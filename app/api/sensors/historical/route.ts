import { NextRequest, NextResponse } from 'next/server'
import { query } from '@/lib/db'
import { SensorDataWithCategories, ApiResponse } from '@/lib/types'

export const dynamic = 'force-dynamic'

export async function GET(request: NextRequest) {
  try {
    // Get hours parameter from query string (default: 24)
    const searchParams = request.nextUrl.searchParams
    const hoursParam = searchParams.get('hours')
    
    // Validate and parse hours parameter
    let hours = 24
    if (hoursParam) {
      const parsedHours = parseInt(hoursParam, 10)
      if (isNaN(parsedHours) || parsedHours < 1 || parsedHours > 168) {
        return NextResponse.json<ApiResponse<null>>(
          {
            success: false,
            error: 'Invalid hours parameter. Must be between 1 and 168.',
          },
          { status: 400 }
        )
      }
      hours = parsedHours
    }

    // Query historical sensor data with categories
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
      WHERE s.timestamp >= NOW() - INTERVAL '1 hour' * $1
      ORDER BY s.timestamp ASC
    `, [hours])

    return NextResponse.json<ApiResponse<SensorDataWithCategories[]>>({
      success: true,
      data: result,
    })
  } catch (error) {
    console.error('Error fetching historical sensor data:', error)
    
    return NextResponse.json<ApiResponse<null>>(
      {
        success: false,
        error: 'Failed to fetch historical sensor data',
      },
      { status: 500 }
    )
  }
}
