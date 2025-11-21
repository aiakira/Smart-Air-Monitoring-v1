"use client"

import { StatusBanner } from "./status-banner" // Fixed import path to match actual filename

interface AirQualityGaugeProps {
  co2: number
  co: number
  dust: number
}

export function AirQualityGauge({ co2, co, dust }: AirQualityGaugeProps) {
  // Determine overall status based on sensor values
  const getStatus = () => {
    if (co2 > 1000 || co > 5 || dust > 100) return "poor"
    if (co2 > 700 || co > 2 || dust > 75) return "moderate"
    return "good"
  }

  const status = getStatus()
  const statusLabel = {
    good: "Baik",
    moderate: "Sedang",
    poor: "Buruk",
  }[status]

  return (
    <div className="space-y-4">
      <StatusBanner status={status} label={statusLabel} />
    </div>
  )
}
