# 🚀 Panduan Deployment ke Vercel

## Langkah 1: Persiapan GitHub

### 1.1 Initialize Git (jika belum)
```bash
git init
```

### 1.2 Cek Status File
```bash
git status
```

### 1.3 Add All Files
```bash
git add .
```

### 1.4 Commit
```bash
git commit -m "Initial commit: Smart Air Monitor v1.0"
```

### 1.5 Create Repository di GitHub

1. Buka [github.com](https://github.com)
2. Klik tombol **"New"** atau **"+"** → **"New repository"**
3. Isi detail:
   - **Repository name:** `smart-air-monitor`
   - **Description:** `Sistem monitoring kualitas udara real-time`
   - **Visibility:** Public atau Private (pilih sesuai kebutuhan)
   - **JANGAN** centang "Initialize with README" (sudah ada)
4. Klik **"Create repository"**

### 1.6 Push ke GitHub

GitHub akan memberikan instruksi, jalankan:

```bash
# Ganti dengan URL repository Anda
git remote add origin https://github.com/yourusername/smart-air-monitor.git
git branch -M main
git push -u origin main
```

**Atau jika sudah ada remote:**
```bash
git push origin main
```

## Langkah 2: Deploy ke Vercel

### 2.1 Buat Akun Vercel

1. Buka [vercel.com](https://vercel.com)
2. Klik **"Sign Up"**
3. Pilih **"Continue with GitHub"**
4. Authorize Vercel untuk akses GitHub

### 2.2 Import Project

1. Di Vercel Dashboard, klik **"Add New..."** → **"Project"**
2. Pilih repository **"smart-air-monitor"**
3. Klik **"Import"**

### 2.3 Configure Project

**Framework Preset:** Next.js (auto-detected)

**Root Directory:** `./` (default)

**Build Command:** `npm run build` (default)

**Output Directory:** `.next` (default)

### 2.4 Environment Variables

Klik **"Environment Variables"** dan tambahkan:

```
Name: DATABASE_URL
Value: postgresql://neondb_owner:npg_U7IHN4rFmCVs@ep-lucky-darkness-a15k13s2-pooler.ap-southeast-1.aws.neon.tech/neondb?sslmode=require&channel_binding=require
```

**PENTING:** Gunakan DATABASE_URL production Anda, bukan yang di .env.local!

### 2.5 Deploy

1. Klik **"Deploy"**
2. Tunggu proses build (2-5 menit)
3. Selesai! 🎉

## Langkah 3: Setup Database untuk Production

### 3.1 Jalankan Database Indexes

1. Buka [Neon DB Console](https://console.neon.tech)
2. Pilih project Anda
3. Buka **SQL Editor**
4. Copy-paste isi file `DATABASE_INDEXES.sql`
5. Klik **"Run"**

```sql
CREATE INDEX IF NOT EXISTS idx_sensor_timestamp ON sensor_data(timestamp DESC);
CREATE INDEX IF NOT EXISTS idx_kontrol_waktu ON kontrol(waktu DESC);
CREATE INDEX IF NOT EXISTS idx_notifications_created ON notifications(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_notifications_unread ON notifications(is_read) WHERE is_read = false;
```

### 3.2 Initialize Database Functions (jika belum)

Akses URL production Anda:
```
https://your-app.vercel.app/api/init-db
```

Method: POST

Atau gunakan curl:
```bash
curl -X POST https://your-app.vercel.app/api/init-db
```

### 3.3 Seed Data (opsional)

```bash
curl -X POST https://your-app.vercel.app/api/seed-data
```

## Langkah 4: Verifikasi Deployment

### 4.1 Test API Endpoints

```bash
# Ganti dengan URL Anda
export APP_URL=https://your-app.vercel.app

# Test database
curl $APP_URL/api/test-db

# Test sensor data
curl $APP_URL/api/sensors/latest

# Test control
curl $APP_URL/api/control
```

### 4.2 Test di Browser

1. Buka `https://your-app.vercel.app`
2. Cek Dashboard - harus load data
3. Cek Grafik - harus tampil chart
4. Cek Notifikasi - harus tampil list
5. Test Fan Control - harus bisa ON/OFF

### 4.3 Cek Performance

1. Buka Chrome DevTools (F12)
2. Tab **Network** - cek response time
3. Tab **Console** - pastikan tidak ada error
4. Tab **Lighthouse** - run audit

**Target:**
- Performance: > 90
- Accessibility: > 90
- Best Practices: > 90
- SEO: > 90

## Langkah 5: Custom Domain (Opsional)

### 5.1 Beli Domain

Beli domain dari:
- Namecheap
- GoDaddy
- Cloudflare
- dll

### 5.2 Setup di Vercel

1. Di Vercel Dashboard → Project Settings
2. Klik **"Domains"**
3. Klik **"Add"**
4. Masukkan domain Anda (contoh: `airmonitor.com`)
5. Follow instruksi untuk setup DNS

### 5.3 Configure DNS

Di provider domain Anda, tambahkan record:

**A Record:**
```
Type: A
Name: @
Value: 76.76.21.21
```

**CNAME Record:**
```
Type: CNAME
Name: www
Value: cname.vercel-dns.com
```

Tunggu propagasi DNS (5-30 menit).

## Langkah 6: Monitoring & Maintenance

### 6.1 Setup Vercel Analytics

1. Di Vercel Dashboard → Project
2. Tab **"Analytics"**
3. Enable Analytics
4. Gratis untuk hobby plan!

### 6.2 Setup Error Tracking (Opsional)

**Sentry:**
```bash
npm install @sentry/nextjs
npx @sentry/wizard@latest -i nextjs
```

### 6.3 Scheduled Cleanup

**Option 1: Vercel Cron Jobs**

Buat file `vercel.json`:
```json
{
  "crons": [{
    "path": "/api/cleanup",
    "schedule": "0 0 * * 0"
  }]
}
```

**Option 2: Manual**

Jalankan setiap minggu:
```bash
curl -X POST https://your-app.vercel.app/api/cleanup
```

## Langkah 7: Update & Redeploy

### 7.1 Update Code

```bash
# Edit files
git add .
git commit -m "Update: description of changes"
git push origin main
```

### 7.2 Auto Deploy

Vercel akan otomatis deploy setiap push ke `main` branch!

### 7.3 Preview Deployments

Setiap push ke branch lain akan create preview deployment:
```bash
git checkout -b feature/new-feature
# Edit files
git push origin feature/new-feature
```

Vercel akan comment di PR dengan preview URL.

## Troubleshooting

### Build Failed

**Error:** `Module not found`
```bash
# Pastikan dependencies terinstall
npm install
git add package-lock.json
git commit -m "Update dependencies"
git push
```

**Error:** `TypeScript errors`
```bash
# Fix TypeScript errors locally
npm run build
# Fix errors, then push
```

### Database Connection Failed

1. Cek DATABASE_URL di Vercel Environment Variables
2. Pastikan Neon DB tidak sleep (free tier)
3. Test koneksi: `curl https://your-app.vercel.app/api/test-db`

### Slow Performance

1. Jalankan database indexes (Langkah 3.1)
2. Enable Vercel Analytics
3. Cek Neon DB metrics
4. Consider upgrade Neon DB plan

### 404 Not Found

1. Cek routing di `app/` folder
2. Clear Vercel cache: Redeploy
3. Cek build logs di Vercel

## Checklist Deployment

- [ ] Git repository created
- [ ] Code pushed to GitHub
- [ ] Vercel account created
- [ ] Project imported to Vercel
- [ ] DATABASE_URL configured
- [ ] First deployment successful
- [ ] Database indexes created
- [ ] Database functions initialized
- [ ] All pages working
- [ ] All API endpoints working
- [ ] Performance tested
- [ ] Mobile responsive tested
- [ ] Error handling tested
- [ ] Analytics enabled
- [ ] Custom domain configured (optional)
- [ ] Cleanup cron scheduled

## Post-Deployment

### Share Your App

```
🌬️ Smart Air Monitor
Monitor kualitas udara real-time

🔗 Live: https://your-app.vercel.app
📱 Mobile-friendly
🌙 Dark mode support
📊 Real-time charts

Built with Next.js + PostgreSQL
```

### Monitor Usage

- Vercel Dashboard → Analytics
- Neon DB Dashboard → Metrics
- Check logs regularly

### Backup

```bash
# Backup database (di Neon Console)
# Export → Download SQL

# Backup code (already in GitHub)
git pull origin main
```

## Support

Jika ada masalah:
1. Cek Vercel build logs
2. Cek browser console
3. Cek Neon DB status
4. Buka issue di GitHub

---

**Selamat! Aplikasi Anda sudah live! 🎉**

URL: `https://your-app.vercel.app`

Share dengan teman dan kolega! 🚀
