"use client"

import { useState, useEffect } from "react"
import { SensorCard } from "@/components/sensor-card"
import { AirQualityGauge } from "@/components/air-quality-gauge"
import { Card } from "@/components/ui/card"
import { Button } from "@/components/ui/button"
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs"
import { LineChart, Line, XAxis, YAxis, CartesianGrid, Tooltip, Legend, ResponsiveContainer } from "recharts"
import { RefreshCw, Activity, BarChart3, History } from "lucide-react"
import { useSensorData } from "@/hooks/use-sensor-data"
import { SensorDataWithCategories, ApiResponse } from "@/lib/types"

export default function Dashboard() {
  const { data: sensorData, loading, error } = useSensorData(5000)
  const [selectedSensor, setSelectedSensor] = useState<"co2" | "co" | "dust">("co2")
  const [chartData, setChartData] = useState<any[]>([])
  const [historicalData, setHistoricalData] = useState<SensorDataWithCategories[]>([])
  const [chartLoading, setChartLoading] = useState(false)

  const getCategoryStatus = (category: string): "good" | "moderate" | "poor" => {
    const lowerCategory = category.toLowerCase()
    if (lowerCategory.includes("hazardous") || lowerCategory.includes("poor") || lowerCategory.includes("very unhealthy") || 
        lowerCategory.includes("bahaya") || lowerCategory.includes("fatal") || lowerCategory.includes("berbahaya")) {
      return "poor"
    }
    if (lowerCategory.includes("unhealthy") || lowerCategory.includes("moderate") || lowerCategory.includes("fair") ||
        lowerCategory.includes("tidak sehat") || lowerCategory.includes("sedang")) {
      return "moderate"
    }
    return "good"
  }

  const fetchChartData = async () => {
    try {
      setChartLoading(true)
      const response = await fetch('/api/sensors/historical?hours=24')
      
      if (!response.ok) throw new Error(`HTTP error! status: ${response.status}`)
      
      const result: ApiResponse<SensorDataWithCategories[]> = await response.json()
      
      if (result.success && result.data) {
        setHistoricalData(result.data)
        const formattedData = result.data.map((item) => {
          const date = new Date(item.timestamp)
          return {
            time: date.toLocaleTimeString("id-ID", { hour: '2-digit', minute: '2-digit' }),
            fullTime: date.toLocaleString("id-ID"),
            co2: Number(item.co2),
            co: Number(item.co),
            dust: Number(item.dust),
          }
        })
        setChartData(formattedData)
      }
    } catch (err) {
      console.error('Error fetching chart data:', err)
    } finally {
      setChartLoading(false)
    }
  }

  useEffect(() => {
    fetchChartData()
  }, [])

  const sensorConfig = {
    co2: { color: "#4CAF50", name: "CO₂ (ppm)", key: "co2" },
    co: { color: "#009688", name: "CO (ppm)", key: "co" },
    dust: { color: "#FFB74D", name: "Debu (µg/m³)", key: "dust" },
  }

  if (loading) {
    return (
      <div className="min-h-screen bg-gradient-to-br from-slate-50 to-slate-100 dark:from-slate-900 dark:to-slate-800">
        <div className="container mx-auto px-4 py-8">
          <div className="text-center py-12">
            <p className="text-muted-foreground">Memuat data sensor...</p>
          </div>
        </div>
      </div>
    )
  }

  if (error) {
    return (
      <div className="min-h-screen bg-gradient-to-br from-slate-50 to-slate-100 dark:from-slate-900 dark:to-slate-800">
        <div className="container mx-auto px-4 py-8">
          <div className="text-center py-12">
            <p className="text-red-500">Error: {error.message}</p>
          </div>
        </div>
      </div>
    )
  }

  if (!sensorData) {
    return (
      <div className="min-h-screen bg-gradient-to-br from-slate-50 to-slate-100 dark:from-slate-900 dark:to-slate-800">
        <div className="container mx-auto px-4 py-8 max-w-4xl">
          <div className="mb-8">
            <h1 className="text-4xl font-bold text-foreground mb-2 flex items-center gap-3">
              <Activity className="h-8 w-8 text-primary" />
              Smart Air Monitoring System
            </h1>
            <p className="text-muted-foreground">Monitoring Kualitas Udara Real-time dengan ESP32</p>
          </div>
          
          <div className="bg-white dark:bg-slate-800 rounded-lg shadow-lg p-8 text-center space-y-6">
            <div className="text-6xl">📊</div>
            <h2 className="text-2xl font-bold">Belum Ada Data Sensor</h2>
            <p className="text-muted-foreground max-w-md mx-auto">
              Sistem siap menerima data. Silakan kirim data dari ESP32 atau gunakan endpoint test untuk mencoba.
            </p>
            
            <div className="space-y-4 text-left max-w-2xl mx-auto">
              <div className="bg-slate-50 dark:bg-slate-900 p-4 rounded-lg">
                <h3 className="font-semibold mb-2">🔧 Setup Database (Jika Belum)</h3>
                <p className="text-sm text-muted-foreground mb-2">Akses endpoint ini untuk setup database:</p>
                <code className="block bg-slate-800 text-green-400 p-2 rounded text-xs">
                  http://localhost:3000/api/setup-db
                </code>
              </div>
              
              <div className="bg-slate-50 dark:bg-slate-900 p-4 rounded-lg">
                <h3 className="font-semibold mb-2">📡 Test Kirim Data</h3>
                <p className="text-sm text-muted-foreground mb-2">Gunakan curl untuk test:</p>
                <code className="block bg-slate-800 text-green-400 p-2 rounded text-xs overflow-x-auto">
                  curl -X POST http://localhost:3000/api/esp/sensor -H "Content-Type: application/json" -d '&#123;"co2": 450, "co": 5.2, "dust": 35&#125;'
                </code>
              </div>
              
              <div className="bg-slate-50 dark:bg-slate-900 p-4 rounded-lg">
                <h3 className="font-semibold mb-2">🔌 ESP32 Setup</h3>
                <p className="text-sm text-muted-foreground">
                  Upload code ke ESP32 dan pastikan WiFi credentials sudah benar. 
                  Lihat Serial Monitor untuk debug.
                </p>
              </div>
            </div>
            
            {error && (
              <div className="mt-4 p-3 bg-yellow-50 dark:bg-yellow-900/20 border border-yellow-200 dark:border-yellow-800 rounded text-sm text-yellow-800 dark:text-yellow-200">
                {error.message}
              </div>
            )}
          </div>
        </div>
      </div>
    )
  }



  return (
    <div className="min-h-screen bg-gradient-to-br from-slate-50 to-slate-100 dark:from-slate-900 dark:to-slate-800">
      <div className="container mx-auto px-4 py-8 max-w-7xl">
        {/* Header */}
        <div className="mb-8">
          <h1 className="text-4xl font-bold text-foreground mb-2 flex items-center gap-3">
            <Activity className="h-8 w-8 text-primary" />
            Smart Air Monitoring System
          </h1>
          <p className="text-muted-foreground">Monitoring Kualitas Udara Real-time dengan ESP32</p>
        </div>

        <Tabs defaultValue="dashboard" className="space-y-6">
          <TabsList className="grid w-full grid-cols-3 max-w-md">
            <TabsTrigger value="dashboard" className="flex items-center gap-2">
              <Activity className="h-4 w-4" />
              Dashboard
            </TabsTrigger>
            <TabsTrigger value="grafik" className="flex items-center gap-2">
              <BarChart3 className="h-4 w-4" />
              Grafik
            </TabsTrigger>
            <TabsTrigger value="riwayat" className="flex items-center gap-2">
              <History className="h-4 w-4" />
              Riwayat
            </TabsTrigger>
          </TabsList>

          {/* Dashboard Tab */}
          <TabsContent value="dashboard" className="space-y-6">
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


          </TabsContent>

          {/* Grafik Tab */}
          <TabsContent value="grafik" className="space-y-6">
            <Card className="p-6 shadow-sm">
              <div className="flex flex-col sm:flex-row gap-4 items-start sm:items-center justify-between mb-6">
                <div className="flex flex-wrap gap-2">
                  {(Object.keys(sensorConfig) as Array<"co2" | "co" | "dust">).map((sensor) => (
                    <Button
                      key={sensor}
                      variant={selectedSensor === sensor ? "default" : "outline"}
                      onClick={() => setSelectedSensor(sensor)}
                      size="sm"
                    >
                      {sensorConfig[sensor].name}
                    </Button>
                  ))}
                </div>

                <Button size="sm" variant="outline" onClick={fetchChartData} disabled={chartLoading}>
                  <RefreshCw className={`h-4 w-4 mr-1 ${chartLoading ? 'animate-spin' : ''}`} />
                  Refresh
                </Button>
              </div>

              {chartLoading ? (
                <div className="h-[400px] flex items-center justify-center">
                  <p className="text-muted-foreground">Memuat data...</p>
                </div>
              ) : chartData.length === 0 ? (
                <div className="h-[400px] flex items-center justify-center">
                  <p className="text-muted-foreground">Tidak ada data tersedia</p>
                </div>
              ) : (
                <ResponsiveContainer width="100%" height={400}>
                  <LineChart data={chartData} margin={{ top: 5, right: 30, left: 0, bottom: 5 }}>
                    <CartesianGrid strokeDasharray="3 3" stroke="#e5e7eb" />
                    <XAxis dataKey="time" stroke="#9ca3af" />
                    <YAxis stroke="#9ca3af" />
                    <Tooltip
                      contentStyle={{
                        backgroundColor: "#ffffff",
                        border: "1px solid #e5e7eb",
                        borderRadius: "8px",
                      }}
                    />
                    <Legend />
                    <Line
                      type="monotone"
                      dataKey={sensorConfig[selectedSensor].key}
                      stroke={sensorConfig[selectedSensor].color}
                      name={sensorConfig[selectedSensor].name}
                      strokeWidth={2}
                      dot={false}
                    />
                  </LineChart>
                </ResponsiveContainer>
              )}


            </Card>
          </TabsContent>

          {/* Riwayat Tab */}
          <TabsContent value="riwayat" className="space-y-6">
            <Card className="p-6 shadow-sm">
              <div className="flex items-center justify-between mb-6">
                <h2 className="text-xl font-semibold">Riwayat Data Sensor (24 Jam Terakhir)</h2>
                <Button size="sm" variant="outline" onClick={fetchChartData} disabled={chartLoading}>
                  <RefreshCw className={`h-4 w-4 mr-1 ${chartLoading ? 'animate-spin' : ''}`} />
                  Refresh
                </Button>
              </div>

              <div className="overflow-x-auto">
                <table className="w-full text-sm">
                  <thead className="border-b">
                    <tr className="text-left">
                      <th className="pb-3 font-semibold">Waktu</th>
                      <th className="pb-3 font-semibold">CO₂ (ppm)</th>
                      <th className="pb-3 font-semibold">CO (ppm)</th>
                      <th className="pb-3 font-semibold">Debu (µg/m³)</th>
                      <th className="pb-3 font-semibold">Status</th>
                    </tr>
                  </thead>
                  <tbody>
                    {historicalData.length === 0 ? (
                      <tr>
                        <td colSpan={5} className="py-8 text-center text-muted-foreground">
                          Tidak ada data riwayat
                        </td>
                      </tr>
                    ) : (
                      historicalData.slice(0, 50).map((item, index) => (
                        <tr key={index} className="border-b last:border-0 hover:bg-muted/50">
                          <td className="py-3">
                            {new Date(item.timestamp).toLocaleString("id-ID")}
                          </td>
                          <td className="py-3">{Number(item.co2).toFixed(1)}</td>
                          <td className="py-3">{Number(item.co).toFixed(1)}</td>
                          <td className="py-3">{Number(item.dust).toFixed(1)}</td>
                          <td className="py-3">
                            <span className={`px-2 py-1 rounded text-xs font-medium ${
                              getCategoryStatus(item.air_quality_status) === 'good' 
                                ? 'bg-green-100 text-green-800' 
                                : getCategoryStatus(item.air_quality_status) === 'moderate'
                                ? 'bg-yellow-100 text-yellow-800'
                                : 'bg-red-100 text-red-800'
                            }`}>
                              {item.air_quality_status}
                            </span>
                          </td>
                        </tr>
                      ))
                    )}
                  </tbody>
                </table>
              </div>
            </Card>
          </TabsContent>
        </Tabs>
      </div>
    </div>
  )
}
