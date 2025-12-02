-- Table: sensor_readings
CREATE TABLE IF NOT EXISTS sensor_readings (
  id SERIAL PRIMARY KEY,
  co2 NUMERIC(10, 2) NOT NULL,           -- Kadar CO2 dalam ppm
  co NUMERIC(10, 2) NOT NULL,            -- Kadar CO dalam ppm
  dust NUMERIC(10, 2) NOT NULL,          -- Kadar debu dalam µg/m³
  ts TIMESTAMP DEFAULT CURRENT_TIMESTAMP -- Waktu pembacaan
);

-- Optional: Create index on timestamp for faster queries
CREATE INDEX IF NOT EXISTS idx_sensor_readings_ts ON sensor_readings(ts DESC);
