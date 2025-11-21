-- Database Indexes untuk Optimasi Performance
-- Jalankan query ini di Neon DB Console

-- Index untuk sensor_data (query paling sering)
CREATE INDEX IF NOT EXISTS idx_sensor_timestamp ON sensor_data(timestamp DESC);

-- Index untuk kontrol (query latest control)
CREATE INDEX IF NOT EXISTS idx_kontrol_waktu ON kontrol(waktu DESC);

-- Index untuk notifications (query by created_at)
CREATE INDEX IF NOT EXISTS idx_notifications_created ON notifications(created_at DESC);

-- Index untuk notifications (filter unread)
CREATE INDEX IF NOT EXISTS idx_notifications_unread ON notifications(is_read) WHERE is_read = false;

-- Verify indexes
SELECT 
    tablename,
    indexname,
    indexdef
FROM 
    pg_indexes
WHERE 
    schemaname = 'public'
ORDER BY 
    tablename, indexname;
