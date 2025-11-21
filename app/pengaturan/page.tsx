"use client"

import { useState } from "react"
import { Header } from "@/components/header"
import { Sidebar } from "@/components/sidebar"
import { Card } from "@/components/ui/card"
import { Button } from "@/components/ui/button"
import { Save, CheckCircle } from "lucide-react"

export default function PengaturanPage() {
  const [settings, setSettings] = useState({
    co2Threshold: 700,
    coThreshold: 2.0,
    dustThreshold: 75,
    cloudService: "firebase",
    autoMode: true,
  })

  const [testResult, setTestResult] = useState<"idle" | "testing" | "success" | "error">("idle")

  const handleInputChange = (key: string, value: any) => {
    setSettings((prev) => ({ ...prev, [key]: value }))
  }

  const handleSave = () => {
    setTestResult("success")
    setTimeout(() => setTestResult("idle"), 3000)
  }

  const handleTestConnection = async () => {
    setTestResult("testing")
    setTimeout(() => {
      setTestResult("success")
      setTimeout(() => setTestResult("idle"), 3000)
    }, 1500)
  }

  return (
    <div className="flex min-h-screen bg-background">
      <Sidebar />
      <div className="flex-1 flex flex-col">
        <Header />
        <main className="flex-1 overflow-auto p-6">
          <div className="max-w-4xl mx-auto space-y-6">
            <div>
              <h1 className="text-3xl font-bold text-foreground mb-2">Pengaturan</h1>
              <p className="text-muted-foreground">Konfigurasi sistem monitoring dan ambang batas sensor</p>
            </div>

            {/* Threshold Settings */}
            <Card className="p-6 shadow-sm">
              <h2 className="text-xl font-semibold mb-6">Ambang Batas Sensor</h2>
              <div className="space-y-6">
                <div>
                  <label className="block text-sm font-medium mb-2">CO₂ (ppm)</label>
                  <input
                    type="number"
                    value={settings.co2Threshold}
                    onChange={(e) => handleInputChange("co2Threshold", Number(e.target.value))}
                    className="w-full px-4 py-2 border border-border rounded-lg bg-card text-foreground focus:outline-none focus:ring-2 focus:ring-primary"
                  />
                  <p className="text-xs text-muted-foreground mt-1">Ambang batas normal: 700 ppm</p>
                </div>

                <div>
                  <label className="block text-sm font-medium mb-2">CO (ppm)</label>
                  <input
                    type="number"
                    step="0.1"
                    value={settings.coThreshold}
                    onChange={(e) => handleInputChange("coThreshold", Number(e.target.value))}
                    className="w-full px-4 py-2 border border-border rounded-lg bg-card text-foreground focus:outline-none focus:ring-2 focus:ring-primary"
                  />
                  <p className="text-xs text-muted-foreground mt-1">Ambang batas normal: 2.0 ppm</p>
                </div>

                <div>
                  <label className="block text-sm font-medium mb-2">Debu (µg/m³)</label>
                  <input
                    type="number"
                    value={settings.dustThreshold}
                    onChange={(e) => handleInputChange("dustThreshold", Number(e.target.value))}
                    className="w-full px-4 py-2 border border-border rounded-lg bg-card text-foreground focus:outline-none focus:ring-2 focus:ring-primary"
                  />
                  <p className="text-xs text-muted-foreground mt-1">Ambang batas normal: 75 µg/m³</p>
                </div>

                <Button onClick={handleSave} className="w-full">
                  <Save className="h-4 w-4 mr-2" />
                  Simpan Ambang Batas
                </Button>
              </div>
            </Card>

            {/* Mode Operation */}
            <Card className="p-6 shadow-sm">
              <h2 className="text-xl font-semibold mb-6">Mode Operasi</h2>
              <div className="space-y-4">
                <div className="flex items-center justify-between">
                  <div>
                    <p className="font-medium">Mode Otomatis</p>
                    <p className="text-sm text-muted-foreground">
                      Fan akan menyala otomatis saat kualitas udara menurun
                    </p>
                  </div>
                  <input
                    type="checkbox"
                    checked={settings.autoMode}
                    onChange={(e) => handleInputChange("autoMode", e.target.checked)}
                    className="h-5 w-5 rounded border-border cursor-pointer"
                  />
                </div>
              </div>
            </Card>

            {/* Cloud Connection */}
            <Card className="p-6 shadow-sm">
              <h2 className="text-xl font-semibold mb-6">Koneksi Cloud</h2>
              <div className="space-y-4">
                <div>
                  <label className="block text-sm font-medium mb-2">Layanan Cloud</label>
                  <select
                    value={settings.cloudService}
                    onChange={(e) => handleInputChange("cloudService", e.target.value)}
                    className="w-full px-4 py-2 border border-border rounded-lg bg-card text-foreground"
                  >
                    <option value="firebase">Firebase</option>
                    <option value="mqtt">MQTT</option>
                    <option value="aws">AWS IoT</option>
                  </select>
                </div>

                <Button
                  onClick={handleTestConnection}
                  variant="outline"
                  className="w-full bg-transparent"
                  disabled={testResult === "testing"}
                >
                  {testResult === "testing" ? (
                    <>Menguji koneksi...</>
                  ) : testResult === "success" ? (
                    <>
                      <CheckCircle className="h-4 w-4 mr-2 text-emerald-600" />
                      Koneksi Berhasil
                    </>
                  ) : (
                    <>Tes Koneksi</>
                  )}
                </Button>
              </div>
            </Card>

            {/* About */}
            <Card className="p-6 shadow-sm bg-muted">
              <h2 className="text-xl font-semibold mb-4">Tentang Aplikasi</h2>
              <div className="space-y-2 text-sm">
                <p>
                  <span className="font-medium">Smart Air Monitor</span> v1.0
                </p>
                <p className="text-muted-foreground">Sistem monitoring kualitas udara dalam ruangan real-time</p>
                <p className="text-muted-foreground text-xs mt-4">© 2025 Smart Air Monitor. Semua hak dilindungi.</p>
              </div>
            </Card>
          </div>
        </main>
      </div>
    </div>
  )
}
