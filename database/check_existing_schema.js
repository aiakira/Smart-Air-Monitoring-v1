/**
 * Check Existing Schema in Neon Database
 */

const { Pool } = require('pg');

const DATABASE_URL = process.env.DATABASE_URL || 
  'postgresql://neondb_owner:npg_U7IHN4rFmCVs@ep-lucky-darkness-a15k13s2-pooler.ap-southeast-1.aws.neon.tech/neondb?sslmode=require';

const pool = new Pool({
  connectionString: DATABASE_URL,
  ssl: { rejectUnauthorized: false }
});

async function checkSchema() {
  try {
    const client = await pool.connect();
    
    console.log('📊 Checking existing schema...\n');
    
    // Check sensor_readings table structure
    const columnsResult = await client.query(`
      SELECT column_name, data_type, is_nullable
      FROM information_schema.columns
      WHERE table_name = 'sensor_readings'
      ORDER BY ordinal_position
    `);
    
    console.log('📋 sensor_readings table structure:');
    columnsResult.rows.forEach(col => {
      console.log(`   - ${col.column_name}: ${col.data_type} ${col.is_nullable === 'NO' ? '(NOT NULL)' : ''}`);
    });
    
    // Check data
    const dataResult = await client.query(`
      SELECT * FROM sensor_readings ORDER BY ts DESC LIMIT 5
    `);
    
    console.log('\n📊 Sample data (latest 5 records):');
    if (dataResult.rows.length > 0) {
      dataResult.rows.forEach((row, i) => {
        console.log(`\n   Record ${i + 1}:`);
        Object.keys(row).forEach(key => {
          console.log(`   - ${key}: ${row[key]}`);
        });
      });
    } else {
      console.log('   No data found');
    }
    
    client.release();
    
  } catch (err) {
    console.error('❌ Error:', err.message);
  } finally {
    await pool.end();
  }
}

checkSchema();
