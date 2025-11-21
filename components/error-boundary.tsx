'use client'

import { Component, ReactNode } from 'react'
import { Card } from './ui/card'
import { Button } from './ui/button'
import { AlertCircle } from 'lucide-react'

interface Props {
  children: ReactNode
  fallback?: ReactNode
}

interface State {
  hasError: boolean
  error?: Error
}

export class ErrorBoundary extends Component<Props, State> {
  constructor(props: Props) {
    super(props)
    this.state = { hasError: false }
  }

  static getDerivedStateFromError(error: Error): State {
    return { hasError: true, error }
  }

  componentDidCatch(error: Error, errorInfo: any) {
    console.error('Error caught by boundary:', error, errorInfo)
  }

  render() {
    if (this.state.hasError) {
      return (
        this.props.fallback || (
          <div className="flex min-h-screen items-center justify-center p-6 bg-background">
            <Card className="p-8 max-w-md w-full text-center shadow-lg">
              <AlertCircle className="h-12 w-12 text-red-500 mx-auto mb-4" />
              <h2 className="text-2xl font-bold text-foreground mb-2">
                Terjadi Kesalahan
              </h2>
              <p className="text-muted-foreground mb-6">
                {this.state.error?.message || 'Terjadi kesalahan yang tidak terduga'}
              </p>
              <Button
                onClick={() => {
                  this.setState({ hasError: false, error: undefined })
                  window.location.reload()
                }}
                className="w-full"
              >
                Muat Ulang Halaman
              </Button>
            </Card>
          </div>
        )
      )
    }

    return this.props.children
  }
}
