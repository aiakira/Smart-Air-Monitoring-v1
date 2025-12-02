/**
 * Inspect schema & data inside Neon DB
 * Usage: DATABASE_URL=... node database/check_existing_schema.js
 */

const { Pool } = require('pg');

const DATABASE_URL = process.env.DATABASE_URL || process.argv[2];

if (!DATABASE_URL) {
  console.error('❌ DATABASE_URL tidak ditemukan.');
  console.error('Set environment variable atau kirim sebagai argumen CLI.');
  process.exit(1);
}

const pool = new Pool({
  connectionString: DATABASE_URL,
  ssl: { rejectUnauthorized: false },
});

async function checkSchema() {
  const client = await pool.connect();

  try {
    console.log('📊 Inspecting schema and latest data...\n');

    const tables = await client.query(`
      SELECT table_name
      FROM information_schema.tables
      WHERE table_schema = 'public'
      ORDER BY table_name
    `);

    console.log('Tables:');
    tables.rows.forEach((row) => console.log(` - ${row.table_name}`));

    const requiredTables = ['sensor_readings', 'notifications'];
    const missing = requiredTables.filter(
      (name) => !tables.rows.find((row) => row.table_name === name),
    );

    if (missing.length) {
      console.log('\n⚠️  Missing tables:', missing.join(', '));
      console.log('Run database/setup_database.sql first.\n');
      return;
    }

    const sensorColumns = await client.query(`
      SELECT column_name, data_type
      FROM information_schema.columns
      WHERE table_name = 'sensor_readings'
      ORDER BY ordinal_position
    `);

    console.log('\nColumns for sensor_data:');
    sensorColumns.rows.forEach((col) =>
      console.log(` - ${col.column_name} (${col.data_type})`),
    );

    const latestSensor = await client.query(`
      SELECT *
      FROM sensor_readings
      ORDER BY ts DESC
      LIMIT 5
    `);

    console.log('\nLatest sensor records:');
    if (latestSensor.rows.length === 0) {
      console.log(' - No data yet');
    } else {
      latestSensor.rows.forEach((row, idx) => {
        console.log(`\n   Record #${idx + 1}`);
        console.log(`   id         : ${row.id}`);
        console.log(`   co2 (ppm)  : ${row.co2}`);
        console.log(`   co (ppm)   : ${row.co}`);
        console.log(`   dust (µg/m³): ${row.dust}`);
        console.log(`   timestamp  : ${row.ts}`);
      });
    }

    const views = await client.query(`
      SELECT table_name
      FROM information_schema.views
      WHERE table_schema = 'public'
      ORDER BY table_name
    `);

    console.log('\nViews:');
    views.rows.forEach((row) => console.log(` - ${row.table_name}`));
  } catch (error) {
    console.error('❌ Error:', error.message);
  } finally {
    client.release();
    await pool.end();
  }
}

checkSchema();
