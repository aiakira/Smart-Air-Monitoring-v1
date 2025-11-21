"use client"

import { Header } from "@/components/header"
import { Sidebar } from "@/components/sidebar"
import { SensorCard } from "@/components/sensor-card"
import { AirQualityGauge } from "@/components/air-quality-gauge"
import { FanControl } from "@/components/fan-control"
import { Card } from "@/components/ui/card"
import { Zap } from "lucide-react"
import { useSensorData } from "@/hooks/use-sensor-data"

export default function Dashboard() {
  const { data: sensorData, loading, error } = useSensorData(5000)

  const getCategoryStatus = (category: string): "good" | "moderate" | "poor" => {
    const lowerCategory = category.toLowerCase()
    if (lowerCategory.includes("hazardous") || lowerCategory.includes("poor") || lowerCategory.includes("very unhealthy")) {
      return "poor"
    }
    if (lowerCategory.includes("unhealthy") || lowerCategory.includes("moderate") || lowerCategory.includes("fair")) {
      return "moderate"
    }
    return "good"
  }

  if (loading) {
    return (
      <div className="flex min-h-screen bg-background">
        <Sidebar />
        <div className="flex-1 flex flex-col">
          <Header />
          <main className="flex-1 overflow-auto p-6">
            <div className="max-w-7xl mx-auto space-y-6">
              <div className="text-center py-12">
                <p className="text-muted-foreground">Memuat data sensor...</p>
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
            <div className="max-w-7xl mx-auto space-y-6">
              <div className="text-center py-12">
                <p className="text-red-500">Error: {error.message}</p>
              </div>
            </div>
          </main>
        </div>
      </div>
    )
  }

  if (!sensorData) {
    return (
      <div className="flex min-h-screen bg-background">
        <Sidebar />
        <div className="flex-1 flex flex-col">
          <Header />
          <main className="flex-1 overflow-auto p-6">
            <div className="max-w-7xl mx-auto space-y-6">
              <div className="text-center py-12">
                <p className="text-muted-foreground">Tidak ada data sensor tersedia</p>
              </div>
            </div>
          </main>
        </div>
      </div>
    )
  }

  const lastUpdateTime = new Date(sensorData.timestamp).toLocaleTimeString("id-ID")

  return (
    <div className="flex min-h-screen bg-background">
      <Sidebar />
      <div className="flex-1 flex flex-col">
        <Header />
        <main className="flex-1 overflow-auto p-6">
          <div className="max-w-7xl mx-auto space-y-6">
            {/* Status Banner */}
            <AirQualityGauge co2={Number(sensorData.co2)} co={Number(sensorData.co)} dust={Number(sensorData.dust)} />

            {/* Sensor Data Grid */}
            <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
              <SensorCard
                label="CO₂"
                value={Math.round(Number(sensorData.co2))}
                unit="ppm"
                icon="🌫️"
                status={getCategoryStatus(sensorData.co2_category)}
              />
              <SensorCard
                label="CO"
                value={Number(Number(sensorData.co).toFixed(1))}
                unit="ppm"
                icon="💨"
                status={getCategoryStatus(sensorData.co_category)}
              />
              <SensorCard
                label="Debu"
                value={Math.round(Number(sensorData.dust))}
                unit="µg/m³"
                icon="🏭"
                status={getCategoryStatus(sensorData.dust_category)}
              />
            </div>

            {/* Control Section */}
            <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
              <div className="md:col-span-2">
                <FanControl />
              </div>

              <Card className="p-6 shadow-sm">
                <div className="flex items-start gap-3">
                  <Zap className="h-5 w-5 text-primary mt-1 flex-shrink-0" />
                  <div>
                    <h3 className="font-semibold mb-1">Status Kualitas Udara</h3>
                    <p className="text-sm text-muted-foreground">
                      {sensorData.air_quality_status}
                    </p>
                    <p className="text-xs text-muted-foreground mt-3">
                      Terakhir diupdate: {lastUpdateTime}
                    </p>
                  </div>
                </div>
              </Card>
            </div>
          </div>
        </main>
      </div>
    </div>
  )
}
