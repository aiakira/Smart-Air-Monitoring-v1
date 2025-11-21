import { NextResponse } from 'next/server'
import { query } from '@/lib/db'

export const dynamic = 'force-dynamic'

/**
 * Fix database functions to use BIGINT instead of INTEGER
 */
export async function POST() {
  try {
    // Drop old functions
    await query('DROP FUNCTION IF EXISTS get_latest_reading()')
    await query('DROP FUNCTION IF EXISTS get_historical_data(INTEGER)')

    // Recreate get_latest_reading with correct types
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
      ) AS $func$
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
      $func$ LANGUAGE plpgsql
    `)

    // Recreate get_historical_data with correct types
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
      ) AS $func$
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
      $func$ LANGUAGE plpgsql
    `)

    return NextResponse.json({
      success: true,
      message: 'Database functions fixed successfully',
    })
  } catch (error: any) {
    console.error('Fix database functions error:', error)
    
    return NextResponse.json({
      success: false,
      error: error.message || 'Failed to fix database functions',
      details: error.stack,
    }, { status: 500 })
  }
}
