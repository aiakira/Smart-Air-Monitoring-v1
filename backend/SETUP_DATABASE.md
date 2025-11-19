# Setup Database Schema di Neon DB

## Langkah-langkah

### 1. Buka Neon Console

1. Kunjungi: https://console.neon.tech
2. Login ke akun Anda
3. Pilih project: **neondb** (atau project yang sesuai)

### 2. Buka SQL Editor

1. Di dashboard Neon, klik **SQL Editor** (di sidebar kiri)
2. Atau klik tombol **"Query"** atau **"SQL Editor"**

### 3. Jalankan Schema Script

1. Buka file `database/schema.sql` di folder backend
2. **Copy semua isi** file tersebut
3. **Paste** ke SQL Editor di Neon Console
4. Klik tombol **"Run"** atau tekan `Ctrl+Enter`

### 4. Verifikasi Tabel Dibuat

Setelah script berjalan, jalankan query ini untuk verifikasi:

```sql
-- Cek tabel sensor_data
SELECT * FROM sensor_data LIMIT 1;

-- Cek tabel kontrol_perangkat
SELECT * FROM kontrol_perangkat;

-- Cek tabel notifikasi
SELECT * FROM notifikasi LIMIT 1;
```

Jika tidak ada error, berarti tabel berhasil dibuat! ✅

---

## Schema yang Akan Dibuat

### 1. Tabel `sensor_data`
- Menyimpan data sensor (CO₂, CO, Debu)
- Digunakan untuk ALUR 1 & 2

### 2. Tabel `kontrol_perangkat`
- Menyimpan status kontrol (Fan ON/OFF, Mode Auto/Manual)
- Digunakan untuk ALUR 3

### 3. Tabel `notifikasi`
- Menyimpan notifikasi (opsional)
- Untuk fitur notifikasi di aplikasi

---

## Troubleshooting

### Error: "relation already exists"
- Tabel sudah ada, tidak masalah
- Script menggunakan `CREATE TABLE IF NOT EXISTS`, jadi aman dijalankan ulang

### Error: "permission denied"
- Pastikan Anda login dengan akun yang memiliki akses ke database
- Cek connection string yang digunakan

### Error: "syntax error"
- Pastikan copy-paste semua isi file `schema.sql`
- Jangan ada karakter yang terpotong

---

## Test Insert Data Manual

Setelah schema dibuat, Anda bisa test insert data:

```sql
-- Insert data sensor test
INSERT INTO sensor_data (nilai_co2, nilai_co, nilai_debu)
VALUES (500, 2, 15);

-- Lihat data yang baru diinsert
SELECT * FROM sensor_data ORDER BY waktu DESC LIMIT 5;
```

Jika berhasil, berarti database siap digunakan! 🎉

