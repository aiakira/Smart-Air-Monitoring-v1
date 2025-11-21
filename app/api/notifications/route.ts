import { NextRequest, NextResponse } from 'next/server'
import { query } from '@/lib/db'
import { Notification, ApiResponse } from '@/lib/types'

export const dynamic = 'force-dynamic'

export async function GET(request: NextRequest) {
  try {
    // Get unread parameter from query string
    const searchParams = request.nextUrl.searchParams
    const unreadOnly = searchParams.get('unread') === 'true'

    let result: Notification[]

    if (unreadOnly) {
      // Get only unread notifications
      result = await query<Notification>(
        'SELECT * FROM notifications WHERE is_read = false ORDER BY created_at DESC'
      )
    } else {
      // Get all notifications
      result = await query<Notification>(
        'SELECT * FROM notifications ORDER BY created_at DESC'
      )
    }

    return NextResponse.json<ApiResponse<Notification[]>>({
      success: true,
      data: result,
    })
  } catch (error) {
    console.error('Error fetching notifications:', error)
    
    return NextResponse.json<ApiResponse<null>>(
      {
        success: false,
        error: 'Failed to fetch notifications',
      },
      { status: 500 }
    )
  }
}

export async function PATCH(request: NextRequest) {
  try {
    const body = await request.json()
    const { id, is_read } = body

    // Validate id
    if (!id || typeof id !== 'number') {
      return NextResponse.json<ApiResponse<null>>(
        {
          success: false,
          error: 'Invalid notification id',
        },
        { status: 400 }
      )
    }

    // Validate is_read
    if (typeof is_read !== 'boolean') {
      return NextResponse.json<ApiResponse<null>>(
        {
          success: false,
          error: 'Invalid is_read value. Must be boolean.',
        },
        { status: 400 }
      )
    }

    // Update notification
    const result = await query<Notification>(
      'UPDATE notifications SET is_read = $1 WHERE id = $2 RETURNING *',
      [is_read, id]
    )

    if (result.length === 0) {
      return NextResponse.json<ApiResponse<null>>(
        {
          success: false,
          error: 'Notification not found',
        },
        { status: 404 }
      )
    }

    return NextResponse.json<ApiResponse<Notification>>({
      success: true,
      data: result[0],
    })
  } catch (error) {
    console.error('Error updating notification:', error)
    
    return NextResponse.json<ApiResponse<null>>(
      {
        success: false,
        error: 'Failed to update notification',
      },
      { status: 500 }
    )
  }
}
