const express = require('express');
const cors = require('cors');
const { Pool } = require('pg');
require('dotenv').config();

const app = express();

// Middleware
app.use(cors());
app.use(express.json());

// Koneksi ke Neon PostgreSQL
const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
  ssl: {
    rejectUnauthorized: false
  }
});

// Test koneksi database
pool.connect((err, client, release) => {
  if (err) {
    console.error('❌ Error connecting to database:', err.stack);
  } else {
    console.log('✅ Connected to Neon PostgreSQL database');
    release();
  }
});

// ============================================
// ROUTES
// ============================================

// Health Check
app.get('/api/health', (req, res) => {
  res.json({ 
    status: 'OK',
    message: 'Smart Air Monitoring API is running',
    timestamp: new Date().toISOString()
  });
});

// Data Terbaru (untuk Dashboard) - Updated untuk schema baru
app.get('/api/data/terbaru', async (req, res) => {
  try {
    // Gunakan function get_latest_reading() dari database
    const result = await pool.query('SELECT * FROM get_latest_reading()');
    
    if (result.rows.length > 0) {
      res.json(result.rows[0]);
    } else {
      res.status(404).json({ 
        error: 'No data found',
        message: 'Belum ada data sensor di database'
      });
    }
  } catch (error) {
    console.error('Error fetching latest data:', error);
    res.status(500).json({ 
      error: 'Internal server error',
      message: error.message 
    });
  }
});

// Data Historis (untuk Grafik) - Updated untuk schema baru
app.get('/api/data/historis', async (req, res) => {
  try {
    const hours = parseInt(req.query.hours) || 24;
    
    // Gunakan function get_historical_data() dari database
    const result = await pool.query(
      'SELECT * FROM get_historical_data($1)',
      [hours]
    );
    
    res.json({ 
      data: result.rows,
      count: result.rows.length,
      hours: hours
    });
  } catch (error) {
    console.error('Error fetching historical data:', error);
    res.status(500).json({ 
      error: 'Internal server error',
      message: error.message 
    });
  }
});

// Status Kontrol (Fan ON/OFF, Mode Auto/Manual)
app.get('/api/kontrol/status', async (req, res) => {
  try {
    const result = await pool.query(
      'SELECT fan, mode, waktu FROM kontrol ORDER BY waktu DESC LIMIT 1'
    );
    
    if (result.rows.length > 0) {
      res.json(result.rows[0]);
    } else {
      // Default status jika belum ada data
      res.json({ 
        fan: 'OFF', 
        mode: 'AUTO',
        waktu: new Date().toISOString()
      });
    }
  } catch (error) {
    console.error('Error fetching control status:', error);
    res.status(500).json({ 
      error: 'Internal server error',
      message: error.message 
    });
  }
});

// Kirim Perintah Kontrol
app.post('/api/kontrol', async (req, res) => {
  try {
    const { fan, mode } = req.body;
    
    // Validasi input
    if (!fan && !mode) {
      return res.status(400).json({ 
        error: 'Bad request',
        message: 'fan atau mode harus diisi'
      });
    }
    
    // Ambil status terakhir
    const lastStatus = await pool.query(
      'SELECT fan, mode FROM kontrol ORDER BY waktu DESC LIMIT 1'
    );
    
    const currentFan = fan || (lastStatus.rows.length > 0 ? lastStatus.rows[0].fan : 'OFF');
    const currentMode = mode || (lastStatus.rows.length > 0 ? lastStatus.rows[0].mode : 'AUTO');
    
    // Insert perintah baru
    const result = await pool.query(
      'INSERT INTO kontrol (fan, mode, waktu) VALUES ($1, $2, NOW()) RETURNING *',
      [currentFan, currentMode]
    );
    
    res.json({ 
      success: true,
      data: result.rows[0],
      message: 'Perintah kontrol berhasil dikirim'
    });
  } catch (error) {
    console.error('Error sending control command:', error);
    res.status(500).json({ 
      error: 'Internal server error',
      message: error.message 
    });
  }
});

// Insert Data Sensor (untuk Arduino/ESP32) - Updated untuk schema baru
app.post('/api/data', async (req, res) => {
  try {
    const { co2, co, dust } = req.body;
    
    // Validasi input
    if (co2 === undefined || co === undefined || dust === undefined) {
      return res.status(400).json({ 
        error: 'Bad request',
        message: 'co2, co, dan dust harus diisi'
      });
    }
    
    // Insert data dan return dengan kategori
    const result = await pool.query(
      `INSERT INTO sensor_data (co2, co, dust) 
       VALUES ($1, $2, $3)
       RETURNING 
         id, co2, co, dust, timestamp,
         get_co2_category(co2) as co2_category,
         get_co_category(co) as co_category,
         get_dust_category(dust) as dust_category,
         get_air_quality_status(co2, co, dust) as air_quality_status`,
      [co2, co, dust]
    );
    
    res.json({ 
      success: true,
      data: result.rows[0],
      message: 'Data sensor berhasil disimpan'
    });
  } catch (error) {
    console.error('Error inserting sensor data:', error);
    res.status(500).json({ 
      error: 'Internal server error',
      message: error.message 
    });
  }
});

// Statistik Data - Updated untuk schema baru
app.get('/api/data/statistik', async (req, res) => {
  try {
    const hours = parseInt(req.query.hours) || 24;
    
    const result = await pool.query(
      `SELECT 
        COUNT(*) as total_data,
        AVG(co2) as avg_co2,
        MAX(co2) as max_co2,
        MIN(co2) as min_co2,
        AVG(co) as avg_co,
        MAX(co) as max_co,
        MIN(co) as min_co,
        AVG(dust) as avg_dust,
        MAX(dust) as max_dust,
        MIN(dust) as min_dust
       FROM sensor_data 
       WHERE timestamp >= NOW() - INTERVAL '${hours} hours'`
    );
    
    res.json(result.rows[0]);
  } catch (error) {
    console.error('Error fetching statistics:', error);
    res.status(500).json({ 
      error: 'Internal server error',
      message: error.message 
    });
  }
});

// 404 Handler
app.use((req, res) => {
  res.status(404).json({ 
    error: 'Not found',
    message: 'Endpoint tidak ditemukan'
  });
});

// Error Handler
app.use((err, req, res, next) => {
  console.error('Unhandled error:', err);
  res.status(500).json({ 
    error: 'Internal server error',
    message: err.message 
  });
});

// Start Server
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`🚀 Server running on http://localhost:${PORT}`);
  console.log(`📊 API Endpoints:`);
  console.log(`   GET  /api/health`);
  console.log(`   GET  /api/data/terbaru`);
  console.log(`   GET  /api/data/historis?hours=24`);
  console.log(`   GET  /api/data/statistik?hours=24`);
  console.log(`   POST /api/data`);
  console.log(`   GET  /api/kontrol/status`);
  console.log(`   POST /api/kontrol`);
});

// Graceful shutdown
process.on('SIGTERM', () => {
  console.log('SIGTERM signal received: closing HTTP server');
  pool.end(() => {
    console.log('Database pool closed');
  });
});
