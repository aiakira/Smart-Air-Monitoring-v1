"use client"

import { useState } from "react"
import { Card } from "@/components/ui/card"
import { Button } from "@/components/ui/button"
import { Zap, Power } from "lucide-react"
import { useControl } from "@/hooks/use-control"
import { toast } from "@/hooks/use-toast"

export function FanControl() {
  const { control, loading, error, updateControl } = useControl()
  const [isUpdating, setIsUpdating] = useState(false)

  const isActive = control?.fan === 'ON'
  const mode = control?.mode === 'AUTO' ? 'auto' : 'manual'

  const handleToggle = async () => {
    if (!control) return
    
    try {
      setIsUpdating(true)
      const newFanStatus = control.fan === 'ON' ? 'OFF' : 'ON'
      await updateControl(newFanStatus, control.mode)
      
      toast({
        title: "Berhasil",
        description: `Fan ${newFanStatus === 'ON' ? 'dinyalakan' : 'dimatikan'}`,
      })
    } catch (err) {
      toast({
        title: "Error",
        description: "Gagal mengubah status fan",
        variant: "destructive",
      })
    } finally {
      setIsUpdating(false)
    }
  }

  const handleModeChange = async (newMode: 'AUTO' | 'MANUAL') => {
    if (!control) return
    
    try {
      setIsUpdating(true)
      await updateControl(control.fan, newMode)
      
      toast({
        title: "Berhasil",
        description: `Mode diubah ke ${newMode}`,
      })
    } catch (err) {
      toast({
        title: "Error",
        description: "Gagal mengubah mode",
        variant: "destructive",
      })
    } finally {
      setIsUpdating(false)
    }
  }

  if (loading) {
    return (
      <Card className="p-6 shadow-sm">
        <p className="text-center text-muted-foreground">Memuat kontrol...</p>
      </Card>
    )
  }

  if (error || !control) {
    return (
      <Card className="p-6 shadow-sm">
        <p className="text-center text-red-500">Error memuat kontrol</p>
      </Card>
    )
  }

  return (
    <Card className="p-6 shadow-sm">
      <div className="flex items-center justify-between mb-6">
        <div className="flex items-center gap-3">
          <Power className="h-6 w-6 text-primary" />
          <h3 className="font-semibold">Exhaust Fan</h3>
        </div>
        <div
          className={`px-3 py-1 rounded-full text-sm font-medium ${
            isActive
              ? "bg-emerald-100 text-emerald-900 dark:bg-emerald-900 dark:text-emerald-100"
              : "bg-muted text-muted-foreground"
          }`}
        >
          {isActive ? "🟢 Aktif" : "⚪ Mati"}
        </div>
      </div>

      <Button
        onClick={handleToggle}
        disabled={isUpdating}
        className={`w-full mb-6 transition-all duration-300 font-bold text-base py-6 ${
          isActive ? "bg-emerald-500 hover:bg-emerald-600 text-white" : "bg-red-500 hover:bg-red-600 text-white"
        }`}
        size="lg"
      >
        {isUpdating ? (
          "Memproses..."
        ) : isActive ? (
          <>
            <Power className="h-5 w-5 mr-2" />
            Matikan Fan
          </>
        ) : (
          <>
            <Power className="h-5 w-5 mr-2" />
            Nyalakan Fan
          </>
        )}
      </Button>

      <div className="space-y-3">
        <p className="text-sm font-medium text-foreground/70">Mode Operasi</p>
        <div className="flex gap-2">
          <Button
            variant={mode === "auto" ? "default" : "outline"}
            className="flex-1 text-sm"
            onClick={() => handleModeChange('AUTO')}
            disabled={isUpdating}
          >
            <Zap className="h-4 w-4 mr-1" />
            Auto
          </Button>
          <Button
            variant={mode === "manual" ? "default" : "outline"}
            className="flex-1 text-sm"
            onClick={() => handleModeChange('MANUAL')}
            disabled={isUpdating}
          >
            Manual
          </Button>
        </div>
        <p className="text-xs text-muted-foreground mt-2">
          {mode === "auto" ? "Fan akan menyala otomatis saat kualitas udara menurun" : "Kontrol fan secara manual"}
        </p>
      </div>
    </Card>
  )
}
