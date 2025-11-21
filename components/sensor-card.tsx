"use client"

interface SensorCardProps {
  label: string
  value: number
  unit: string
  icon: string
  status: "good" | "moderate" | "poor"
}

export function SensorCard({ label, value, unit, icon, status }: SensorCardProps) {
  const statusColors = {
    good: "status-good",
    moderate: "status-moderate",
    poor: "status-poor",
  }

  return (
    <div className={`rounded-xl p-6 text-center shadow-sm transition-all duration-300 ${statusColors[status]}`}>
      <div className="text-4xl mb-2">{icon}</div>
      <p className="text-sm font-medium opacity-75 mb-2">{label}</p>
      <div className="text-3xl font-bold">
        {value}
        <span className="text-lg ml-1">{unit}</span>
      </div>
    </div>
  )
}
