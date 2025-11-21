import { useState, useEffect, useCallback } from 'react'
import { SensorDataWithCategories, ApiResponse } from '@/lib/types'

interface UseSensorDataReturn {
  data: SensorDataWithCategories | null
  loading: boolean
  error: Error | null
  refetch: () => Promise<void>
}

/**
 * Custom hook to fetch and auto-refresh latest sensor data
 * @param refreshInterval - Auto-refresh interval in milliseconds (default: 3000ms)
 */
export function useSensorData(refreshInterval: number = 5000): UseSensorDataReturn {
  const [data, setData] = useState<SensorDataWithCategories | null>(null)
  const [loading, setLoading] = useState<boolean>(true)
  const [error, setError] = useState<Error | null>(null)

  const fetchData = useCallback(async () => {
    try {
      setError(null)
      const response = await fetch('/api/sensors/latest')
      
      if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`)
      }
      
      const result: ApiResponse<SensorDataWithCategories> = await response.json()
      
      if (result.success && result.data) {
        setData(result.data)
      } else {
        throw new Error(result.error || 'Failed to fetch sensor data')
      }
    } catch (err) {
      console.error('Error fetching sensor data:', err)
      setError(err instanceof Error ? err : new Error('Unknown error'))
    } finally {
      setLoading(false)
    }
  }, [])

  useEffect(() => {
    // Initial fetch
    fetchData()

    // Set up auto-refresh
    const interval = setInterval(() => {
      fetchData()
    }, refreshInterval)

    // Cleanup
    return () => clearInterval(interval)
  }, [fetchData, refreshInterval])

  return {
    data,
    loading,
    error,
    refetch: fetchData,
  }
}
