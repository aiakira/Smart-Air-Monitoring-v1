import { NextRequest, NextResponse } from 'next/server'
import { query } from '@/lib/db'
import { SensorData, ApiResponse } from '@/lib/types'

export const dynamic = 'force-dynamic'

/**
 * POST endpoint for ESP32/ESP8266 to send sensor data
 * Body: { co2: number, co: number, dust: number }
 */
export async function POST(request: NextRequest) {
  try {
    const body = await request.json()
    const { co2, co, dust } = body

    // Validate sensor data
    if (typeof co2 !== 'number' || co2 < 0 || co2 > 10000) {
      return NextResponse.json<ApiResponse<null>>(
        {
          success: false,
          error: 'Invalid CO2 value. Must be between 0 and 10000.',
        },
        { status: 400 }
      )
    }

    if (typeof co !== 'number' || co < 0 || co > 1000) {
      return NextResponse.json<ApiResponse<null>>(
        {
          success: false,
          error: 'Invalid CO value. Must be between 0 and 1000.',
        },
        { status: 400 }
      )
    }

    if (typeof dust !== 'number' || dust < 0 || dust > 1000) {
      return NextResponse.json<ApiResponse<null>>(
        {
          success: false,
          error: 'Invalid dust value. Must be between 0 and 1000.',
        },
        { status: 400 }
      )
    }

    // Insert sensor data into database
    const result = await query<SensorData>(
      'INSERT INTO sensor_data (co2, co, dust) VALUES ($1, $2, $3) RETURNING *',
      [co2, co, dust]
    )

    if (result.length === 0) {
      return NextResponse.json<ApiResponse<null>>(
        {
          success: false,
          error: 'Failed to insert sensor data',
        },
        { status: 500 }
      )
    }

    return NextResponse.json<ApiResponse<SensorData>>({
      success: true,
      data: result[0],
    })
  } catch (error) {
    console.error('Error inserting sensor data:', error)
    
    return NextResponse.json<ApiResponse<null>>(
      {
        success: false,
        error: 'Failed to insert sensor data',
      },
      { status: 500 }
    )
  }
}
