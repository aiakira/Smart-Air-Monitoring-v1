# Design Document

## Overview

This design document outlines the integration of the Smart Air Monitor Next.js application with a PostgreSQL database hosted on Neon. The application currently uses simulated data and needs to be connected to a real database that stores sensor readings, fan control states, and notifications.

The integration will use Next.js API routes for server-side database operations, a PostgreSQL client library for database connectivity, and TypeScript interfaces for type safety.

## Architecture

### High-Level Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                     Client (Browser)                         │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │  Dashboard   │  │   History    │  │ Notifications│      │
│  │    Page      │  │    Page      │  │     Page     │      │
│  └──────────────┘  └──────────────┘  └──────────────┘      │
└─────────────────────────────────────────────────────────────┘
                            │
                            │ HTTP/Fetch
                            ▼
┌─────────────────────────────────────────────────────────────┐
│                   Next.js API Routes                         │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │   /api/      │  │   /api/      │  │   /api/      │      │
│  │   sensors    │  │   control    │  │notifications │      │
│  └──────────────┘  └──────────────┘  └──────────────┘      │
└─────────────────────────────────────────────────────────────┘
                            │
                            │ SQL Queries
                            ▼
┌─────────────────────────────────────────────────────────────┐
│              Database Client (node-postgres)                 │
│                    Connection Pool                           │
└─────────────────────────────────────────────────────────────┘
                            │
                            │ PostgreSQL Protocol
                            ▼
┌─────────────────────────────────────────────────────────────┐
│              PostgreSQL Database (Neon)                      │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │ sensor_data  │  │   kontrol    │  │notifications │      │
│  └──────────────┘  └──────────────┘  └──────────────┘      │
└─────────────────────────────────────────────────────────────┘
```

### Technology Stack

- **Frontend**: Next.js 16 with React 19, TypeScript
- **Backend**: Next.js API Routes (Server-side)
- **Database Client**: `pg` (node-postgres) with connection pooling
- **Database**: PostgreSQL 15+ (Neon serverless)
- **Environment Management**: `.env.local` for connection strings
- **Type Safety**: TypeScript interfaces matching database schema

## Components and Interfaces

### 1. Database Connection Module

**Location**: `lib/db.ts`

**Purpose**: Centralized database connection management with connection pooling

**Key Features**:
- Singleton connection pool
- Environment variable configuration
- Error handling and logging
- Connection health checks

**Interface**:
```typescript
import { Pool } from 'pg'

export const pool: Pool
export async function query<T>(text: string, params?: any[]): Promise<T[]>
export async function getClient(): Promise<PoolClient>
```

### 2. Type Definitions

**Location**: `lib/types.ts`

**Purpose**: TypeScript interfaces matching database schema

**Interfaces**:
```typescript
export interface SensorData {
  id: number
  co2: number
  co: number
  dust: number
  timestamp: Date
}

export interface SensorDataWithCategories extends SensorData {
  co2_category: string
  co_category: string
  dust_category: string
  air_quality_status: string
}

export interface KontrolData {
  id: number
  fan: 'ON' | 'OFF'
  mode: 'AUTO' | 'MANUAL'
  waktu: Date
}

