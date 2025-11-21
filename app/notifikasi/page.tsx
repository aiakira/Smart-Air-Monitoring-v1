"use client"

import { Header } from "@/components/header"
import { Sidebar } from "@/components/sidebar"
import { Card } from "@/components/ui/card"
import { Button } from "@/components/ui/button"
import { AlertCircle, CheckCircle, Info, AlertTriangle } from "lucide-react"
import { useNotifications } from "@/hooks/use-notifications"
import { toast } from "@/hooks/use-toast"
import { Notification } from "@/lib/types"

export default function NotifikasiPage() {
  const { notifications, loading, error, markAsRead } = useNotifications()

  const handleMarkAsRead = async (id: number) => {
    try {
      await markAsRead(id)
      toast({
        title: "Berhasil",
        description: "Notifikasi ditandai sebagai sudah dibaca",
      })
    } catch (err) {
      toast({
        title: "Error",
        description: "Gagal menandai notifikasi",
        variant: "destructive",
      })
    }
  }

  const getIcon = (type: string) => {
    switch (type) {
      case "warning":
        return AlertTriangle
      case "danger":
        return AlertCircle
      case "info":
        return Info
      case "success":
        return CheckCircle
      default:
        return Info
    }
  }

  const getTypeStyles = (type: string) => {
    switch (type) {
      case "warning":
        return {
          bg: "bg-amber-50 dark:bg-amber-950",
          border: "border-amber-200 dark:border-amber-800",
          icon: "text-amber-600 dark:text-amber-400",
        }
      case "danger":
        return {
          bg: "bg-red-50 dark:bg-red-950",
          border: "border-red-200 dark:border-red-800",
          icon: "text-red-600 dark:text-red-400",
        }
      case "info":
        return {
          bg: "bg-blue-50 dark:bg-blue-950",
          border: "border-blue-200 dark:border-blue-800",
          icon: "text-blue-600 dark:text-blue-400",
        }
      case "success":
        return {
          bg: "bg-emerald-50 dark:bg-emerald-950",
          border: "border-emerald-200 dark:border-emerald-800",
          icon: "text-emerald-600 dark:text-emerald-400",
        }
      default:
        return {
          bg: "bg-gray-50 dark:bg-gray-900",
          border: "border-gray-200 dark:border-gray-800",
          icon: "text-gray-600 dark:text-gray-400",
        }
    }
  }

  if (loading) {
    return (
      <div className="flex min-h-screen bg-background">
        <Sidebar />
        <div className="flex-1 flex flex-col">
          <Header />
          <main className="flex-1 overflow-auto p-6">
            <div className="max-w-4xl mx-auto space-y-6">
              <div className="text-center py-12">
                <p className="text-muted-foreground">Memuat notifikasi...</p>
              </div>
            </div>
          </main>
        </div>
      </div>
    )
  }

  if (error) {
    return (
      <div className="flex min-h-screen bg-background">
        <Sidebar />
        <div className="flex-1 flex flex-col">
          <Header />
          <main className="flex-1 overflow-auto p-6">
            <div className="max-w-4xl mx-auto space-y-6">
              <div className="text-center py-12">
                <p className="text-red-500">Error: {error.message}</p>
              </div>
            </div>
          </main>
        </div>
      </div>
    )
  }

  return (
    <div className="flex min-h-screen bg-background">
      <Sidebar />
      <div className="flex-1 flex flex-col">
        <Header />
        <main className="flex-1 overflow-auto p-6">
          <div className="max-w-4xl mx-auto space-y-6">
            <div className="flex items-center justify-between">
              <div>
                <h1 className="text-3xl font-bold text-foreground mb-2">Notifikasi</h1>
                <p className="text-muted-foreground">Peringatan dan informasi sistem</p>
              </div>
            </div>

            {notifications.length === 0 ? (
              <Card className="p-12 shadow-sm text-center">
                <p className="text-lg font-semibold text-muted-foreground mb-2">Tidak ada notifikasi</p>
                <p className="text-sm text-muted-foreground">Semua notifikasi sudah dibaca</p>
              </Card>
            ) : (
              <div className="space-y-4">
                {notifications.map((notif: Notification) => {
                  const Icon = getIcon(notif.type)
                  const styles = getTypeStyles(notif.type)
                  const timeString = new Date(notif.created_at).toLocaleTimeString("id-ID")
                  
                  return (
                    <Card
                      key={notif.id}
                      className={`p-6 shadow-sm border-2 ${styles.bg} ${styles.border} transition-all duration-200 ${
                        notif.is_read ? 'opacity-60' : ''
                      }`}
                    >
                      <div className="flex items-start justify-between">
                        <div className="flex gap-4 flex-1">
                          <div className={`flex-shrink-0 ${styles.icon}`}>
                            <Icon className="h-6 w-6" />
                          </div>
                          <div className="flex-1">
                            <div className="flex items-center gap-2 mb-1">
                              <p className="font-semibold text-foreground">{notif.title}</p>
                              <span className="text-xs text-muted-foreground font-mono">
                                {timeString}
                              </span>
                              {!notif.is_read && (
                                <span className="px-2 py-0.5 bg-primary text-primary-foreground text-xs rounded-full">
                                  Baru
                                </span>
                              )}
                            </div>
                            <p className="text-sm text-muted-foreground">{notif.message}</p>
                          </div>
                        </div>
                        {!notif.is_read && (
                          <Button
                            size="sm"
                            variant="ghost"
                            onClick={() => handleMarkAsRead(Number(notif.id))}
                            className="flex-shrink-0"
                          >
                            Tandai Dibaca
                          </Button>
                        )}
                      </div>
                    </Card>
                  )
                })}
              </div>
            )}
          </div>
        </main>
      </div>
    </div>
  )
}
