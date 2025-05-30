# โปรเจกต์เซิร์ฟเวอร์ Delphi DataSnap

## ภาพรวมโปรเจกต์

โปรเจกต์นี้จัดทำแอปพลิเคชันเซิร์ฟเวอร์ DataSnap โดยใช้ Delphi มันจัดเตรียมเซิร์ฟเวอร์ HTTP อย่างง่ายที่เปิดเผยเมธอดการจัดการสตริงต่างๆ ผ่าน RESTful API แอปพลิเคชันทำงานเป็นแอปพลิเคชันคอนโซล อนุญาตให้ผู้ใช้ควบคุมเซิร์ฟเวอร์ผ่านคำสั่งบรรทัดคำสั่ง

## คอมโพเนนต์หลัก

### โปรแกรมหลัก (DelphiDS.dpr)

ไฟล์โปรแกรมหลักที่เริ่มต้นและรันเซิร์ฟเวอร์ DataSnap มันจัดเตรียมอินเทอร์เฟซคอนโซลสำหรับ:
- เริ่มและหยุดเซิร์ฟเวอร์
- เปลี่ยนพอร์ตเซิร์ฟเวอร์
- แสดงสถานะเซิร์ฟเวอร์
- จัดการคำสั่งผ่านอินเทอร์เฟซบรรทัดคำสั่ง

### โมดูลเซิร์ฟเวอร์

1. **ServerMethodsUnit1.pas**
   - ประกอบด้วยเมธอดของเซิร์ฟเวอร์หลักที่สามารถเรียกใช้จากระยะไกล
   - จัดทำเมธอดการจัดการสตริงอย่างง่าย:
     - `EchoString`: ส่งคืนสตริงที่ป้อนเข้าโดยไม่มีการเปลี่ยนแปลง
     - `ReverseString`: กลับด้านสตริงที่ป้อนเข้ามา
     - `ToUpperCase`: แปลงสตริงที่ป้อนเข้ามาเป็นตัวพิมพ์ใหญ่
     - `ToLowerCase`: แปลงสตริงที่ป้อนเข้ามาเป็นตัวพิมพ์เล็ก

2. **ServerContainerUnit1.pas**
   - จัดการคอมโพเนนต์เซิร์ฟเวอร์ DataSnap
   - สร้างและรักษาอินสแตนซ์เซิร์ฟเวอร์
   - ลงทะเบียนคลาสเซิร์ฟเวอร์

3. **WebModuleUnit1.pas**
   - จัดการคำขอ HTTP ไปยังเซิร์ฟเวอร์
   - จัดการอินเทอร์เฟซเว็บสำหรับฟังก์ชันเซิร์ฟเวอร์
   - ควบคุมการเข้าถึงตัวเรียกฟังก์ชันเซิร์ฟเวอร์ (จำกัดเฉพาะ localhost)
   - สร้างไฟล์พร็อกซี JavaScript สำหรับการโต้ตอบฝั่งไคลเอนต์

4. **ServerConst1.pas**
   - ประกอบด้วยค่าคงที่และสตริงทรัพยากรที่ใช้ทั่วทั้งแอปพลิเคชัน
   - รวมศูนย์ข้อความผู้ใช้และสตริงคำสั่ง

## คอมโพเนนต์ฝั่งไคลเอนต์

เซิร์ฟเวอร์สร้างไฟล์พร็อกซี JavaScript โดยอัตโนมัติที่ไคลเอนต์สามารถใช้เพื่อเรียกเมธอดของเซิร์ฟเวอร์:

- `js/serverfunctions.js`: ประกอบด้วยพร็อกซีสำหรับเมธอดของเซิร์ฟเวอร์
- `js/serverfunctioninvoker.js`: จัดเตรียมอินเทอร์เฟซผู้ใช้สำหรับทดสอบเมธอดเซิร์ฟเวอร์
- `js/json2.js`: จัดการการแปลงข้อมูล JSON

## วิธีการใช้งาน

1. **เริ่มเซิร์ฟเวอร์**:
   - รันไฟล์ปฏิบัติการ DelphiDS
   - พิมพ์ `start` ที่พรอมต์เพื่อเริ่มเซิร์ฟเวอร์ (พอร์ตเริ่มต้น 8989)

2. **จัดการเซิร์ฟเวอร์**:
   - `stop`: หยุดเซิร์ฟเวอร์
   - `status`: แสดงสถานะปัจจุบันของเซิร์ฟเวอร์
   - `set port [number]`: เปลี่ยนพอร์ตเซิร์ฟเวอร์
   - `help`: แสดงคำสั่งที่มี
   - `exit`: ออกจากแอปพลิเคชัน

3. **เข้าถึงฟังก์ชันเซิร์ฟเวอร์**:
   - จากเว็บเบราว์เซอร์บนเครื่องท้องถิ่น เยี่ยมชม: `http://localhost:8989/`
   - คลิกที่ลิงก์ "Server Functions" เพื่อเข้าถึงอินเทอร์เฟซตัวเรียกฟังก์ชัน
   - ฟังก์ชันเซิร์ฟเวอร์สามารถเรียกใช้ผ่านคำขอ HTTP โดยใช้รูปแบบ URL ที่เหมาะสมได้ด้วย

## บันทึกการพัฒนา

- เซิร์ฟเวอร์อนุญาตให้เข้าถึงตัวเรียกฟังก์ชันเซิร์ฟเวอร์จากโลคัลโฮสต์ (127.0.0.1 หรือ ::1) เท่านั้น เพื่อเหตุผลด้านความปลอดภัย
- โปรเจกต์ใช้คอมโพเนนต์ Indy สำหรับการสื่อสาร HTTP
- DataSnap จัดการการแปลงพารามิเตอร์และผลลัพธ์โดยอัตโนมัติ
- เมื่อแอปพลิเคชันเซิร์ฟเวอร์ได้รับการอัปเดต ไฟล์พร็อกซี JavaScript จะถูกสร้างขึ้นใหม่โดยอัตโนมัติ

## การขยายโปรเจกต์

ในการเพิ่มเมธอดเซิร์ฟเวอร์ใหม่:

1. เพิ่มประกาศเมธอดใหม่ไปยัง `TServerMethods1` ใน `ServerMethodsUnit1.pas`
2. ใส่การทำงานของเมธอดในส่วนการทำงาน (implementation section)
3. รีสตาร์ทเซิร์ฟเวอร์เพื่อทำให้เมธอดใหม่พร้อมใช้งาน

## ข้อควรพิจารณาด้านความปลอดภัย

- ตัวเรียกฟังก์ชันเซิร์ฟเวอร์สามารถเข้าถึงได้จากโลคัลโฮสต์เท่านั้น
- พิจารณาการนำการยืนยันตัวตนไปใช้สำหรับการใช้งานในระบบการผลิต
- ตรวจสอบการตั้งค่าการควบคุมการเข้าถึงก่อนที่จะปรับใช้ในสภาพแวดล้อมการผลิต