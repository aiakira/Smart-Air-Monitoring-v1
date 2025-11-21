import { useState, useEffect, useCallback } from 'react'
import { Notification, ApiResponse } from '@/lib/types'

interface UseNotificationsReturn {
  notifications: Notification[]
  loading: boolean
  error: Error | null
  markAsRead: (id: number) => Promise<void>
  refetch: () => Promise<void>
}

/**
 * Custom hook to fetch and manage notifications
 * @param unreadOnly - If true, only fetch unread notifications
 */
export function useNotifications(unreadOnly: boolean = false): UseNotificationsReturn {
  const [notifications, setNotifications] = useState<Notification[]>([])
  const [loading, setLoading] = useState<boolean>(true)
  const [error, setError] = useState<Error | null>(null)

  const fetchNotifications = useCallback(async () => {
    try {
      setError(null)
      const url = unreadOnly ? '/api/notifications?unread=true' : '/api/notifications'
      const response = await fetch(url)
      
      if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`)
      }
      
      const result: ApiResponse<Notification[]> = await response.json()
      
      if (result.success && result.data) {
        setNotifications(result.data)
      } else {
        throw new Error(result.error || 'Failed to fetch notifications')
      }
    } catch (err) {
      console.error('Error fetching notifications:', err)
      setError(err instanceof Error ? err : new Error('Unknown error'))
    } finally {
      setLoading(false)
    }
  }, [unreadOnly])

  const markAsRead = useCallback(async (id: number) => {
    try {
      setError(null)
      
      const response = await fetch('/api/notifications', {
        method: 'PATCH',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({ id, is_read: true }),
      })
      
      if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`)
      }
      
      const result: ApiResponse<Notification> = await response.json()
      
      if (result.success && result.data) {
        // Update local state
        setNotifications((prev) =>
          prev.map((notif) =>
            notif.id === id ? { ...notif, is_read: true } : notif
          )
        )
      } else {
        throw new Error(result.error || 'Failed to mark notification as read')
      }
    } catch (err) {
      console.error('Error marking notification as read:', err)
      setError(err instanceof Error ? err : new Error('Unknown error'))
      throw err // Re-throw to allow caller to handle
    }
  }, [])

  useEffect(() => {
    fetchNotifications()
  }, [fetchNotifications])

  return {
    notifications,
    loading,
    error,
    markAsRead,
    refetch: fetchNotifications,
  }
}
