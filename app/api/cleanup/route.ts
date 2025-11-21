import { NextResponse } from 'next/server'
import { query } from '@/lib/db'

export const dynamic = 'force-dynamic'

/**
 * Cleanup old data from database
 * Run this periodically to keep database size manageable
 */
export async function POST() {
  try {
    // Hapus data sensor lebih dari 30 hari
    const sensorResult = await query(`
      DELETE FROM sensor_data 
      WHERE timestamp < NOW() - INTERVAL '30 days'
      RETURNING id
    `)

    // Hapus notifikasi yang sudah dibaca lebih dari 7 hari
    const notifResult = await query(`
      DELETE FROM notifications 
      WHERE is_read = true 
      AND created_at < NOW() - INTERVAL '7 days'
      RETURNING id
    `)

    // Hapus kontrol lama, simpan hanya 100 record terakhir
    await query(`
      DELETE FROM kontrol 
      WHERE id NOT IN (
        SELECT id FROM kontrol 
        ORDER BY waktu DESC 
        LIMIT 100
      )
    `)

    return NextResponse.json({
      success: true,
      message: 'Cleanup completed',
      deleted: {
        sensor_data: sensorResult.length,
        notifications: notifResult.length,
      },
    })
  } catch (error: any) {
    console.error('Cleanup error:', error)
    
    return NextResponse.json(
      {
        success: false,
        error: error.message || 'Failed to cleanup data',
      },
      { status: 500 }
    )
  }
}
