import { NextRequest, NextResponse } from 'next/server'
import { query } from '@/lib/db'
import { KontrolData, ApiResponse, FanStatus, ControlMode } from '@/lib/types'

export const dynamic = 'force-dynamic'

export async function GET() {
  try {
    // Get the most recent control record
    const result = await query<KontrolData>(
      'SELECT * FROM kontrol ORDER BY waktu DESC LIMIT 1'
    )

    if (result.length === 0) {
      return NextResponse.json<ApiResponse<null>>(
        {
          success: false,
          error: 'No control data available',
        },
        { status: 404 }
      )
    }

    return NextResponse.json<ApiResponse<KontrolData>>({
      success: true,
      data: result[0],
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

export async function POST(request: NextRequest) {
  try {
    const body = await request.json()
    const { fan, mode } = body

    // Validate fan status
    if (!fan || (fan !== 'ON' && fan !== 'OFF')) {
      return NextResponse.json<ApiResponse<null>>(
        {
          success: false,
          error: 'Invalid fan status. Must be "ON" or "OFF".',
        },
        { status: 400 }
      )
    }

    // Validate mode
    if (!mode || (mode !== 'AUTO' && mode !== 'MANUAL')) {
      return NextResponse.json<ApiResponse<null>>(
        {
          success: false,
          error: 'Invalid mode. Must be "AUTO" or "MANUAL".',
        },
        { status: 400 }
      )
    }

    // Insert new control record
    const result = await query<KontrolData>(
      'INSERT INTO kontrol (fan, mode) VALUES ($1, $2) RETURNING *',
      [fan, mode]
    )

    if (result.length === 0) {
      return NextResponse.json<ApiResponse<null>>(
        {
          success: false,
          error: 'Failed to create control record',
        },
        { status: 500 }
      )
    }

    return NextResponse.json<ApiResponse<KontrolData>>({
      success: true,
      data: result[0],
    })
  } catch (error) {
    console.error('Error updating control data:', error)
    
    return NextResponse.json<ApiResponse<null>>(
      {
        success: false,
        error: 'Failed to update control data',
      },
      { status: 500 }
    )
  }
}
