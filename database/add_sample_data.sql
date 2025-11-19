-- ============================================
-- ADD SAMPLE DATA
-- ============================================

INSERT INTO sensor_data (co2, co, dust, timestamp) VALUES
(450.5, 5.2, 12.3, NOW() - INTERVAL '10 minutes'),
(520.3, 6.1, 14.7, NOW() - INTERVAL '9 minutes'),
(380.2, 4.5, 10.9, NOW() - INTERVAL '8 minutes'),
(850.0, 7.0, 18.0, NOW() - INTERVAL '7 minutes'),
(920.0, 8.0, 20.0, NOW() - INTERVAL '6 minutes'),
(750.0, 5.0, 30.0, NOW() - INTERVAL '5 minutes'),
(700.0, 6.0, 32.0, NOW() - INTERVAL '4 minutes'),
(1500.0, 12.0, 45.0, NOW() - INTERVAL '3 minutes'),
(1800.0, 15.0, 50.0, NOW() - INTERVAL '2 minutes'),
(3000.0, 150.0, 60.0, NOW() - INTERVAL '1 minute');

SELECT 'Sample data inserted!' as status;
SELECT COUNT(*) as total_records FROM sensor_data;
