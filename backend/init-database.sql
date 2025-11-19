-- ============================================
-- Database Schema untuk Smart Air Monitoring
-- PostgreSQL (Neon DB)
-- ============================================

-- Tabel untuk menyimpan data sensor
CREATE TABLE IF NOT EXISTS sensor_data (
  id SERIAL PRIMARY KEY,
  co2 FLOAT NOT NULL,
  co FLOAT NOT NULL,
  debu FLOAT NOT NULL,
  waktu TIMESTAMP NOT NULL DEFAULT NOW(),
  created_at TIMESTAMP DEFAULT NOW()
);

-- Index untuk performa query berdasarkan waktu
CREATE INDEX IF NOT EXISTS idx_sensor_data_waktu ON sensor_data(waktu DESC);

-- Tabel untuk menyimpan status kontrol
CREATE TABLE IF NOT EXISTS kontrol (
  id SERIAL PRIMARY KEY,
  fan VARCHAR(10) NOT NULL CHECK (fan IN ('ON', 'OFF')),
  mode VARCHAR(10) NOT NULL CHECK (mode IN ('AUTO', 'MANUAL')),
  waktu TIMESTAMP NOT NULL DEFAULT NOW(),
  created_at TIMESTAMP DEFAULT NOW()
);

-- Index untuk performa query status kontrol
CREATE INDEX IF NOT EXISTS idx_kontrol_waktu ON kontrol(waktu DESC);

-- ============================================
-- Sample Data untuk Testing
-- ============================================

-- Insert sample sensor data (24 jam terakhir)
INSERT INTO sensor_data (co2, co, debu, waktu) VALUES
(450, 5.2, 25.3, NOW()),
(460, 5.5, 26.1, NOW() - INTERVAL '1 hour'),
(440, 4.8, 24.5, NOW() - INTERVAL '2 hours'),
(470, 6.1, 27.2, NOW() - INTERVAL '3 hours'),
(455, 5.3, 25.8, NOW() - INTERVAL '4 hours'),
(465, 5.7, 26.5, NOW() - INTERVAL '5 hours'),
(445, 4.9, 24.9, NOW() - INTERVAL '6 hours'),
(475, 6.3, 27.8, NOW() - INTERVAL '7 hours'),
(450, 5.1, 25.2, NOW() - INTERVAL '8 hours'),
(460, 5.6, 26.3, NOW() - INTERVAL '9 hours'),
(440, 4.7, 24.4, NOW() - INTERVAL '10 hours'),
(470, 6.2, 27.5, NOW() - INTERVAL '11 hours'),
(455, 5.4, 25.9, NOW() - INTERVAL '12 hours'),
(465, 5.8, 26.7, NOW() - INTERVAL '13 hours'),
(445, 5.0, 25.0, NOW() - INTERVAL '14 hours'),
(475, 6.4, 28.0, NOW() - INTERVAL '15 hours'),
(450, 5.2, 25.4, NOW() - INTERVAL '16 hours'),
(460, 5.5, 26.2, NOW() - INTERVAL '17 hours'),
(440, 4.8, 24.6, NOW() - INTERVAL '18 hours'),
(470, 6.1, 27.3, NOW() - INTERVAL '19 hours'),
(455, 5.3, 25.7, NOW() - INTERVAL '20 hours'),
(465, 5.7, 26.6, NOW() - INTERVAL '21 hours'),
(445, 4.9, 24.8, NOW() - INTERVAL '22 hours'),
(475, 6.3, 27.9, NOW() - INTERVAL '23 hours');

-- Insert sample control status
INSERT INTO kontrol (fan, mode, waktu) VALUES
('OFF', 'AUTO', NOW()),
('ON', 'MANUAL', NOW() - INTERVAL '2 hours'),
('OFF', 'AUTO', NOW() - INTERVAL '4 hours');

-- ============================================
-- Queries untuk Maintenance
-- ============================================

-- Hapus data lama (lebih dari 30 hari)
-- DELETE FROM sensor_data WHERE waktu < NOW() - INTERVAL '30 days';

-- Lihat jumlah data
-- SELECT COUNT(*) FROM sensor_data;

-- Lihat data terbaru
-- SELECT * FROM sensor_data ORDER BY waktu DESC LIMIT 10;

-- Lihat statistik
-- SELECT 
--   COUNT(*) as total,
--   AVG(co2) as avg_co2,
--   AVG(co) as avg_co,
--   AVG(debu) as avg_debu
-- FROM sensor_data 
-- WHERE waktu >= NOW() - INTERVAL '24 hours';
