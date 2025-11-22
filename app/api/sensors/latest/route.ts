import { NextResponse } from 'next/server'
import { query } from '@/lib/db'
import { SensorDataWithCategories, ApiResponse } from '@/lib/types'

export const dynamic = 'force-dynamic'

export async function GET() {
  try {
    // Query latest sensor data with categories
    const result = await query<any>(`
      SELECT 
        s.id,
        s.co2,
        s.co,
        s.dust,
        s.timestamp,
        CASE 
          WHEN s.co2 <= 800 THEN 'Baik'
          WHEN s.co2 <= 1000 THEN 'Masih Aman'
          WHEN s.co2 <= 2000 THEN 'Tidak Sehat'
          WHEN s.co2 <= 5000 THEN 'Bahaya'
          ELSE 'Sangat Berbahaya'
        END as co2_category,
        CASE 
          WHEN s.co <= 9 THEN 'Aman'
          WHEN s.co <= 35 THEN 'Tidak Sehat'
          WHEN s.co <= 200 THEN 'Berbahaya'
          WHEN s.co <= 800 THEN 'Sangat Berbahaya'
          ELSE 'Fatal'
        END as co_category,
        CASE 
          WHEN s.dust <= 15 THEN 'Baik'
          WHEN s.dust <= 35 THEN 'Sedang'
          WHEN s.dust <= 55 THEN 'Tidak Sehat'
          ELSE 'Sangat Tidak Sehat'
        END as dust_category,
        CASE 
          WHEN s.co > 800 THEN 'FATAL - CO Sangat Tinggi'
          WHEN s.co2 > 5000 OR s.co > 200 THEN 'SANGAT BERBAHAYA'
          WHEN s.co2 > 2000 OR s.co > 35 THEN 'BAHAYA'
          WHEN s.co2 > 1000 OR s.co > 9 OR s.dust > 55 THEN 'TIDAK SEHAT'
          WHEN s.dust > 35 OR s.dust > 15 THEN 'SEDANG'
          WHEN s.co2 > 800 THEN 'CUKUP BAIK'
          ELSE 'BAIK'
        END as air_quality_status
      FROM sensor_data s
      ORDER BY s.timestamp DESC
      LIMIT 1
    `)

    if (result.length === 0) {
      return NextResponse.json<ApiResponse<null>>(
        {
          success: true,
          data: null,
          error: 'No sensor data available. Please send data from ESP32 or use test endpoint.',
        },
        { status: 200 }
      )
    }

    const sensorData = result[0]

    return NextResponse.json<ApiResponse<SensorDataWithCategories>>({
      success: true,
      data: sensorData,
    })
  } catch (error) {
    console.error('Error fetching latest sensor data:', error)
    
    return NextResponse.json<ApiResponse<null>>(
      {
        success: false,
        error: 'Failed to fetch sensor data',
      },
      { status: 500 }
    )
  }
}
