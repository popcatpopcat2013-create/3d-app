# Photo Swipe

คัดรูปในเครื่องแบบ Tinder: **ปัดขวา = เก็บ, ปัดซ้าย = ทิ้ง**

- รูปที่ปัดซ้ายไปรอในถังขยะของแอปก่อน ยังไม่ถูกลบออกจากเครื่อง กู้คืนได้
- กด "ล้างถังขยะ" แล้วยืนยัน จึงลบรูปออกจากเครื่องจริง
- ปิดแอปแล้วกลับมา แอปจำได้ว่าปัดถึงรูปไหนแล้ว
- รูปทั้งหมดอยู่ในเครื่อง ไม่มีการอัปโหลดไปที่ไหน

(Android เท่านั้น แจกเป็นไฟล์ APK)

---

## สำหรับคนโหลดแอป

1. ไปที่หน้า **Releases** ของ repo นี้ แล้วโหลดไฟล์ `.apk` ล่าสุด
2. เปิดไฟล์บนมือถือ ถ้าเครื่องถาม ให้อนุญาต "ติดตั้งแอปจากแหล่งที่ไม่รู้จัก"
3. ถ้า Play Protect เตือน เพราะแอปไม่ได้มาจาก Play Store ให้เลือก "ติดตั้งต่อไป"
4. เปิดแอป กด "อนุญาต" เมื่อแอปขอเข้าถึงรูปภาพ

---

## สำหรับเจ้าของโปรเจกต์: ขั้นตอนอัปขึ้น GitHub (ทำใน Codespace)

### ครั้งแรก

1. สร้าง repo ว่างบน GitHub (ไม่ต้องติ๊กสร้าง README)
2. เปิด Codespace ของ repo นั้น (ปุ่ม **Code → Codespaces → Create**)
3. ลากไฟล์ `photo_swipe.zip` ไปวางในช่อง Explorer ด้านซ้ายของ Codespace
4. ใน terminal ด้านล่าง พิมพ์ (ก๊อปวางได้เลย):

```bash
unzip -o photo_swipe.zip
cp -r photo_swipe/. .
rm -rf photo_swipe photo_swipe.zip
git add .
git commit -m "Round 1: swipe, trash, permission"
git push
```

5. ไปที่แท็บ **Actions** บน GitHub จะเห็นงาน "Build APK" กำลังทำ รอประมาณ 5-10 นาที
6. เมื่อเสร็จ (เครื่องหมายถูกสีเขียว) เปิดงานนั้น เลื่อนลงไปส่วน **Artifacts** จะมีไฟล์ APK ให้โหลดไปลองบนมือถือ

### ออก Release ให้คนอื่นโหลด

เมื่อทดสอบแล้วโอเค ติดป้ายเวอร์ชัน:

```bash
git tag v0.1.0
git push origin v0.1.0
```

GitHub จะสร้าง APK แล้วแนบในหน้า **Releases** ให้เอง (ครั้งต่อไปเปลี่ยนเลขเป็น v0.2.0 ฯลฯ)

### ถ้า build ไม่ผ่าน

เปิดงานที่ขึ้นเครื่องหมายแดงในแท็บ Actions กดดูขั้นตอนที่ล้มเหลว
ก๊อปข้อความ error ส่งกลับมาให้ Claude พร้อมบอกว่าเป็นขั้นตอนไหน

### ครั้งต่อไปที่ได้ zip ใหม่

```bash
git checkout -b feature/ชื่อฟีเจอร์        # แยก branch กันพัง
unzip -o photo_swipe.zip
cp -r photo_swipe/. .
rm -rf photo_swipe photo_swipe.zip
git add .
git commit -m "อธิบายสั้นๆ ว่าเพิ่มอะไร"
git push -u origin feature/ชื่อฟีเจอร์
```

แล้วเปิด Pull Request บน GitHub เพื่อรวมเข้า `main` (Actions จะ build ตอนรวมแล้ว)
ถ้าของใหม่พัง แค่ไม่ merge branch นั้น ของเดิมก็ยังอยู่

---

## Signing key (ควรทำก่อนแจกให้คนอื่น)

ถ้าไม่ทำ ทุกครั้งที่ build จะได้กุญแจใหม่ ผู้ใช้ต้อง **ถอนการติดตั้งของเก่าก่อน**
จึงจะลงเวอร์ชันใหม่ได้ ทำครั้งเดียวแล้วอัปเดตทับกันได้เลย:

1. ใน terminal ของ Codespace สร้างกุญแจ:

```bash
keytool -genkey -v -keystore debug.keystore -storepass android -alias androiddebugkey -keypass android -keyalg RSA -keysize 2048 -validity 10000 -dname "CN=Android Debug,O=Android,C=US"
base64 -w0 debug.keystore
```

2. ก๊อปข้อความยาวๆ ที่ได้จากคำสั่ง `base64`
3. บน GitHub: **Settings → Secrets and variables → Actions → New repository secret**
   - Name: `DEBUG_KEYSTORE_BASE64`
   - Secret: วางข้อความที่ก๊อปมา
4. **เก็บไฟล์ `debug.keystore` ไว้ในที่ปลอดภัยนอก repo** (เช่นอีเมลหาตัวเอง) ถ้าหายจะอัปเดตทับเวอร์ชันเก่าไม่ได้
   ไฟล์ `*.keystore` ถูกตั้งไว้ใน `.gitignore` แล้ว จะไม่ถูกอัปขึ้น GitHub โดยบังเอิญ ห้ามเอาขึ้น repo

---

โครงสร้างโค้ดและกฎการเพิ่มฟีเจอร์อยู่ใน [ARCHITECTURE.md](ARCHITECTURE.md)
