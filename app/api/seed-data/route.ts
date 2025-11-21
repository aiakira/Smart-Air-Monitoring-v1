import { NextResponse } from 'next/server'
import { query } from '@/lib/db'

export const dynamic = 'force-dynamic'

/**
 * Seed initial data to database
 */
export async function POST() {
  try {
    // Insert sample sensor data
    await query(
      `INSERT INTO sensor_data (co2, co, dust) VALUES
       (450, 5, 20),
       (480, 6, 22),
       (520, 7, 25),
       (490, 5.5, 21),
       (510, 6.5, 23)`
    )

    // Insert initial control data
    await query(
      `INSERT INTO kontrol (fan, mode) VALUES ('OFF', 'AUTO')`
    )

    // Insert sample notifications
    await query(
      `INSERT INTO notifications (title, message, type, is_read) VALUES
       ('Selamat Datang', 'Sistem monitoring udara aktif', 'info', false),
       ('Kualitas Udara Baik', 'Semua parameter dalam batas normal', 'success', false)`
    )

    return NextResponse.json({
      success: true,
      message: 'Sample data inserted successfully',
    })
  } catch (error: any) {
    console.error('Seed data error:', error)
    
    return NextResponse.json({
      success: false,
      error: error.message || 'Failed to seed data',
    }, { status: 500 })
  }
}