export interface Notification {
  id: number
  title: string
  message: string
  type: 'warning' | 'danger' | 'info' | 'success'
  is_read: boolean
  created_at: Date
}
```

### 3. API Routes

#### `/api/sensors/latest` (GET)

**Purpose**: Retrieve the most recent sensor reading with categories

**Response**:
```typescript
{
  success: boolean
  data?: SensorDataWithCategories
  error?: string
}
```

**Database Function Used**: `get_latest_reading()`

#### `/api/sensors/historical` (GET)

**Purpose**: Retrieve historical sensor data

**Query Parameters**:
- `hours` (optional): Number of hours to look back (default: 24)

**Response**:
```typescript
{
  success: boolean
  data?: SensorDataWithCategories[]
  error?: string
}
```

**Database Function Used**: `get_historical_data(hours_back)`

#### `/api/control` (GET, POST)

**Purpose**: Get current control status or update fan control

**GET Response**:
```typescript
{
  success: boolean
  data?: KontrolData
  error?: string
}
```

**POST Request Body**:
```typescript
{
  fan: 'ON' | 'OFF'
  mode: 'AUTO' | 'MANUAL'
}
```

**POST Response**:
```typescript
{
  success: boolean
  data?: KontrolData
  error?: string
}
```

#### `/api/notifications` (GET, PATCH)

**Purpose**: Retrieve notifications or mark them as read

**GET Query Parameters**:
- `unread` (optional): Filter for unread notifications only

**GET Response**:
```typescript
{
  success: boolean
  data?: Notification[]
  error?: string
}
```

**PATCH Request Body**:
```typescript
{
  id: number
  is_read: boolean
}
```

**PATCH Response**:
```typescript
{
  success: boolean
  data?: Notification
  error?: string
}
```

### 4. Client-Side Hooks

#### `hooks/use-sensor-data.ts`

**Purpose**: Custom hook for fetching and auto-refreshing sensor data

**Interface**:
```typescript
export function useSensorData(refreshInterval?: number) {
  return {
    data: SensorDataWithCategories | null
    loading: boolean
    error: Error | null
    refetch: () => Promise<void>
  }
}
```

#### `hooks/use-control.ts`

**Purpose**: Custom hook for fan control management

**Interface**:
```typescript
export function useControl() {
  return {
    control: KontrolData | null
    loading: boolean
    error: Error | null
    updateControl: (fan: 'ON' | 'OFF', mode: 'AUTO' | 'MANUAL') => Promise<void>
  }
}
```

#### `hooks/use-notifications.ts`

**Purpose**: Custom hook for notification management

**Interface**:
```typescript
export function useNotifications() {
  return {
    notifications: Notification[]
    loading: boolean
    error: Error | null
    markAsRead: (id: number) => Promise<void>
    refetch: () => Promise<void>
  }
}
```

## Data Models

### Database Schema (Already Exists)

The database schema is already created with the following tables:

1. **sensor_data**: Stores sensor readings with constraints
2. **kontrol**: Stores fan control state
3. **notifications**: Stores system notifications

### Helper Functions (Already Exists)

The database includes PostgreSQL functions for:
- `get_co2_category(co2_value)`: Categorizes CO2 levels
- `get_co_category(co_value)`: Categorizes CO levels
- `get_dust_category(dust_value)`: Categorizes dust levels
- `get_air_quality_status(co2, co, dust)`: Overall air quality
- `get_latest_reading()`: Returns latest sensor data with categories
- `get_historical_data(hours_back)`: Returns historical data with categories

## Error Handling

### Database Connection Errors

**Strategy**: Graceful degradation with user feedback

**Implementation**:
- Catch connection errors in `lib/db.ts`
- Return structured error responses from API routes
- Display user-friendly error messages in UI
- Log detailed errors server-side for debugging

**Error Response Format**:
```typescript
{
  success: false,
  error: "User-friendly error message",
  details?: "Technical details (development only)"
}
```

### Query Errors

**Strategy**: Validate inputs and handle SQL errors

**Implementation**:
- Validate query parameters before execution
- Use parameterized queries to prevent SQL injection
- Catch and log query errors
- Return appropriate HTTP status codes (400, 500)

### Client-Side Error Handling

**Strategy**: Display errors and provide retry mechanisms

**Implementation**:
- Show toast notifications for errors
- Provide retry buttons for failed requests
- Display loading states during operations
- Handle network errors gracefully

## Testing Strategy

### Unit Tests

**Focus**: Database utility functions and type conversions

**Tools**: Jest or Vitest

**Test Cases**:
- Database connection pool initialization
- Query function with various inputs
- Type conversion and validation
- Error handling in utility functions

### Integration Tests

**Focus**: API routes with database interactions

**Tools**: Jest with supertest or Vitest

**Test Cases**:
- GET /api/sensors/latest returns valid data
- GET /api/sensors/historical with different time ranges
- POST /api/control updates database correctly
- PATCH /api/notifications marks as read
- Error responses for invalid inputs

### End-to-End Tests (Optional)

**Focus**: Full user workflows

**Tools**: Playwright or Cypress

**Test Cases**:
- Dashboard loads and displays sensor data
- Fan control toggles work correctly
- Notifications display and can be marked as read
- Historical data page shows charts

## Security Considerations

### Environment Variables

- Store database connection string in `.env.local`
- Never commit `.env.local` to version control
- Use `.env.example` for documentation

### SQL Injection Prevention

- Use parameterized queries exclusively
- Validate and sanitize all user inputs
- Leverage TypeScript for type safety

### Connection Security

- Use SSL/TLS for database connections (required by Neon)
- Implement connection pooling to prevent exhaustion
- Set appropriate connection timeouts

### API Route Protection (Future Enhancement)

- Consider adding authentication for write operations
- Implement rate limiting for API routes
- Add CORS configuration if needed

## Performance Optimization

### Connection Pooling

- Use `pg` Pool for connection reuse
- Configure pool size based on expected load
- Set idle timeout to release unused connections

### Caching Strategy

- Implement client-side caching with SWR or React Query
- Set appropriate cache invalidation intervals
- Use stale-while-revalidate pattern for better UX

### Query Optimization

- Leverage database indexes (already created)
- Use database functions for complex calculations
- Limit result sets with appropriate time ranges

## Deployment Considerations

### Environment Setup

**Required Environment Variables**:
```
DATABASE_URL=postgresql://neondb_owner:npg_U7IHN4rFmCVs@ep-lucky-darkness-a15k13s2-pooler.ap-southeast-1.aws.neon.tech/neondb?sslmode=require&channel_binding=require
```

### Database Migrations

- Schema is already created
- No migrations needed for initial integration
- Future schema changes should use migration tools

### Monitoring

- Log database connection errors
- Monitor query performance
- Track API route response times
- Set up alerts for connection failures
