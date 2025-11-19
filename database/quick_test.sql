-- ============================================
-- QUICK CONNECTION TEST
-- Copy paste ke Neon SQL Editor untuk test
-- ============================================

-- Test 1: Basic query
SELECT 'Connection OK!' as status, NOW() as current_time;

-- Test 2: Check PostgreSQL version
SELECT version();

-- Test 3: Check current database
SELECT current_database(), current_user;

-- Test 4: List all tables
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public' 
ORDER BY table_name;

-- Test 5: Check if sensor_data exists
SELECT EXISTS (
    SELECT FROM information_schema.tables 
    WHERE table_schema = 'public' 
    AND table_name = 'sensor_data'
) as sensor_data_exists;

-- Test 6: Count records (if table exists)
-- Uncomment jika table sudah ada
-- SELECT COUNT(*) as total_records FROM sensor_data;

-- Test 7: Get latest record (if table exists)
-- Uncomment jika table sudah ada
-- SELECT * FROM sensor_data ORDER BY timestamp DESC LIMIT 1;

-- Test 8: List all functions
SELECT routine_name, routine_type
FROM information_schema.routines 
WHERE routine_schema = 'public'
ORDER BY routine_name;

-- Test 9: List all views
SELECT table_name as view_name
FROM information_schema.views 
WHERE table_schema = 'public'
ORDER BY table_name;

-- Test 10: Test function (if exists)
-- Uncomment jika function sudah ada
-- SELECT * FROM get_latest_reading();

-- ============================================
-- HASIL YANG DIHARAPKAN:
-- ============================================
-- ✅ Semua query berhasil dijalankan
-- ✅ sensor_data_exists = true (jika schema sudah dijalankan)
-- ✅ Ada beberapa tables, functions, dan views
-- ============================================
