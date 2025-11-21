"use client"

import { useState, useMemo } from "react"
import { Header } from "@/components/header"
import { Sidebar } from "@/components/sidebar"
import { Card } from "@/components/ui/card"
import { Button } from "@/components/ui/button"
import { Download, Trash2, Filter } from "lucide-react"

const generateHistoryData = () => {
  const data = []
  for (let i = 0; i < 30; i++) {
    const date = new Date()
    date.setDate(date.getDate() - i)
    data.push({
      id: i,
      tanggal: date.toLocaleDateString("id-ID"),
      waktu: `${date.getHours().toString().padStart(2, "0")}:${date.getMinutes().toString().padStart(2, "0")}`,
      co2: Math.floor(Math.random() * 600) + 300,
      co: Number((Math.random() * 4 + 0.5).toFixed(1)),
      dust: Math.floor(Math.random() * 100) + 30,
      status: Math.random() > 0.6 ? "buruk" : Math.random() > 0.4 ? "sedang" : "baik",
    })
  }
  return data
}

export default function RiwayatPage() {
  const [data] = useState(generateHistoryData())
  const [filterStatus, setFilterStatus] = useState<"semua" | "baik" | "sedang" | "buruk">("semua")
  const [sortOrder, setSortOrder] = useState<"terbaru" | "terlama">("terbaru")

  const filteredData = useMemo(() => {
    let result = data
    if (filterStatus !== "semua") {
      result = result.filter((item) => item.status === filterStatus)
    }
    if (sortOrder === "terlama") {
      result = [...result].reverse()
    }
    return result
  }, [data, filterStatus, sortOrder])

  const getStatusColor = (status: string) => {
    switch (status) {
      case "baik":
        return "bg-emerald-100 text-emerald-900 dark:bg-emerald-900 dark:text-emerald-100"
      case "sedang":
        return "bg-amber-100 text-amber-900 dark:bg-amber-900 dark:text-amber-100"
      case "buruk":
        return "bg-red-100 text-red-900 dark:bg-red-900 dark:text-red-100"
      default:
        return "bg-gray-100 text-gray-900"
    }
  }

  const handleExportCSV = () => {
    const csv = [
      ["Tanggal", "Waktu", "CO₂ (ppm)", "CO (ppm)", "Debu (µg/m³)", "Status"].join(","),
      ...filteredData.map((row) => [row.tanggal, row.waktu, row.co2, row.co, row.dust, row.status].join(",")),
    ].join("\n")

    const blob = new Blob([csv], { type: "text/csv" })
    const url = window.URL.createObjectURL(blob)
    const a = document.createElement("a")
    a.href = url
    a.download = `air-quality-history-${new Date().toISOString()}.csv`
    a.click()
  }

  return (
    <div className="flex min-h-screen bg-background">
      <Sidebar />
      <div className="flex-1 flex flex-col">
        <Header />
        <main className="flex-1 overflow-auto p-6">
          <div className="max-w-6xl mx-auto space-y-6">
            <div>
              <h1 className="text-3xl font-bold text-foreground mb-2">Riwayat Data</h1>
              <p className="text-muted-foreground">Catatan data sensor dari waktu sebelumnya</p>
            </div>

            {/* Filters */}
            <Card className="p-6 shadow-sm">
              <div className="flex flex-col sm:flex-row gap-4 items-start sm:items-center justify-between">
                <div className="flex flex-wrap gap-2">
                  <Button variant="outline" size="sm" className="flex items-center gap-2 bg-transparent">
                    <Filter className="h-4 w-4" />
                    Status:
                  </Button>
                  {["semua", "baik", "sedang", "buruk"].map((status) => (
                    <Button
                      key={status}
                      variant={filterStatus === status ? "default" : "outline"}
                      size="sm"
                      onClick={() => setFilterStatus(status as any)}
                    >
                      {status.charAt(0).toUpperCase() + status.slice(1)}
                    </Button>
                  ))}
                </div>

                <div className="flex gap-2">
                  <select
                    value={sortOrder}
                    onChange={(e) => setSortOrder(e.target.value as any)}
                    className="px-3 py-2 border border-border rounded-lg text-sm bg-card text-foreground"
                  >
                    <option value="terbaru">Terbaru</option>
                    <option value="terlama">Terlama</option>
                  </select>
                  <Button
                    size="sm"
                    variant="outline"
                    onClick={handleExportCSV}
                    className="flex items-center gap-2 bg-transparent"
                  >
                    <Download className="h-4 w-4" />
                    Export CSV
                  </Button>
                </div>
              </div>
            </Card>

            {/* Table */}
            <Card className="shadow-sm overflow-hidden">
              <div className="overflow-x-auto">
                <table className="w-full text-sm">
                  <thead className="bg-muted border-b border-border">
                    <tr>
                      <th className="px-6 py-3 text-left font-semibold text-muted-foreground">Tanggal/Waktu</th>
                      <th className="px-6 py-3 text-left font-semibold text-muted-foreground">CO₂ (ppm)</th>
                      <th className="px-6 py-3 text-left font-semibold text-muted-foreground">CO (ppm)</th>
                      <th className="px-6 py-3 text-left font-semibold text-muted-foreground">Debu (µg/m³)</th>
                      <th className="px-6 py-3 text-left font-semibold text-muted-foreground">Status Udara</th>
                    </tr>
                  </thead>
                  <tbody className="divide-y divide-border">
                    {filteredData.map((row) => (
                      <tr key={row.id} className="hover:bg-muted/50 transition-colors">
                        <td className="px-6 py-3 text-sm">
                          {row.tanggal} <span className="text-muted-foreground">{row.waktu}</span>
                        </td>
                        <td className="px-6 py-3 font-medium">{row.co2}</td>
                        <td className="px-6 py-3 font-medium">{row.co}</td>
                        <td className="px-6 py-3 font-medium">{row.dust}</td>
                        <td className="px-6 py-3">
                          <span
                            className={`px-3 py-1 rounded-full text-xs font-semibold ${getStatusColor(row.status)}`}
                          >
                            {row.status.charAt(0).toUpperCase() + row.status.slice(1)}
                          </span>
                        </td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
            </Card>

            {/* Action */}
            <Card className="p-4 bg-destructive/10 border border-destructive/20">
              <div className="flex items-center justify-between">
                <p className="text-sm text-foreground">Total: {filteredData.length} entri data</p>
                <Button
                  size="sm"
                  variant="ghost"
                  className="text-destructive hover:bg-destructive/10"
                  onClick={() => alert("Data akan dihapus (ini demo)")}
                >
                  <Trash2 className="h-4 w-4 mr-2" />
                  Hapus Semua
                </Button>
              </div>
            </Card>
          </div>
        </main>
      </div>
    </div>
  )
}
