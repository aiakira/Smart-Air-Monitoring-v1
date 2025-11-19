# Setup Environment Variables untuk Backend API

## Connection String Neon DB (Updated)

**Recommended (with pooler)**:
```
postgresql://neondb_owner:npg_M6CXs9WzouNa@ep-calm-sea-a1mu5wbo-pooler.ap-southeast-1.aws.neon.tech/neondb?sslmode=require
```

**Unpooled (tanpa pgbouncer)**:
```
postgresql://neondb_owner:npg_M6CXs9WzouNa@ep-calm-sea-a1mu5wbo.ap-southeast-1.aws.neon.tech/neondb?sslmode=require
```

## Status

✅ File `.env` sudah dibuat/updated dengan connection string terbaru

## File .env

File `.env` di folder `backend/` berisi:

```env
PORT=3000
DATABASE_URL=postgresql://neondb_owner:npg_M6CXs9WzouNa@ep-calm-sea-a1mu5wbo-pooler.ap-southeast-1.aws.neon.tech/neondb?sslmode=require
```

## Langkah Selanjutnya

### 1. Setup Database Schema

1. Buka [Neon Console](https://console.neon.tech)
2. Pilih project Anda
3. Klik **SQL Editor**
4. Copy semua isi dari file `database/schema.sql`
5. Paste dan jalankan di SQL Editor
6. Pastikan semua tabel berhasil dibuat

### 2. Test Koneksi

Setelah file `.env` dibuat, test koneksi:

```bash
cd backend
npm start
```

Jika berhasil, Anda akan melihat:
```
✅ Connected to Neon DB: [timestamp]
🚀 Server running on http://localhost:3000
```

### 3. Test API

Buka browser atau gunakan cURL:

```bash
# Health check
curl http://localhost:3000/api/health

# Test insert data
curl -X POST http://localhost:3000/api/data/baru \
  -H "Content-Type: application/json" \
  -d '{"co2": 500, "co": 2, "debu": 15}'
```

---

## ⚠️ Catatan Keamanan

- **JANGAN** commit file `.env` ke Git (sudah ada di `.gitignore`)
- Connection string ini mengandung password, jangan share ke publik
- Untuk production, gunakan environment variables di hosting platform

---

## Update Connection String

Jika perlu update connection string, jalankan:

```powershell
cd backend
powershell -ExecutionPolicy Bypass -File update_env.ps1
```

Atau edit manual file `.env` di folder `backend/`.
