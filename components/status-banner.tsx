"use client"

interface StatusBannerProps {
  status: "good" | "moderate" | "poor"
  label: string
}

export function StatusBanner({ status, label }: StatusBannerProps) {
  const statusConfig = {
    good: {
      bg: "bg-emerald-50 dark:bg-emerald-950",
      border: "border-emerald-200 dark:border-emerald-800",
      text: "text-emerald-900 dark:text-emerald-100",
      icon: "🟢",
    },
    moderate: {
      bg: "bg-amber-50 dark:bg-amber-950",
      border: "border-amber-200 dark:border-amber-800",
      text: "text-amber-900 dark:text-amber-100",
      icon: "🟡",
    },
    poor: {
      bg: "bg-red-50 dark:bg-red-950",
      border: "border-red-200 dark:border-red-800",
      text: "text-red-900 dark:text-red-100",
      icon: "🔴",
    },
  }

  const config = statusConfig[status]

  return (
    <div className={`rounded-xl border-2 ${config.border} ${config.bg} p-8 text-center`}>
      <div className="text-6xl mb-3">{config.icon}</div>
      <h2 className={`text-3xl font-bold ${config.text} mb-2`}>Kualitas Udara: {label}</h2>
      <p className={`${config.text} opacity-75`}>Status terkini sistem monitoring</p>
    </div>
  )
}
