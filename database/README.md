# Database Setup untuk Neon PostgreSQL

## 📋 Overview

Database schema yang sesuai dengan aplikasi Flutter monitoring kualitas udara. Schema ini menghilangkan field `status` dari database dan menghitung status secara dinamis menggunakan functions, sesuai dengan logika di aplikasi.

## 🎯 Perubahan Utama

### ❌ Yang Dihapus:
- Field `status` (dihitung di aplikasi, bukan disimpan)
- Field `created_at` (redundan dengan `timestamp`)
- Constraint status yang terbatas (hanya 3 kategori)

### ✅ Yang Ditambahkan:
- Functions untuk calculate kategori CO₂, CO, dan Debu
- Function untuk calculate status kualitas udara keseluruhan
- Function untuk get historical data dengan time range
- Views dengan kategori yang dihitung otomatis
- Index tambahan untuk performa query
- Constraint validasi nilai sensor (harus >= 0)

## 🚀 Cara Penggunaan

### Opsi 1: Database Baru (Fresh Install)

Jika Anda membuat database baru dari awal:

```bash
# Jalankan file ini di Neon SQL Editor
database/neon_schema_fixed.sql
```

File ini akan:
1. Membuat tabel `sensor_data` tanpa field status
2. Membuat semua functions untuk calculate kategori
3. Membuat views untuk analytics
4. Insert sample data untuk testing

### Opsi 2: Update Database Existing

Jika Anda sudah punya database dengan data:

**Step 1:** Jalankan migration script
```bash
# Jalankan di Neon SQL Editor
database/migration_update_schema.sql
```

**Step 2:** Jalankan functions dan views dari schema fixed
```bash
# Copy paste bagian FUNCTIONS dan VIEWS dari file ini
database/neon_schema_fixed.sql
```

⚠️ **PERINGATAN**: Migration akan menghapus column `status` dan `created_at`. Data sensor (co2, co, dust, timestamp) akan tetap aman.

## 📊 Schema Structure

### Tabel: sensor_data

```sql
CREATE TABLE sensor_data (
    id SERIAL PRIMARY KEY,
    co2 DOUBLE PRECISION NOT NULL CHECK (co2 >= 0),
    co DOUBLE PRECISION NOT NULL CHECK (co >= 0),
    dust DOUBLE PRECISION NOT NULL CHECK (dust >= 0),
    timestamp TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);
```

### Functions Available

#### 1. get_co2_category(co2_value)
Mengembalikan kategori CO₂: `BAIK`, `MASIH AMAN`, `TIDAK SEHAT`, `BAHAYA`, `SANGAT BERBAHAYA`

#### 2. get_co_category(co_value)
Mengembalikan kategori CO: `AMAN`, `TIDAK SEHAT`, `BERBAHAYA`, `SANGAT BERBAHAYA`, `FATAL`

#### 3. get_dust_category(dust_value)
Mengembalikan kategori Debu: `BAIK`, `SEDANG`, `TIDAK SEHAT`, `SANGAT TIDAK SEHAT`

#### 4. get_air_quality_status(co2, co, dust)
Mengembalikan status keseluruhan: `FATAL`, `SANGAT BURUK`, `BAHAYA`, `TIDAK SEHAT`, `SEDANG`, `MASIH AMAN`, `BAIK`

#### 5. get_latest_reading()
Mengembalikan pembacaan terbaru dengan semua kategori

#### 6. get_historical_data(hours_back)
Mengembalikan data historis dalam rentang waktu tertentu

#### 7. cleanup_old_data(days_to_keep)
Menghapus data lama (default: 30 hari)

### Views Available

#### 1. daily_statistics
Statistik harian dengan breakdown per kategori

#### 2. latest_readings
100 pembacaan terbaru dengan kategori

## 💡 Contoh Query

### Get data terbaru dengan kategori
```sql
SELECT * FROM get_latest_reading();
```

### Get data 24 jam terakhir
```sql
SELECT * FROM get_historical_data(24);
```

### Get data 7 hari terakhir
```sql
SELECT * FROM get_historical_data(168);  -- 7 * 24 = 168 jam
```

### Get statistik harian
```sql
SELECT * FROM daily_statistics LIMIT 7;
```

### Insert data baru
```sql
INSERT INTO sensor_data (co2, co, dust) 
VALUES (450.5, 5.2, 25.3);
-- timestamp akan otomatis menggunakan NOW()
```

### Query dengan kategori manual
```sql
SELECT 
    co2,
    co,
    dust,
    timestamp,
    get_co2_category(co2) as co2_category,
    get_co_category(co) as co_category,
    get_dust_category(dust) as dust_category,
    get_air_quality_status(co2, co, dust) as overall_status
FROM sensor_data
WHERE timestamp >= NOW() - INTERVAL '1 hour'
ORDER BY timestamp DESC;
```

### Cleanup data lebih dari 30 hari
```sql
SELECT cleanup_old_data(30);
```

## 🔧 Integration dengan Flutter App

### API Endpoint yang Perlu Update

Pastikan backend API Anda mengembalikan data tanpa field `status`, karena aplikasi Flutter akan menghitung sendiri:

```json
{
  "co2": 450.5,
  "co": 5.2,
  "dust": 25.3,
  "timestamp": "2024-01-15T10:30:00Z"
}
```

Atau jika ingin include kategori dari database:

```json
{
  "co2": 450.5,
  "co": 5.2,
  "dust": 25.3,
  "timestamp": "2024-01-15T10:30:00Z",
  "co2_category": "BAIK",
  "co_category": "AMAN",
  "dust_category": "BAIK",
  "air_quality_status": "BAIK"
}
```

### Model SensorData di Flutter

Model di `lib/models/sensor_data.dart` sudah sesuai - tidak ada field `status`, semua dihitung dengan methods.

## 📈 Performance Tips

1. **Index sudah optimal** untuk query berdasarkan timestamp dan nilai sensor
2. **Functions adalah IMMUTABLE** sehingga bisa di-cache oleh PostgreSQL
3. **Views menggunakan functions** yang sudah di-optimize
4. **Cleanup data lama** secara berkala untuk menjaga performa

## 🧪 Testing

Setelah setup, test dengan queries berikut:

```sql
-- Test 1: Cek jumlah data
SELECT COUNT(*) FROM sensor_data;

-- Test 2: Cek data terbaru
SELECT * FROM get_latest_reading();

-- Test 3: Cek semua kategori
SELECT 
    co2, get_co2_category(co2),
    co, get_co_category(co),
    dust, get_dust_category(dust),
    get_air_quality_status(co2, co, dust)
FROM sensor_data
LIMIT 5;

-- Test 4: Cek view
SELECT * FROM daily_statistics LIMIT 3;
SELECT * FROM latest_readings LIMIT 10;
```

## 🆘 Troubleshooting

### Error: column "status" does not exist
✅ Ini normal setelah migration. Pastikan aplikasi tidak mencoba query field `status`.

### Error: function already exists
✅ Gunakan `CREATE OR REPLACE FUNCTION` untuk update function.

### Data hilang setelah migration
❌ Migration hanya menghapus column `status` dan `created_at`, bukan data sensor. Cek dengan:
```sql
SELECT COUNT(*) FROM sensor_data;
```

## 📞 Support

Jika ada masalah, cek:
1. Apakah semua functions berhasil dibuat? `\df` di psql
2. Apakah semua views berhasil dibuat? `\dv` di psql
3. Apakah index sudah ada? `\di` di psql
