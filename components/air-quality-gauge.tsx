"use client"

import { Card } from "@/components/ui/card"
import { AlertCircle, CheckCircle, AlertTriangle } from "lucide-react"

interface AirQualityGaugeProps {
  co2: number
  co: number
  dust: number
}

export function AirQualityGauge({ co2, co, dust }: AirQualityGaugeProps) {
  // Determine overall status based on sensor values
  const getStatus = (): "good" | "moderate" | "poor" => {
    // CO is most dangerous
    if (co > 100) return "poor"
    if (co > 35) return "poor"
    
    // CO2 levels
    if (co2 > 2000) return "poor"
    if (co2 > 1000) return "moderate"
    
    // Dust levels
    if (dust > 150) return "poor"
    if (dust > 100) return "moderate"
    
    return "good"
  }

  const status = getStatus()
  
  const statusConfig = {
    good: {
      label: "Kualitas Udara Baik",
      description: "Kondisi udara dalam keadaan baik dan aman",
      icon: CheckCircle,
      bgColor: "bg-green-50 dark:bg-green-950",
      borderColor: "border-green-200 dark:border-green-800",
      textColor: "text-green-800 dark:text-green-200",
      iconColor: "text-green-600 dark:text-green-400"
    },
    moderate: {
      label: "Kualitas Udara Sedang",
      description: "Perhatikan ventilasi ruangan",
      icon: AlertTriangle,
      bgColor: "bg-yellow-50 dark:bg-yellow-950",
      borderColor: "border-yellow-200 dark:border-yellow-800",
      textColor: "text-yellow-800 dark:text-yellow-200",
      iconColor: "text-yellow-600 dark:text-yellow-400"
    },
    poor: {
      label: "Kualitas Udara Buruk",
      description: "Segera tingkatkan ventilasi atau evakuasi!",
      icon: AlertCircle,
      bgColor: "bg-red-50 dark:bg-red-950",
      borderColor: "border-red-200 dark:border-red-800",
      textColor: "text-red-800 dark:text-red-200",
      iconColor: "text-red-600 dark:text-red-400"
    }
  }

  const config = statusConfig[status]
  const Icon = config.icon

  return (
    <Card className={`p-6 border-2 ${config.bgColor} ${config.borderColor}`}>
      <div className="flex items-center gap-4">
        <div className={`p-3 rounded-full ${config.bgColor}`}>
          <Icon className={`h-8 w-8 ${config.iconColor}`} />
        </div>
        <div className="flex-1">
          <h2 className={`text-2xl font-bold ${config.textColor}`}>
            {config.label}
          </h2>
          <p className={`text-sm ${config.textColor} opacity-80`}>
            {config.description}
          </p>
        </div>
        <div className={`text-right ${config.textColor}`}>
          <div className="text-sm opacity-70">Status</div>
          <div className="text-lg font-semibold uppercase">{status}</div>
        </div>
      </div>
    </Card>
  )
}
