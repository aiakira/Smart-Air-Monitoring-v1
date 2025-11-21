/**
 * Database type definitions matching PostgreSQL schema
 */

// Sensor Data Types
export interface SensorData {
  id: string | number  // BIGINT from database
  co2: string | number  // NUMERIC from database
  co: string | number   // NUMERIC from database
  dust: string | number // NUMERIC from database
  timestamp: string | Date
}

export interface SensorDataWithCategories {
  id: string | number
  co2: string | number
  co: string | number
  dust: string | number
  timestamp: string | Date
  co2_category: string
  co_category: string
  dust_category: string
  air_quality_status: string
}

// Control System Types
export type FanStatus = 'ON' | 'OFF'
export type ControlMode = 'AUTO' | 'MANUAL'

export interface KontrolData {
  id: string | number  // BIGINT from database
  fan: FanStatus
  mode: ControlMode
  waktu: string | Date
}

// Notification Types
export type NotificationType = 'warning' | 'danger' | 'info' | 'success'

export interface Notification {
  id: string | number  // BIGINT from database
  title: string
  message: string
  type: NotificationType
  is_read: boolean
  created_at: string | Date
}

// API Response Types
export interface ApiResponse<T> {
  success: boolean
  data?: T
  error?: string
}

export interface ApiError {
  success: false
  error: string
  details?: string
}

// Category Types (from database functions)
export type CO2Category = 'Baik' | 'Masih Aman' | 'Tidak Sehat' | 'Bahaya' | 'Sangat Berbahaya'
export type COCategory = 'Aman' | 'Tidak Sehat' | 'Berbahaya' | 'Sangat Berbahaya' | 'Fatal'
export type DustCategory = 'Baik' | 'Sedang' | 'Tidak Sehat' | 'Sangat Tidak Sehat'
export type AirQualityStatus = 
  | 'BAIK' 
  | 'CUKUP BAIK' 
  | 'SEDANG' 
  | 'TIDAK SEHAT' 
  | 'BAHAYA' 
  | 'SANGAT BERBAHAYA' 
  | 'FATAL - CO Sangat Tinggi'
