-- ============================================
-- ADD MISSING PARTS - Run ini satu per satu
-- ============================================

-- PART 1: Function get_historical_data
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

SELECT 'Function get_historical_data created!' as status;
