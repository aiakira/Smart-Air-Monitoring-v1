import { NextResponse } from 'next/server'
import { query, testConnection } from '@/lib/db'

export const dynamic = 'force-dynamic'

/**
 * Complete database setup for Smart Air Monitoring System
 * Sensors: MQ135 (CO2), MQ5524 (CO), GP2Y1010AU0F (Dust)
 */
export async function POST() {
  try {
    // Test connection first
    const isConnected = await testConnection()
    if (!isConnected) {
      return NextResponse.json(
        { success: false, error: 'Database connection failed' },
        { status: 500 }
      )
    }

    // Step 1: Drop existing tables
    await query(`
      DROP TABLE IF EXISTS notifications CASCADE;
      DROP TABLE IF EXISTS kontrol CASCADE;
      DROP TABLE IF EXISTS sensor_data CASCADE;
      DROP VIEW IF EXISTS v_latest_sensor_data CASCADE;
      DROP VIEW IF EXISTS v_hourly_averages CASCADE;
    `)

    // Step 2: Create sensor_data table
    await query(`
      CREATE TABLE sensor_data (
          id BIGSERIAL PRIMARY KEY,
          
          -- Gas Sensors
          co2 NUMERIC(10, 2) NOT NULL CHECK (co2 >= 0 AND co2 <= 10000),
          co NUMERIC(10, 2) NOT NULL CHECK (co >= 0 AND co <= 1000),
          
          -- Dust Sensor
          dust NUMERIC(10, 2) NOT NULL CHECK (dust >= 0 AND dust <= 1000),
          pm25 NUMERIC(10, 2) DEFAULT NULL CHECK (pm25 >= 0 AND pm25 <= 1000),
          pm10 NUMERIC(10, 2) DEFAULT NULL CHECK (pm10 >= 0 AND pm10 <= 1000),
          
          -- Environmental Sensors (Optional)
          temperature NUMERIC(5, 2) DEFAULT NULL CHECK (temperature >= -40 AND temperature <= 80),
          humidity NUMERIC(5, 2) DEFAULT NULL CHECK (humidity >= 0 AND humidity <= 100),
          
          -- Metadata
          timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
          device_id VARCHAR(50) DEFAULT 'ESP32-001',
          
          CONSTRAINT valid_timestamp CHECK (timestamp <= CURRENT_TIMESTAMP + INTERVAL '1 minute')
      )
    `)

    // Step 3: Create indexes
    await query(`
      CREATE INDEX idx_sensor_timestamp ON sensor_data(timestamp DESC);
      CREATE INDEX idx_sensor_device ON sensor_data(device_id);
      CREATE INDEX idx_sensor_co2 ON sensor_data(co2);
      CREATE INDEX idx_sensor_co ON sensor_data(co);
      CREATE INDEX idx_sensor_dust ON sensor_data(dust);
    `)

    // Step 4: Create kontrol table
    await query(`
      CREATE TABLE kontrol (
          id BIGSERIAL PRIMARY KEY,
          fan VARCHAR(3) NOT NULL CHECK (fan IN ('ON', 'OFF')),
          mode VARCHAR(10) NOT NULL CHECK (mode IN ('AUTO', 'MANUAL')),
          waktu TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
          
          -- Auto control thresholds
          co2_threshold NUMERIC(10, 2) DEFAULT 1000,
          co_threshold NUMERIC(10, 2) DEFAULT 50,
          dust_threshold NUMERIC(10, 2) DEFAULT 150,
          
          -- Metadata
          updated_by VARCHAR(50) DEFAULT 'system',
          notes TEXT DEFAULT NULL
      )
    `)

    // Step 5: Insert default control settings
    await query(`
      INSERT INTO kontrol (fan, mode, co2_threshold, co_threshold, dust_threshold, updated_by) 
      VALUES ('OFF', 'AUTO', 1000, 50, 150, 'system')
    `)

    // Step 6: Create notifications table
    await query(`
      CREATE TABLE notifications (
          id BIGSERIAL PRIMARY KEY,
          title VARCHAR(255) NOT NULL,
          message TEXT NOT NULL,
          type VARCHAR(20) NOT NULL CHECK (type IN ('info', 'warning', 'danger', 'success')),
          is_read BOOLEAN DEFAULT FALSE,
          created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
          sensor_data_id BIGINT REFERENCES sensor_data(id) ON DELETE SET NULL,
          priority INTEGER DEFAULT 1 CHECK (priority >= 1 AND priority <= 5),
          expires_at TIMESTAMP DEFAULT NULL
      )
    `)

    // Step 7: Create notification indexes
    await query(`
      CREATE INDEX idx_notifications_created ON notifications(created_at DESC);
      CREATE INDEX idx_notifications_read ON notifications(is_read);
      CREATE INDEX idx_notifications_type ON notifications(type);
    `)

    // Step 8: Create categorization functions
    await query(`
      CREATE OR REPLACE FUNCTION get_co2_category(co2_value NUMERIC)
      RETURNS VARCHAR AS $$
      BEGIN
          RETURN CASE
              WHEN co2_value < 400 THEN 'Sangat Baik'
              WHEN co2_value < 600 THEN 'Baik'
              WHEN co2_value < 1000 THEN 'Masih Aman'
              WHEN co2_value < 2000 THEN 'Tidak Sehat'
              WHEN co2_value < 5000 THEN 'Bahaya'
              ELSE 'Sangat Berbahaya'
          END;
      END;
      $$ LANGUAGE plpgsql IMMUTABLE;
    `)

    await query(`
      CREATE OR REPLACE FUNCTION get_co_category(co_value NUMERIC)
      RETURNS VARCHAR AS $$
      BEGIN
          RETURN CASE
              WHEN co_value < 9 THEN 'Aman'
              WHEN co_value < 35 THEN 'Tidak Sehat'
              WHEN co_value < 100 THEN 'Berbahaya'
              WHEN co_value < 200 THEN 'Sangat Berbahaya'
              ELSE 'Fatal'
          END;
      END;
      $$ LANGUAGE plpgsql IMMUTABLE;
    `)

    await query(`
      CREATE OR REPLACE FUNCTION get_dust_category(dust_value NUMERIC)
      RETURNS VARCHAR AS $$
      BEGIN
          RETURN CASE
              WHEN dust_value < 50 THEN 'Baik'
              WHEN dust_value < 100 THEN 'Sedang'
              WHEN dust_value < 150 THEN 'Tidak Sehat'
              WHEN dust_value < 250 THEN 'Sangat Tidak Sehat'
              ELSE 'Berbahaya'
          END;
      END;
      $$ LANGUAGE plpgsql IMMUTABLE;
    `)

    await query(`
      CREATE OR REPLACE FUNCTION get_air_quality_status(
          co2_value NUMERIC,
          co_value NUMERIC,
          dust_value NUMERIC
      )
      RETURNS VARCHAR AS $$
      DECLARE
          co2_cat VARCHAR;
          co_cat VARCHAR;
          dust_cat VARCHAR;
      BEGIN
          co2_cat := get_co2_category(co2_value);
          co_cat := get_co_category(co_value);
          dust_cat := get_dust_category(dust_value);
          
          IF co_cat = 'Fatal' THEN
              RETURN 'FATAL - CO Sangat Tinggi';
          ELSIF co_cat = 'Sangat Berbahaya' OR co2_cat = 'Sangat Berbahaya' THEN
              RETURN 'SANGAT BERBAHAYA';
          ELSIF co_cat = 'Berbahaya' OR co2_cat = 'Bahaya' OR dust_cat = 'Berbahaya' THEN
              RETURN 'BAHAYA';
          ELSIF co_cat = 'Tidak Sehat' OR co2_cat = 'Tidak Sehat' OR dust_cat = 'Sangat Tidak Sehat' THEN
              RETURN 'TIDAK SEHAT';
          ELSIF dust_cat = 'Tidak Sehat' OR co2_cat = 'Masih Aman' THEN
              RETURN 'SEDANG';
          ELSIF dust_cat = 'Sedang' THEN
              RETURN 'CUKUP BAIK';
          ELSE
              RETURN 'BAIK';
          END IF;
      END;
      $$ LANGUAGE plpgsql IMMUTABLE;
    `)

    // Step 9: Create auto-notification trigger
    await query(`
      CREATE OR REPLACE FUNCTION create_notification_on_danger()
      RETURNS TRIGGER AS $$
      DECLARE
          air_status VARCHAR;
          co2_cat VARCHAR;
          co_cat VARCHAR;
          dust_cat VARCHAR;
      BEGIN
          air_status := get_air_quality_status(NEW.co2, NEW.co, NEW.dust);
          co2_cat := get_co2_category(NEW.co2);
          co_cat := get_co_category(NEW.co);
          dust_cat := get_dust_category(NEW.dust);
          
          IF co_cat IN ('Fatal', 'Sangat Berbahaya', 'Berbahaya') THEN
              INSERT INTO notifications (title, message, type, sensor_data_id, priority)
              VALUES (
                  '⚠️ BAHAYA: Kadar CO Tinggi!',
                  format('Kadar CO mencapai %.2f ppm (%s). Segera evakuasi dan ventilasi ruangan!', NEW.co, co_cat),
                  'danger',
                  NEW.id,
                  5
              );
          END IF;
          
          IF co2_cat IN ('Sangat Berbahaya', 'Bahaya') THEN
              INSERT INTO notifications (title, message, type, sensor_data_id, priority)
              VALUES (
                  '⚠️ Peringatan: Kadar CO2 Tinggi',
                  format('Kadar CO2 mencapai %.2f ppm (%s). Tingkatkan ventilasi ruangan.', NEW.co2, co2_cat),
                  'warning',
                  NEW.id,
                  4
              );
          END IF;
          
          IF dust_cat IN ('Berbahaya', 'Sangat Tidak Sehat') THEN
              INSERT INTO notifications (title, message, type, sensor_data_id, priority)
              VALUES (
                  '⚠️ Peringatan: Kadar Debu Tinggi',
                  format('Kadar debu mencapai %.2f µg/m³ (%s). Gunakan masker dan bersihkan ruangan.', NEW.dust, dust_cat),
                  'warning',
                  NEW.id,
                  3
              );
          END IF;
          
          RETURN NEW;
      END;
      $$ LANGUAGE plpgsql;
    `)

    await query(`
      DROP TRIGGER IF EXISTS trigger_notification_on_danger ON sensor_data;
      CREATE TRIGGER trigger_notification_on_danger
          AFTER INSERT ON sensor_data
          FOR EACH ROW
          EXECUTE FUNCTION create_notification_on_danger();
    `)

    // Step 10: Create auto-control fan trigger
    await query(`
      CREATE OR REPLACE FUNCTION auto_control_fan()
      RETURNS TRIGGER AS $$
      DECLARE
          current_mode VARCHAR;
          current_thresholds RECORD;
      BEGIN
          SELECT mode, co2_threshold, co_threshold, dust_threshold
          INTO current_mode, current_thresholds
          FROM kontrol
          ORDER BY id DESC
          LIMIT 1;
          
          IF current_mode = 'AUTO' THEN
              IF NEW.co2 > current_thresholds.co2_threshold OR
                 NEW.co > current_thresholds.co_threshold OR
                 NEW.dust > current_thresholds.dust_threshold THEN
                  
                  UPDATE kontrol
                  SET fan = 'ON',
                      waktu = CURRENT_TIMESTAMP,
                      updated_by = 'auto-system',
                      notes = format('Auto ON: CO2=%.2f, CO=%.2f, Dust=%.2f', NEW.co2, NEW.co, NEW.dust)
                  WHERE id = (SELECT id FROM kontrol ORDER BY id DESC LIMIT 1);
                  
              ELSIF NEW.co2 < current_thresholds.co2_threshold * 0.8 AND
                    NEW.co < current_thresholds.co_threshold * 0.8 AND
                    NEW.dust < current_thresholds.dust_threshold * 0.8 THEN
                  
                  UPDATE kontrol
                  SET fan = 'OFF',
                      waktu = CURRENT_TIMESTAMP,
                      updated_by = 'auto-system',
                      notes = format('Auto OFF: CO2=%.2f, CO=%.2f, Dust=%.2f', NEW.co2, NEW.co, NEW.dust)
                  WHERE id = (SELECT id FROM kontrol ORDER BY id DESC LIMIT 1);
              END IF;
          END IF;
          
          RETURN NEW;
      END;
      $$ LANGUAGE plpgsql;
    `)

    await query(`
      DROP TRIGGER IF EXISTS trigger_auto_control_fan ON sensor_data;
      CREATE TRIGGER trigger_auto_control_fan
          AFTER INSERT ON sensor_data
          FOR EACH ROW
          EXECUTE FUNCTION auto_control_fan();
    `)

    // Step 11: Create views
    await query(`
      CREATE OR REPLACE VIEW v_latest_sensor_data AS
      SELECT 
          id,
          co2,
          co,
          dust,
          pm25,
          pm10,
          temperature,
          humidity,
          timestamp,
          device_id,
          get_co2_category(co2) as co2_category,
          get_co_category(co) as co_category,
          get_dust_category(dust) as dust_category,
          get_air_quality_status(co2, co, dust) as air_quality_status
      FROM sensor_data
      ORDER BY timestamp DESC
      LIMIT 1;
    `)

    await query(`
      CREATE OR REPLACE VIEW v_hourly_averages AS
      SELECT 
          DATE_TRUNC('hour', timestamp) as hour,
          ROUND(AVG(co2)::numeric, 2) as avg_co2,
          ROUND(AVG(co)::numeric, 2) as avg_co,
          ROUND(AVG(dust)::numeric, 2) as avg_dust,
          ROUND(AVG(temperature)::numeric, 2) as avg_temperature,
          ROUND(AVG(humidity)::numeric, 2) as avg_humidity,
          COUNT(*) as reading_count,
          MAX(co2) as max_co2,
          MAX(co) as max_co,
          MAX(dust) as max_dust
      FROM sensor_data
      WHERE timestamp >= NOW() - INTERVAL '7 days'
      GROUP BY DATE_TRUNC('hour', timestamp)
      ORDER BY hour DESC;
    `)

    return NextResponse.json({
      success: true,
      message: '✅ Database setup berhasil!',
      features: [
        '✓ Tabel sensor_data dengan support MQ135, MQ5524, GP2Y1010AU0F',
        '✓ Fungsi kategorisasi otomatis untuk CO2, CO, dan Debu',
        '✓ Sistem notifikasi otomatis untuk level berbahaya',
        '✓ Kontrol kipas otomatis berdasarkan threshold',
        '✓ View analytics per jam',
        '✓ Trigger dan function untuk automasi'
      ],
      tables: ['sensor_data', 'kontrol', 'notifications'],
      views: ['v_latest_sensor_data', 'v_hourly_averages'],
      functions: [
        'get_co2_category()',
        'get_co_category()',
        'get_dust_category()',
        'get_air_quality_status()',
        'create_notification_on_danger()',
        'auto_control_fan()'
      ]
    })
  } catch (error: any) {
    console.error('Database setup error:', error)
    
    return NextResponse.json({
      success: false,
      error: 'Gagal setup database',
      details: error.message || 'Unknown error',
      stack: process.env.NODE_ENV === 'development' ? error.stack : undefined
    }, { status: 500 })
  }
}

export async function GET() {
  return NextResponse.json({
    message: 'Gunakan POST method untuk setup database',
    endpoint: '/api/setup-db',
    method: 'POST'
  })
}
