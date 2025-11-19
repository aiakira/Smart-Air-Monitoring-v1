-- ============================================
-- NEON DATABASE SCHEMA - FIXED VERSION
-- Sesuai dengan aplikasi Flutter
-- ============================================
-- 
-- PENJELASAN SCHEMA:
-- 
-- 1. TABLE sensor_data
--    Menyimpan data sensor (CO2, CO, Debu) dengan timestamp
--    TIDAK ada field 'status' karena status dihitung dinamis
-- 
-- 2. FUNCTIONS (7 functions)
--    - get_co2_category() : Kategori CO₂ (5 level)
--    - get_co_category() : Kategori CO (5 level)
--    - get_dust_category() : Kategori Debu (4 level)
--    - get_air_quality_status() : Status keseluruhan (7 level)
--    - get_latest_reading() : Ambil data terbaru
--    - get_historical_data() : Ambil data historis
--    - cleanup_old_data() : Hapus data lama
-- 
-- 3. VIEWS (2 views)
--    - daily_statistics : Statistik harian
--    - latest_readings : 100 data terbaru
-- 
-- 4. SAMPLE DATA
--    10 sample records untuk testing
-- 
-- ============================================

-- Drop existing table if exists (HATI-HATI!)
-- Uncomment jika ingin reset total
-- DROP TABLE IF EXISTS sensor_data CASCADE;

-- ============================================
-- 1. CREATE TABLE
-- ============================================

