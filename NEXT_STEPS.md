# ✅ Code Berhasil di-Upload ke GitHub!

Repository: https://github.com/aiakira/Smart-Air-Monitoring

## 🚀 Langkah Selanjutnya: Deploy ke Vercel

### 1. Buka Vercel
- Go to: **https://vercel.com**
- Klik **"Sign Up"** atau **"Login"**
- Pilih **"Continue with GitHub"**

### 2. Import Project
1. Di Vercel Dashboard, klik **"Add New..."** → **"Project"**
2. Cari dan pilih repository: **"Smart-Air-Monitoring"**
3. Klik **"Import"**

### 3. Configure Project

**Framework Preset:** Next.js ✅ (auto-detected)

**Root Directory:** `./` (default)

**Build Command:** `npm run build` (default)

**Install Command:** `npm install` (default)

### 4. Environment Variables (PENTING!)

Klik **"Environment Variables"** dan tambahkan:

```
Name: DATABASE_URL
Value: postgresql://neondb_owner:npg_U7IHN4rFmCVs@ep-lucky-darkness-a15k13s2-pooler.ap-southeast-1.aws.neon.tech/neondb?sslmode=require&channel_binding=require
```

**⚠️ PENTING:** Pastikan DATABASE_URL benar!

### 5. Deploy!

1. Klik tombol **"Deploy"**
2. Tunggu proses build (2-5 menit) ☕
3. Selesai! 🎉

### 6. Setelah Deploy Berhasil

#### A. Setup Database Indexes (Penting untuk Performance!)

1. Buka **Neon DB Console**: https://console.neon.tech
2. Pilih project Anda
3. Buka **SQL Editor**
4. Jalankan query ini:

```sql
CREATE INDEX IF NOT EXISTS idx_sensor_timestamp ON sensor_data(timestamp DESC);
CREATE INDEX IF NOT EXISTS idx_kontrol_waktu ON kontrol(waktu DESC);
CREATE INDEX IF NOT EXISTS idx_notifications_created ON notifications(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_notifications_unread ON notifications(is_read) WHERE is_read = false;
```

#### B. Initialize Database Functions

Akses URL production Anda (ganti dengan URL Vercel Anda):

```
https://your-app.vercel.app/api/init-db
```

Method: **POST**

Atau gunakan curl:
```bash
curl -X POST https://your-app.vercel.app/api/init-db
```

#### C. Test Production

```bash
# Test database connection
curl https://your-app.vercel.app/api/test-db

# Test sensor data
curl https://your-app.vercel.app/api/sensors/latest

# Test control
curl https://your-app.vercel.app/api/control
```

### 7. Verifikasi di Browser

Buka URL production Anda dan test:

- ✅ Dashboard load dengan data
- ✅ Grafik tampil
- ✅ Notifikasi berfungsi
- ✅ Fan control berfungsi
- ✅ Responsive di mobile

## 📱 URL Production Anda

Setelah deploy, Vercel akan memberikan URL seperti:
```
https://smart-air-monitoring-xxx.vercel.app
```

## 🔄 Update Code di Masa Depan

Setiap kali Anda push ke GitHub, Vercel akan otomatis deploy!

```bash
# Edit code
git add .
git commit -m "Update: description"
git push origin main
```

Vercel akan otomatis build dan deploy dalam 2-3 menit.

## 🎯 Custom Domain (Opsional)

1. Di Vercel Dashboard → Project Settings
2. Klik **"Domains"**
3. Tambahkan domain Anda
4. Follow instruksi DNS setup

## 📊 Monitoring

### Vercel Analytics (Gratis!)
1. Di Vercel Dashboard → Project
2. Tab **"Analytics"**
3. Enable Analytics

### Check Logs
1. Di Vercel Dashboard → Project
2. Tab **"Deployments"**
3. Klik deployment → **"View Function Logs"**

## 🐛 Troubleshooting

### Build Failed?
1. Cek build logs di Vercel
2. Pastikan `npm run build` berhasil di local
3. Fix errors dan push lagi

### Database Connection Failed?
1. Cek DATABASE_URL di Vercel Environment Variables
2. Pastikan tidak ada typo
3. Test connection di Neon Console

### 500 Error?
1. Cek Function Logs di Vercel
2. Pastikan database functions sudah di-initialize
3. Cek database indexes sudah dibuat

## ✅ Checklist

- [x] Code di-upload ke GitHub
- [ ] Project di-import ke Vercel
- [ ] DATABASE_URL ditambahkan
- [ ] Deploy berhasil
- [ ] Database indexes dibuat
- [ ] Database functions initialized
- [ ] Test semua halaman
- [ ] Test semua API endpoints
- [ ] Vercel Analytics enabled

## 🎉 Selamat!

Aplikasi Anda akan segera live di internet!

**Repository:** https://github.com/aiakira/Smart-Air-Monitoring

**Next:** Deploy ke Vercel → https://vercel.com

---

**Need Help?**
- Vercel Docs: https://vercel.com/docs
- Neon Docs: https://neon.tech/docs
- Next.js Docs: https://nextjs.org/docs

Good luck! 🚀
