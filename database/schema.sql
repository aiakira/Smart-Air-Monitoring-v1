-- =====================================================
-- SMART AIR MONITORING SYSTEM - DATABASE SCHEMA
-- Sensors: MQ135 (CO2), MQ5524 (CO), GP2Y1010AU0F (Dust)
-- =====================================================

-- Drop existing tables if they exist
DROP TABLE IF EXISTS notifications CASCADE;
DROP TABLE IF EXISTS kontrol CASCADE;
DROP TABLE IF EXISTS sensor_data CASCADE;

-- =====================================================
-- TABLE: sensor_data
-- Stores all sensor readings from ESP32
-- =====================================================
CREATE TABLE sensor_data (
    id BIGSERIAL PRIMARY KEY,
    
    -- Gas Sensors
    co2 NUMERIC(10, 2) NOT NULL CHECK (co2 >= 0 AND co2 <= 10000),  -- MQ135: 0-10000 ppm
    co NUMERIC(10, 2) NOT NULL CHECK (co >= 0 AND co <= 1000),      -- MQ5524: 0-1000 ppm
    
    -- Dust Sensor
    dust NUMERIC(10, 2) NOT NULL CHECK (dust >= 0 AND dust <= 1000), -- GP2Y1010AU0F: 0-1000 µg/m³
    pm25 NUMERIC(10, 2) DEFAULT NULL CHECK (pm25 >= 0 AND pm25 <= 1000), -- Optional PM2.5
    pm10 NUMERIC(10, 2) DEFAULT NULL CHECK (pm10 >= 0 AND pm10 <= 1000), -- Optional PM10
    
    -- Environmental Sensors (Optional - DHT22/BME280)
    temperature NUMERIC(5, 2) DEFAULT NULL CHECK (temperature >= -40 AND temperature <= 80),
    humidity NUMERIC(5, 2) DEFAULT NULL CHECK (humidity >= 0 AND humidity <= 100),
    
    -- Metadata
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    device_id VARCHAR(50) DEFAULT 'ESP32-001',
    
    -- Indexes for performance
    CONSTRAINT valid_timestamp CHECK (timestamp <= CURRENT_TIMESTAMP + INTERVAL '1 minute')
);

-- Create indexes for faster queries
CREATE INDEX idx_sensor_timestamp ON sensor_data(timestamp DESC);
CREATE INDEX idx_sensor_device ON sensor_data(device_id);
CREATE INDEX idx_sensor_co2 ON sensor_data(co2);
CREATE INDEX idx_sensor_co ON sensor_data(co);
CREATE INDEX idx_sensor_dust ON sensor_data(dust);

-- =====================================================
-- TABLE: kontrol
-- Stores fan control settings
-- =====================================================
CREATE TABLE kontrol (
    id BIGSERIAL PRIMARY KEY,
    fan VARCHAR(3) NOT NULL CHECK (fan IN ('ON', 'OFF')),
    mode VARCHAR(10) NOT NULL CHECK (mode IN ('AUTO', 'MANUAL')),
    waktu TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- Auto control thresholds
    co2_threshold NUMERIC(10, 2) DEFAULT 1000,  -- Auto ON if CO2 > threshold
    co_threshold NUMERIC(10, 2) DEFAULT 50,     -- Auto ON if CO > threshold
    dust_threshold NUMERIC(10, 2) DEFAULT 150,  -- Auto ON if dust > threshold
    
    -- Metadata
    updated_by VARCHAR(50) DEFAULT 'system',
    notes TEXT DEFAULT NULL
);

-- Insert default control settings
INSERT INTO kontrol (fan, mode, co2_threshold, co_threshold, dust_threshold, updated_by) 
VALUES ('OFF', 'AUTO', 1000, 50, 150, 'system');

-- =====================================================
-- TABLE: notifications
-- Stores system notifications and alerts
-- =====================================================
CREATE TABLE notifications (
    id BIGSERIAL PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    message TEXT NOT NULL,
    type VARCHAR(20) NOT NULL CHECK (type IN ('info', 'warning', 'danger', 'success')),
    is_read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    sensor_data_id BIGINT REFERENCES sensor_data(id) ON DELETE SET NULL,
    
    -- Priority level
    priority INTEGER DEFAULT 1 CHECK (priority >= 1 AND priority <= 5),
    
    -- Auto-dismiss after certain time
    expires_at TIMESTAMP DEFAULT NULL
);