CREATE TABLE IF NOT EXISTS sensor_data (
    id SERIAL PRIMARY KEY,
    co2 DOUBLE PRECISION NOT NULL CHECK (co2 >= 0),
    co DOUBLE PRECISION NOT NULL CHECK (co >= 0),
    dust DOUBLE PRECISION NOT NULL CHECK (dust >= 0),
    timestamp TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Create indexes untuk performa
CREATE INDEX IF NOT EXISTS idx_sensor_data_timestamp ON sensor_data(timestamp DESC);
CREATE INDEX IF NOT EXISTS idx_sensor_data_co2 ON sensor_data(co2);
CREATE INDEX IF NOT EXISTS idx_sensor_data_co ON sensor_data(co);
CREATE INDEX IF NOT EXISTS idx_sensor_data_dust ON sensor_data(dust);

-- ============================================
-- 2. CREATE FUNCTIONS
-- ============================================

-- Function 1: Kategori CO₂ (5 kategori)
CREATE OR REPLACE FUNCTION get_co2_category(co2_value DOUBLE PRECISION)
RETURNS VARCHAR(20) AS $$
BEGIN
    IF co2_value <= 800 THEN
        RETURN 'BAIK';
    ELSIF co2_value <= 1000 THEN
        RETURN 'MASIH AMAN';
    ELSIF co2_value <= 2000 THEN
        RETURN 'TIDAK SEHAT';
    ELSIF co2_value <= 5000 THEN
        RETURN 'BAHAYA';
    ELSE
        RETURN 'SANGAT BERBAHAYA';
    END IF;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

-- Function 2: Kategori CO (5 kategori)
CREATE OR REPLACE FUNCTION get_co_category(co_value DOUBLE PRECISION)
RETURNS VARCHAR(20) AS $$
BEGIN
    IF co_value <= 9 THEN
        RETURN 'AMAN';
    ELSIF co_value <= 35 THEN
        RETURN 'TIDAK SEHAT';
    ELSIF co_value <= 200 THEN
        RETURN 'BERBAHAYA';
    ELSIF co_value <= 800 THEN
        RETURN 'SANGAT BERBAHAYA';
    ELSE
        RETURN 'FATAL';
    END IF;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

-- Function 3: Kategori Debu (4 kategori)
CREATE OR REPLACE FUNCTION get_dust_category(dust_value DOUBLE PRECISION)
RETURNS VARCHAR(25) AS $$
BEGIN
    IF dust_value <= 15 THEN
        RETURN 'BAIK';
    ELSIF dust_value <= 35 THEN
        RETURN 'SEDANG';
    ELSIF dust_value <= 55 THEN
        RETURN 'TIDAK SEHAT';
    ELSE
        RETURN 'SANGAT TIDAK SEHAT';
    END IF;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

-- Function 4: Status Kualitas Udara Keseluruhan (7 status)
CREATE OR REPLACE FUNCTION get_air_quality_status(
    co2_value DOUBLE PRECISION,
    co_value DOUBLE PRECISION,
    dust_value DOUBLE PRECISION
)
RETURNS VARCHAR(20) AS $$
DECLARE
    co2_cat VARCHAR(20);
    co_cat VARCHAR(20);
    dust_cat VARCHAR(25);
BEGIN
    co2_cat := get_co2_category(co2_value);
    co_cat := get_co_category(co_value);
    dust_cat := get_dust_category(dust_value);
    
    -- Prioritas: FATAL > SANGAT BERBAHAYA > BAHAYA > TIDAK SEHAT > SEDANG > MASIH AMAN > AMAN > BAIK
    IF co_cat = 'FATAL' THEN
        RETURN 'FATAL';
    ELSIF co2_cat = 'SANGAT BERBAHAYA' OR co_cat = 'SANGAT BERBAHAYA' OR dust_cat = 'SANGAT TIDAK SEHAT' THEN
        RETURN 'SANGAT BURUK';
    ELSIF co2_cat = 'BAHAYA' OR co_cat = 'BERBAHAYA' THEN
        RETURN 'BAHAYA';
    ELSIF co2_cat = 'TIDAK SEHAT' OR co_cat = 'TIDAK SEHAT' OR dust_cat = 'TIDAK SEHAT' THEN
        RETURN 'TIDAK SEHAT';
    ELSIF dust_cat = 'SEDANG' THEN
        RETURN 'SEDANG';
    ELSIF co2_cat = 'MASIH AMAN' THEN
        RETURN 'MASIH AMAN';
    ELSE
        RETURN 'BAIK';
    END IF;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

-- Function 5: Cleanup data lama
CREATE OR REPLACE FUNCTION cleanup_old_data(days_to_keep INTEGER DEFAULT 30)
RETURNS INTEGER AS $$
DECLARE
    deleted_count INTEGER;
BEGIN
    DELETE FROM sensor_data
    WHERE timestamp < NOW() - (days_to_keep || ' days')::INTERVAL;
    
    GET DIAGNOSTICS deleted_count = ROW_COUNT;
    RETURN deleted_count;
END;
$$ LANGUAGE plpgsql;

-- Function 6: Get latest reading dengan kategori
CREATE OR REPLACE FUNCTION get_latest_reading()
RETURNS TABLE (
    id INTEGER,
    co2 DOUBLE PRECISION,
    co DOUBLE PRECISION,
    dust DOUBLE PRECISION,
    timestamp TIMESTAMP,
    co2_category VARCHAR(20),
    co_category VARCHAR(20),
    dust_category VARCHAR(25),
    air_quality_status VARCHAR(20)
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        s.id,
        s.co2,
        s.co,
        s.dust,
        s.timestamp,
        get_co2_category(s.co2) as co2_category,
        get_co_category(s.co) as co_category,
        get_dust_category(s.dust) as dust_category,
        get_air_quality_status(s.co2, s.co, s.dust) as air_quality_status
    FROM sensor_data s
    ORDER BY s.timestamp DESC
    LIMIT 1;
END;
$$ LANGUAGE plpgsql;

-- Function 7: Get historical data dengan time range
CREATE OR REPLACE FUNCTION get_historical_data(hours_back INTEGER DEFAULT 24)
RETURNS TABLE (
    id INTEGER,
    co2 DOUBLE PRECISION,
    co DOUBLE PRECISION,
    dust DOUBLE PRECISION,
    timestamp TIMESTAMP,
    air_quality_status VARCHAR(20)
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        s.id,
        s.co2,
        s.co,
        s.dust,
        s.timestamp,
        get_air_quality_status(s.co2, s.co, s.dust) as air_quality_status
    FROM sensor_data s
    WHERE s.timestamp >= NOW() - (hours_back || ' hours')::INTERVAL
    ORDER BY s.timestamp ASC;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- 3. CREATE VIEWS
-- ============================================

-- View 1: Daily Statistics dengan kategori
CREATE OR REPLACE VIEW daily_statistics AS
SELECT 
    DATE(timestamp) as date,
    COUNT(*) as total_readings,
    -- CO2 Statistics
    AVG(co2) as avg_co2,
    MAX(co2) as max_co2,
    MIN(co2) as min_co2,
    -- CO Statistics
    AVG(co) as avg_co,
    MAX(co) as max_co,
    MIN(co) as min_co,
    -- Dust Statistics
    AVG(dust) as avg_dust,
    MAX(dust) as max_dust,
    MIN(dust) as min_dust,
    -- Status counts (calculated)
    SUM(CASE WHEN get_air_quality_status(co2, co, dust) = 'BAIK' THEN 1 ELSE 0 END) as baik_count,
    SUM(CASE WHEN get_air_quality_status(co2, co, dust) = 'MASIH AMAN' THEN 1 ELSE 0 END) as masih_aman_count,
    SUM(CASE WHEN get_air_quality_status(co2, co, dust) = 'SEDANG' THEN 1 ELSE 0 END) as sedang_count,
    SUM(CASE WHEN get_air_quality_status(co2, co, dust) = 'TIDAK SEHAT' THEN 1 ELSE 0 END) as tidak_sehat_count,
    SUM(CASE WHEN get_air_quality_status(co2, co, dust) = 'BAHAYA' THEN 1 ELSE 0 END) as bahaya_count,
    SUM(CASE WHEN get_air_quality_status(co2, co, dust) = 'SANGAT BURUK' THEN 1 ELSE 0 END) as sangat_buruk_count,
    SUM(CASE WHEN get_air_quality_status(co2, co, dust) = 'FATAL' THEN 1 ELSE 0 END) as fatal_count
FROM sensor_data
GROUP BY DATE(timestamp)
ORDER BY date DESC;

-- View 2: Latest readings dengan kategori
CREATE OR REPLACE VIEW latest_readings AS
SELECT 
    id,
    co2,
    co,
    dust,
    timestamp,
    get_co2_category(co2) as co2_category,
    get_co_category(co) as co_category,
    get_dust_category(dust) as dust_category,
    get_air_quality_status(co2, co, dust) as air_quality_status
FROM sensor_data
ORDER BY timestamp DESC
LIMIT 100;

-- ============================================
-- 4. INSERT SAMPLE DATA
-- ============================================

INSERT INTO sensor_data (co2, co, dust, timestamp) VALUES
-- Data BAIK
(450.5, 5.2, 12.3, NOW() - INTERVAL '10 minutes'),
(520.3, 6.1, 14.7, NOW() - INTERVAL '9 minutes'),
(380.2, 4.5, 10.9, NOW() - INTERVAL '8 minutes'),
-- Data MASIH AMAN
(850.0, 7.0, 18.0, NOW() - INTERVAL '7 minutes'),
(920.0, 8.0, 20.0, NOW() - INTERVAL '6 minutes'),
-- Data SEDANG
(750.0, 5.0, 30.0, NOW() - INTERVAL '5 minutes'),
(700.0, 6.0, 32.0, NOW() - INTERVAL '4 minutes'),
-- Data TIDAK SEHAT
(1500.0, 12.0, 45.0, NOW() - INTERVAL '3 minutes'),
(1800.0, 15.0, 50.0, NOW() - INTERVAL '2 minutes'),
-- Data BAHAYA
(3000.0, 150.0, 60.0, NOW() - INTERVAL '1 minute');

-- ============================================
-- 5. VERIFICATION
-- ============================================

-- Success message
SELECT 'Database schema created successfully!' as message;

-- Count records
SELECT COUNT(*) as total_records FROM sensor_data;

-- Test latest reading
SELECT * FROM get_latest_reading();

-- Test daily statistics
SELECT * FROM daily_statistics LIMIT 5;

-- Test all categories
SELECT 
    co2,
    get_co2_category(co2) as co2_cat,
    co,
    get_co_category(co) as co_cat,
    dust,
    get_dust_category(dust) as dust_cat,
    get_air_quality_status(co2, co, dust) as overall_status
FROM sensor_data
ORDER BY timestamp DESC
LIMIT 10;

-- ============================================
-- SELESAI!
-- ============================================
-- 
-- Schema berhasil dibuat dengan:
-- ✅ 1 Table (sensor_data)
-- ✅ 7 Functions
-- ✅ 2 Views
-- ✅ 10 Sample Data
-- ✅ 4 Indexes
-- 
-- Next: Test dengan node database/test_connection.js
-- ============================================
