import { NextResponse } from 'next/server'
import { query, testConnection } from '@/lib/db'

export const dynamic = 'force-dynamic'

export async function GET() {
  try {
    // Test basic connection
    const isConnected = await testConnection()
    
    if (!isConnected) {
      return NextResponse.json({
        success: false,
        error: 'Database connection failed',
      }, { status: 500 })
    }

    // Test query sensor_data table
    const sensorCount = await query('SELECT COUNT(*) as count FROM sensor_data')
    const kontrolCount = await query('SELECT COUNT(*) as count FROM kontrol')
    const notifCount = await query('SELECT COUNT(*) as count FROM notifications')

    return NextResponse.json({
      success: true,
      message: 'Database connection successful',
      tables: {
        sensor_data: sensorCount[0]?.count || 0,
        kontrol: kontrolCount[0]?.count || 0,
        notifications: notifCount[0]?.count || 0,
      },
    })
  } catch (error: any) {
    console.error('Database test error:', error)
    
    return NextResponse.json({
      success: false,
      error: error.message || 'Unknown error',
      details: process.env.NODE_ENV === 'development' ? error.stack : undefined,
    }, { status: 500 })
  }
}
