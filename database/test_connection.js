/**
 * Test Connection to Neon PostgreSQL Database
 * 
 * Usage:
 * 1. Install pg: npm install pg
 * 2. Run: node database/test_connection.js
 */

const { Pool } = require('pg');

// Connection string dari environment atau argumen CLI
const DATABASE_URL = process.env.DATABASE_URL || process.argv[2];

if (!DATABASE_URL) {
  console.error('❌ DATABASE_URL tidak ditemukan.');
  console.error('Jalankan: DATABASE_URL=... node database/test_connection.js');
  console.error('atau: node database/test_connection.js "postgresql://user:pass@host/db?sslmode=require"');
  process.exit(1);
}

console.log('🔍 Testing Neon Database Connection...\n');

const pool = new Pool({
  connectionString: DATABASE_URL,
  ssl: {
    rejectUnauthorized: false
  }
});

async function testConnection() {
  try {
    console.log('📡 Connecting to database...');
    
    // Test 1: Basic connection
    const client = await pool.connect();
    console.log('✅ Connection successful!\n');
    
    // Test 2: Check PostgreSQL version
    console.log('📊 Database Information:');
    const versionResult = await client.query('SELECT version()');
    console.log('   PostgreSQL Version:', versionResult.rows[0].version.split(',')[0]);
    
    // Test 3: Check current database
    const dbResult = await client.query('SELECT current_database()');
    console.log('   Current Database:', dbResult.rows[0].current_database);
    
    // Test 4: Check if sensor_data table exists
    console.log('\n🔍 Checking Tables:');
    const tableCheck = await client.query(`
      SELECT table_name 
      FROM information_schema.tables 
      WHERE table_schema = 'public' 
      ORDER BY table_name
    `);
    
    if (tableCheck.rows.length > 0) {
      console.log('   Tables found:');
      tableCheck.rows.forEach(row => {
        console.log('   - ' + row.table_name);
      });
    } else {
      console.log('   ⚠️  No tables found. Jalankan database/setup_database.sql terlebih dahulu!');
    }
    
    // Test 5: Check if sensor_data table exists specifically
    const sensorTableCheck = await client.query(`
      SELECT EXISTS (
        SELECT FROM information_schema.tables 
        WHERE table_schema = 'public' 
        AND table_name = 'sensor_data'
      )
    `);
    
    if (sensorTableCheck.rows[0].exists) {
      console.log('\n✅ sensor_data table exists');
      
      // Test 6: Count records
      const countResult = await client.query('SELECT COUNT(*) FROM sensor_data');
      console.log('   Total records:', countResult.rows[0].count);
      
      // Test 7: Get latest record
      const latestResult = await client.query(`
        SELECT co2, co, dust, timestamp 
        FROM sensor_data 
        ORDER BY timestamp DESC 
        LIMIT 1
      `);
      
      if (latestResult.rows.length > 0) {
        console.log('   Latest record:');
        console.log('   - CO₂:', latestResult.rows[0].co2, 'ppm');
        console.log('   - CO:', latestResult.rows[0].co, 'ppm');
        console.log('   - Dust:', latestResult.rows[0].dust, 'µg/m³');
        console.log('   - Time:', latestResult.rows[0].timestamp);
      }
    } else {
      console.log('\n❌ sensor_data table NOT found!');
      console.log('   Run database/setup_database.sql to create the schema.');
    }
    
    // Test 8: Check functions
    console.log('\n🔍 Checking Functions:');
    const functionsCheck = await client.query(`
      SELECT routine_name 
      FROM information_schema.routines 
      WHERE routine_schema = 'public' 
      AND routine_type = 'FUNCTION'
      ORDER BY routine_name
    `);
    
    if (functionsCheck.rows.length > 0) {
      console.log('   Functions found:');
      functionsCheck.rows.forEach(row => {
        console.log('   - ' + row.routine_name);
      });
    } else {
      console.log('   ⚠️  No functions found.');
    }
    
    // Test 9: Check views
    console.log('\n🔍 Checking Views:');
    const viewsCheck = await client.query(`
      SELECT table_name 
      FROM information_schema.views 
      WHERE table_schema = 'public'
      ORDER BY table_name
    `);
    
    if (viewsCheck.rows.length > 0) {
      console.log('   Views found:');
      viewsCheck.rows.forEach(row => {
        console.log('   - ' + row.table_name);
      });
    } else {
      console.log('   ⚠️  No views found.');
    }
    
    // Test 10: Test get_latest_reading function (if exists)
    try {
      const functionTest = await client.query('SELECT * FROM get_latest_reading()');
      if (functionTest.rows.length > 0) {
        console.log('\n✅ get_latest_reading() function works!');
        console.log('   Result:', functionTest.rows[0]);
      }
    } catch (err) {
      console.log('\n⚠️  get_latest_reading() function not found or error');
    }
    
    client.release();
    
    console.log('\n' + '='.repeat(50));
    console.log('✅ All connection tests completed successfully!');
    console.log('='.repeat(50));
    
  } catch (err) {
    console.error('\n❌ Connection test failed!');
    console.error('Error:', err.message);
    console.error('\nPossible issues:');
    console.error('1. Check DATABASE_URL is correct');
    console.error('2. Check internet connection');
    console.error('3. Check Neon project is active');
    console.error('4. Check SSL settings');
    process.exit(1);
  } finally {
    await pool.end();
  }
}

// Run the test
testConnection();
