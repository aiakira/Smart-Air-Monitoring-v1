import { NextResponse } from 'next/server'
import { query } from '@/lib/db'
import { KontrolData, ApiResponse } from '@/lib/types'

export const dynamic = 'force-dynamic'

/**
 * GET endpoint for ESP32/ESP8266 to read fan control status
 * Returns: { fan: "ON" | "OFF", mode: "AUTO" | "MANUAL" }
 */
export async function GET() {
  try {
    // Get the most recent control record
    const result = await query<KontrolData>(
      'SELECT * FROM kontrol ORDER BY waktu DESC LIMIT 1'
    )

    if (result.length === 0) {
      // Return default values if no control data exists
      return NextResponse.json({
        success: true,
        fan: 'OFF',
        mode: 'AUTO',
      })
    }

    const control = result[0]

    return NextResponse.json({
      success: true,
      fan: control.fan,
      mode: control.mode,
    })
  } catch (error) {
    console.error('Error fetching control data:', error)
    
    return NextResponse.json<ApiResponse<null>>(
      {
        success: false,
        error: 'Failed to fetch control data',
      },
      { status: 500 }
    )
  }
}