-- Create indexes
CREATE INDEX idx_notifications_created ON notifications(created_at DESC);
CREATE INDEX idx_notifications_read ON notifications(is_read);
CREATE INDEX idx_notifications_type ON notifications(type);

-- =====================================================
-- FUNCTION: Categorize CO2 levels (MQ135)
-- =====================================================
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

-- =====================================================
-- FUNCTION: Categorize CO levels (MQ5524)
-- =====================================================
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

-- =====================================================
-- FUNCTION: Categorize Dust levels (GP2Y1010AU0F)
-- =====================================================
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

-- =====================================================
-- FUNCTION: Calculate overall air quality status
-- =====================================================
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
    
    -- CO is most dangerous, prioritize it
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

-- =====================================================
-- FUNCTION: Auto-create notifications for dangerous levels
-- =====================================================
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
    
    -- Create notification for dangerous CO levels
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
    
    -- Create notification for dangerous CO2 levels
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
    
    -- Create notification for high dust levels
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

-- Create trigger
DROP TRIGGER IF EXISTS trigger_notification_on_danger ON sensor_data;
CREATE TRIGGER trigger_notification_on_danger
    AFTER INSERT ON sensor_data
    FOR EACH ROW
    EXECUTE FUNCTION create_notification_on_danger();

-- =====================================================
-- FUNCTION: Auto-control fan based on sensor readings
-- =====================================================
CREATE OR REPLACE FUNCTION auto_control_fan()
RETURNS TRIGGER AS $$
DECLARE
    current_mode VARCHAR;
    current_thresholds RECORD;
BEGIN
    -- Get current control settings
    SELECT mode, co2_threshold, co_threshold, dust_threshold
    INTO current_mode, current_thresholds
    FROM kontrol
    ORDER BY id DESC
    LIMIT 1;
    
    -- Only auto-control if mode is AUTO
    IF current_mode = 'AUTO' THEN
        -- Turn fan ON if any threshold is exceeded
        IF NEW.co2 > current_thresholds.co2_threshold OR
           NEW.co > current_thresholds.co_threshold OR
           NEW.dust > current_thresholds.dust_threshold THEN
            
            UPDATE kontrol
            SET fan = 'ON',
                waktu = CURRENT_TIMESTAMP,
                updated_by = 'auto-system',
                notes = format('Auto ON: CO2=%.2f, CO=%.2f, Dust=%.2f', NEW.co2, NEW.co, NEW.dust)
            WHERE id = (SELECT id FROM kontrol ORDER BY id DESC LIMIT 1);
            
        -- Turn fan OFF if all values are below 80% of thresholds
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

-- Create trigger
DROP TRIGGER IF EXISTS trigger_auto_control_fan ON sensor_data;
CREATE TRIGGER trigger_auto_control_fan
    AFTER INSERT ON sensor_data
    FOR EACH ROW
    EXECUTE FUNCTION auto_control_fan();

-- =====================================================
-- VIEW: Latest sensor data with categories
-- =====================================================
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

-- =====================================================
-- VIEW: Hourly averages for analytics
-- =====================================================
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

-- =====================================================
-- FUNCTION: Cleanup old data (keep last 30 days)
-- =====================================================
CREATE OR REPLACE FUNCTION cleanup_old_data()
RETURNS INTEGER AS $$
DECLARE
    deleted_count INTEGER;
BEGIN
    -- Delete sensor data older than 30 days
    DELETE FROM sensor_data
    WHERE timestamp < NOW() - INTERVAL '30 days';
    
    GET DIAGNOSTICS deleted_count = ROW_COUNT;
    
    -- Delete read notifications older than 7 days
    DELETE FROM notifications
    WHERE is_read = TRUE AND created_at < NOW() - INTERVAL '7 days';
    
    RETURN deleted_count;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- Grant permissions (if needed)
-- =====================================================
-- GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO your_user;
-- GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO your_user;

-- =====================================================
-- Insert sample data for testing (optional)
-- =====================================================
-- INSERT INTO sensor_data (co2, co, dust, temperature, humidity)
-- VALUES 
--     (450, 5.2, 35, 25.5, 60),
--     (520, 8.1, 45, 26.0, 58),
--     (480, 6.5, 40, 25.8, 59);

COMMENT ON TABLE sensor_data IS 'Stores all sensor readings from ESP32 with MQ135, MQ5524, and GP2Y1010AU0F sensors';
COMMENT ON TABLE kontrol IS 'Stores fan control settings and thresholds';
COMMENT ON TABLE notifications IS 'Stores system notifications and alerts';
