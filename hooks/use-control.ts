import { useState, useEffect, useCallback } from 'react'
import { KontrolData, ApiResponse, FanStatus, ControlMode } from '@/lib/types'

interface UseControlReturn {
  control: KontrolData | null
  loading: boolean
  error: Error | null
  updateControl: (fan: FanStatus, mode: ControlMode) => Promise<void>
  refetch: () => Promise<void>
}

/**
 * Custom hook to fetch and update fan control status
 */
export function useControl(): UseControlReturn {
  const [control, setControl] = useState<KontrolData | null>(null)
  const [loading, setLoading] = useState<boolean>(true)
  const [error, setError] = useState<Error | null>(null)

  const fetchControl = useCallback(async () => {
    try {
      setError(null)
      const response = await fetch('/api/control')
      
      if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`)
      }
      
      const result: ApiResponse<KontrolData> = await response.json()
      
      if (result.success && result.data) {
        setControl(result.data)
      } else {
        throw new Error(result.error || 'Failed to fetch control data')
      }
    } catch (err) {
      console.error('Error fetching control data:', err)
      setError(err instanceof Error ? err : new Error('Unknown error'))
    } finally {
      setLoading(false)
    }
  }, [])

  const updateControl = useCallback(async (fan: FanStatus, mode: ControlMode) => {
    try {
      setLoading(true)
      setError(null)
      
      const response = await fetch('/api/control', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({ fan, mode }),
      })
      
      if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`)
      }
      
      const result: ApiResponse<KontrolData> = await response.json()
      
      if (result.success && result.data) {
        setControl(result.data)
      } else {
        throw new Error(result.error || 'Failed to update control data')
      }
    } catch (err) {
      console.error('Error updating control data:', err)
      setError(err instanceof Error ? err : new Error('Unknown error'))
      throw err // Re-throw to allow caller to handle
    } finally {
      setLoading(false)
    }
  }, [])

  useEffect(() => {
    fetchControl()
  }, [fetchControl])

  return {
    control,
    loading,
    error,
    updateControl,
    refetch: fetchControl,
  }
}
