import { Pool, QueryResult, PoolClient } from 'pg'

// Create a singleton connection pool
let pool: Pool | null = null

function getPool(): Pool {
  if (!pool) {
    const connectionString = process.env.DATABASE_URL

    if (!connectionString) {
      throw new Error('DATABASE_URL environment variable is not set')
    }

    pool = new Pool({
      connectionString,
      ssl: {
        rejectUnauthorized: false,
      },
      max: 20, // Maximum number of clients in the pool
      idleTimeoutMillis: 30000, // Close idle clients after 30 seconds
      connectionTimeoutMillis: 10000, // Return an error after 10 seconds if connection could not be established
    })

    // Log pool errors
    pool.on('error', (err) => {
      console.error('Unexpected error on idle client', err)
    })

    // Log successful connection
    pool.on('connect', () => {
      console.log('Database connection established')
    })
  }

  return pool
}

/**
 * Execute a SQL query with optional parameters
 * @param text SQL query string
 * @param params Query parameters
 * @returns Query result rows
 */
export async function query<T = any>(
  text: string,
  params?: any[]
): Promise<T[]> {
  const pool = getPool()
  
  try {
    const start = Date.now()
    const result = await pool.query(text, params)
    const duration = Date.now() - start
    
    // Log query execution time in development
    if (process.env.NODE_ENV === 'development') {
      console.log('Executed query', { text, duration, rows: result.rowCount })
    }
    
    return result.rows as T[]
  } catch (error) {
    console.error('Database query error:', error)
    throw error
  }
}

/**
 * Get a client from the pool for transaction support
 * Remember to release the client after use
 */
export async function getClient(): Promise<PoolClient> {
  const pool = getPool()
  return await pool.connect()
}

/**
 * Test database connection
 * @returns true if connection is successful
 */
export async function testConnection(): Promise<boolean> {
  try {
    const result = await query<{ now: Date }>('SELECT NOW() as now')
    console.log('Database connection test successful:', result[0]?.now)
    return true
  } catch (error) {
    console.error('Database connection test failed:', error)
    return false
  }
}

// Export the pool for advanced use cases
export { getPool }
