-- ============================================
-- ADD VIEWS
-- ============================================

-- View 1: Daily Statistics
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

SELECT 'View daily_statistics created!' as status;

-- View 2: Latest Readings
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

SELECT 'View latest_readings created!' as status;
