# 🚀 Quick Deploy Guide

## ✅ Step 1: GitHub (DONE!)
✅ Code sudah di-upload ke: https://github.com/aiakira/Smart-Air-Monitoring

## 🌐 Step 2: Deploy ke Vercel (5 Menit)

### A. Import Project
1. Buka: **https://vercel.com**
2. Login dengan GitHub
3. Klik **"Add New..."** → **"Project"**
4. Pilih **"Smart-Air-Monitoring"**
5. Klik **"Import"**

### B. Add Environment Variable
```
DATABASE_URL=postgresql://neondb_owner:npg_U7IHN4rFmCVs@ep-lucky-darkness-a15k13s2-pooler.ap-southeast-1.aws.neon.tech/neondb?sslmode=require&channel_binding=require
```

### C. Deploy
Klik **"Deploy"** → Tunggu 2-5 menit → Done! 🎉

## 📊 Step 3: Setup Database (2 Menit)

### A. Create Indexes
Buka Neon Console → SQL Editor → Run:
```sql
CREATE INDEX IF NOT EXISTS idx_sensor_timestamp ON sensor_data(timestamp DESC);
CREATE INDEX IF NOT EXISTS idx_kontrol_waktu ON kontrol(waktu DESC);
CREATE INDEX IF NOT EXISTS idx_notifications_created ON notifications(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_notifications_unread ON notifications(is_read) WHERE is_read = false;
```

### B. Initialize Functions
```bash
curl -X POST https://your-app.vercel.app/api/init-db
```

## ✅ Done!

Your app is live at: **https://your-app.vercel.app**

---

**Full Guide:** NEXT_STEPS.md
