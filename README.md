
---
# 🤖 Telegram Auto Upload Bot

Bot ini akan membantumu **mengirim foto & video otomatis ke Group Topic di Telegram** berdasarkan nama folder.  
Cocok banget buat kamu yang ingin auto-upload konten secara praktis dan rapi!

---

## ✨ Fitur 
✅ Kirim otomatis ke Group Topic (nama topik = nama folder)  
✅ Dukungan file gambar & video (`.jpg`, `.png`, `.mp4`)  
✅ Caption otomatis dari nama file (tanpa ekstensi)  
✅ Progress bar  
✅ Anti spam – file yang sudah dikirim tidak akan dikirim ulang

---

## 🚀 Cara Pakai

1. **Siapkan Token Bot Telegram & Chat ID grup**
2. **Edit file `AutoUploader.sh`**, isi bagian:
   ```bash
   BOT_TOKEN="TOKEN_KAMU"
   CHAT_ID="-100XXXXXXXXXX" #Bisa digunakan untuk Group Topik atau Channel
   FOLDER_PATH="/path/ke/folder/Camera"
   DATA_FILE="path/ke/folder/DCIM"

3. Jalankan bot:
```
bash AutoUploader.sh
```



---

⚙️ Butuh Apa Aja? (Dependencies)

Semua tools ini sudah pre-installed di banyak Linux/Termux:

bash
curl
jq
find


Kalau belum ada, kamu bisa install via:
```
apt install bash curl jq findutils
```

---

🙌 Credits

Dibuat oleh :
[Enzyy](https://t.me/GoodayFreeze)

[Group Support](https://t.me/SharingUserbot)

Lisensi: MIT — bebas modif & pakai untuk non-komersial


---

![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)

---
