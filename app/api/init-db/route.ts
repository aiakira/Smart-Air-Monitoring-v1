import { NextResponse } from 'next/server'
import { query } from '@/lib/db'

export const dynamic = 'force-dynamic'

/**
 * Initialize all database functions and tables
 */
export async function POST() {
  try {
    // Create category functions
    await query(`
      -- CO2 Category Function
      CREATE OR REPLACE FUNCTION get_co2_category(co2_value NUMERIC)
      RETURNS VARCHAR(50) AS $$
      BEGIN
        IF co2_value IS NULL THEN
          RETURN 'Unknown';
        ELSIF co2_value <= 400 THEN
          RETURN 'Excellent';
        ELSIF co2_value <= 1000 THEN
          RETURN 'Good';
        ELSIF co2_value <= 2000 THEN
          RETURN 'Fair';
        ELSIF co2_value <= 5000 THEN
          RETURN 'Poor';
        ELSE
          RETURN 'Hazardous';
        END IF;
      END;
      $$ LANGUAGE plpgsql IMMUTABLE;

      -- CO Category Function
      CREATE OR REPLACE FUNCTION get_co_category(co_value NUMERIC)
      RETURNS VARCHAR(50) AS $$
      BEGIN
        IF co_value IS NULL THEN
          RETURN 'Unknown';
        ELSIF co_value <= 4.4 THEN
          RETURN 'Good';
        ELSIF co_value <= 9.4 THEN
          RETURN 'Moderate';
        ELSIF co_value <= 12.4 THEN
          RETURN 'Unhealthy for Sensitive';
        ELSIF co_value <= 15.4 THEN
          RETURN 'Unhealthy';
        ELSIF co_value <= 30.4 THEN
          RETURN 'Very Unhealthy';
        ELSE
          RETURN 'Hazardous';
        END IF;
      END;
      $$ LANGUAGE plpgsql IMMUTABLE;

      -- Dust Category Function
      CREATE OR REPLACE FUNCTION get_dust_category(dust_value NUMERIC)
      RETURNS VARCHAR(50) AS $$
      BEGIN
        IF dust_value IS NULL THEN
          RETURN 'Unknown';
        ELSIF dust_value <= 12 THEN
          RETURN 'Good';
        ELSIF dust_value <= 35.4 THEN
          RETURN 'Moderate';
        ELSIF dust_value <= 55.4 THEN
          RETURN 'Unhealthy for Sensitive';
        ELSIF dust_value <= 150.4 THEN
          RETURN 'Unhealthy';
        ELSIF dust_value <= 250.4 THEN
          RETURN 'Very Unhealthy';
        ELSE
          RETURN 'Hazardous';
        END IF;
      END;
      $$ LANGUAGE plpgsql IMMUTABLE;

      -- Air Quality Status Function
      CREATE OR REPLACE FUNCTION get_air_quality_status(
        co2_value NUMERIC,
        co_value NUMERIC,
        dust_value NUMERIC
      )
      RETURNS VARCHAR(50) AS $$
      DECLARE
        co2_cat VARCHAR(50);
        co_cat VARCHAR(50);
        dust_cat VARCHAR(50);
      BEGIN
        co2_cat := get_co2_category(co2_value);
        co_cat := get_co_category(co_value);
        dust_cat := get_dust_category(dust_value);

        -- Return worst category
        IF co2_cat = 'Hazardous' OR co_cat = 'Hazardous' OR dust_cat = 'Hazardous' THEN
          RETURN 'Hazardous';
        ELSIF co2_cat IN ('Poor', 'Very Unhealthy') OR co_cat = 'Very Unhealthy' OR dust_cat = 'Very Unhealthy' THEN
          RETURN 'Poor';
        ELSIF co2_cat = 'Fair' OR co_cat IN ('Unhealthy', 'Unhealthy for Sensitive') OR dust_cat IN ('Unhealthy', 'Unhealthy for Sensitive') THEN
          RETURN 'Fair';
        ELSIF co2_cat = 'Good' OR co_cat = 'Moderate' OR dust_cat = 'Moderate' THEN
          RETURN 'Good';
        ELSE
          RETURN 'Excellent';
        END IF;
      END;
      $$ LANGUAGE plpgsql IMMUTABLE;
    `)

    // Create get_latest_reading function
    await query(`
      CREATE OR REPLACE FUNCTION get_latest_reading()
      RETURNS TABLE (
        id BIGINT,
        co2 NUMERIC,
        co NUMERIC,
        dust NUMERIC,
        timestamp TIMESTAMP WITH TIME ZONE,
        co2_category VARCHAR(50),
        co_category VARCHAR(50),
        dust_category VARCHAR(50),
        air_quality_status VARCHAR(50)
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
    `)

    // Create get_historical_data function
    await query(`
      CREATE OR REPLACE FUNCTION get_historical_data(hours_back INTEGER DEFAULT 24)
      RETURNS TABLE (
        id BIGINT,
        co2 NUMERIC,
        co NUMERIC,
        dust NUMERIC,
        timestamp TIMESTAMP WITH TIME ZONE,
        co2_category VARCHAR(50),
        co_category VARCHAR(50),
        dust_category VARCHAR(50),
        air_quality_status VARCHAR(50)
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
        WHERE s.timestamp >= NOW() - INTERVAL '1 hour' * hours_back
        ORDER BY s.timestamp ASC;
      END;
      $$ LANGUAGE plpgsql;
    `)

    return NextResponse.json({
      success: true,
      message: 'Database initialized successfully with all functions',
    })
  } catch (error: any) {
    console.error('Database initialization error:', error)
    
    return NextResponse.json({
      success: false,
      error: error.message || 'Failed to initialize database',
      details: process.env.NODE_ENV === 'development' ? error.stack : undefined,
    }, { status: 500 })
  }
}
