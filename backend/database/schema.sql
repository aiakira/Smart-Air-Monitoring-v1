-- Database Schema untuk Smart Air Monitoring
-- Jalankan script ini di Neon DB SQL Editor

-- ============================================
-- Tabel 1: Data Sensor (ALUR 1 & 2)
-- ============================================

CREATE TABLE IF NOT EXISTS sensor_data (
    id SERIAL PRIMARY KEY,
    waktu TIMESTAMP NOT NULL DEFAULT NOW(),
    nilai_co2 DECIMAL(10, 2) NOT NULL,
    nilai_co DECIMAL(10, 2) NOT NULL,
    nilai_debu DECIMAL(10, 2) NOT NULL,
    created_at TIMESTAMP DEFAULT NOW()
);

-- Index untuk mempercepat query berdasarkan waktu
CREATE INDEX IF NOT EXISTS idx_sensor_data_waktu ON sensor_data(waktu DESC);

-- ============================================
-- Tabel 2: Kontrol Perangkat (ALUR 3)
-- ============================================

CREATE TABLE IF NOT EXISTS kontrol_perangkat (
    id_perangkat INTEGER PRIMARY KEY DEFAULT 1,
    status_fan VARCHAR(10) NOT NULL DEFAULT 'OFF' CHECK (status_fan IN ('ON', 'OFF')),
    mode_operasi VARCHAR(10) NOT NULL DEFAULT 'AUTO' CHECK (mode_operasi IN ('AUTO', 'MANUAL')),
    waktu_update TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Insert data default
INSERT INTO kontrol_perangkat (id_perangkat, status_fan, mode_operasi)
VALUES (1, 'OFF', 'AUTO')
ON CONFLICT (id_perangkat) DO NOTHING;

-- ============================================
-- Tabel 3: Notifikasi (Opsional)
-- ============================================

CREATE TABLE IF NOT EXISTS notifikasi (
    id SERIAL PRIMARY KEY,
    judul VARCHAR(255) NOT NULL,
    pesan TEXT NOT NULL,
    waktu TIMESTAMP NOT NULL DEFAULT NOW(),
    sudah_dibaca BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT NOW()
);

-- Index untuk query notifikasi belum dibaca
CREATE INDEX IF NOT EXISTS idx_notifikasi_dibaca ON notifikasi(sudah_dibaca, waktu DESC);

-- ============================================
-- Contoh Query untuk Testing
-- ============================================

-- Lihat data sensor terbaru
-- SELECT * FROM sensor_data ORDER BY waktu DESC LIMIT 10;

-- Lihat status kontrol
-- SELECT * FROM kontrol_perangkat;

-- Lihat notifikasi belum dibaca
-- SELECT * FROM notifikasi WHERE sudah_dibaca = FALSE ORDER BY waktu DESC;

