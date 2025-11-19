-- ============================================
-- COMPLETE MISSING PARTS
-- Jalankan ini untuk melengkapi schema
-- ============================================

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

-- View 1: Daily Statistics dengan kategori
CREATE OR REPLACE VIEW daily_statistics AS
SELECT 
    DATE(timestamp) as date,
    COUNT(*) as total_readings,
    AVG(co2) as avg_co2,
    MAX(co2) as max_co2,
    MIN(co2) as min_co2,
    AVG(co) as avg_co,
    MAX(co) as max_co,
    MIN(co) as min_co,
    AVG(dust) as avg_dust,
    MAX(dust) as max_dust,
    MIN(dust) as min_dust,
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

-- Insert Sample Data
INSERT INTO sensor_data (co2, co, dust, timestamp) VALUES
(450.5, 5.2, 12.3, NOW() - INTERVAL '10 minutes'),
(520.3, 6.1, 14.7, NOW() - INTERVAL '9 minutes'),
(380.2, 4.5, 10.9, NOW() - INTERVAL '8 minutes'),
(850.0, 7.0, 18.0, NOW() - INTERVAL '7 minutes'),
(920.0, 8.0, 20.0, NOW() - INTERVAL '6 minutes'),
(750.0, 5.0, 30.0, NOW() - INTERVAL '5 minutes'),
(700.0, 6.0, 32.0, NOW() - INTERVAL '4 minutes'),
(1500.0, 12.0, 45.0, NOW() - INTERVAL '3 minutes'),
(1800.0, 15.0, 50.0, NOW() - INTERVAL '2 minutes'),
(3000.0, 150.0, 60.0, NOW() - INTERVAL '1 minute');

-- Verification
SELECT 'Schema completed successfully!' as message;
SELECT COUNT(*) as total_records FROM sensor_data;
SELECT * FROM get_latest_reading();
