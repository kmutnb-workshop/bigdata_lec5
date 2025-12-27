1) ทำไม Python ต้องใช้ indentation และเกิดอะไรขึ้นถ้าเยื้องผิด?

Python ใช้ indentation เพื่อกำหนดขอบเขตของ block คำสั่ง แทนการใช้ {}
ถ้าเยื้องผิด → โปรแกรมจะ error (IndentationError) หรือ logic ผิด ทำให้ flow การทำงานคลาดเคลื่อน

⸻

2) ความต่างของ list กับ dict คืออะไร และเหมาะกับข้อมูลแบบไหน?
	•	list: เก็บข้อมูลหลายรายการแบบเรียงลำดับ เหมาะกับ “หลายแถว”
	•	dict: เก็บข้อมูลแบบ key–value เหมาะกับ “ข้อมูล 1 record/1 แถว”
ในงาน ETL มักใช้ list ของ dict เพื่อแทนหลาย record

⸻

3) Pandas กับ Polars ต่างกันอย่างไรในมุมงาน ETL?
	•	Pandas: ใช้ง่าย เหมาะกับข้อมูลขนาดเล็ก–กลาง แต่ช้าลงเมื่อข้อมูลใหญ่
	•	Polars: เร็วกว่า ใช้ columnar + parallel execution รองรับ Lazy execution
งาน ETL ขนาดใหญ่ → Polars เหมาะกว่า

⸻

4) Eager และ Lazy ใน Polars ต่างกันอย่างไร และควรใช้แบบไหน?
	•	Eager: คำนวณทันที เหมาะกับงานเล็กหรือ exploratory
	•	Lazy: สร้างแผนก่อนคำนวณจริง ช่วย optimize pipeline
งาน ETL ยาว/ข้อมูลใหญ่ → ควรใช้ Lazy

⸻

5) เหตุผลหลักที่นิยมใช้ Parquet ใน Data Lake คืออะไร?
	•	เป็น columnar format
	•	ขนาดไฟล์เล็ก (compression ดี)
	•	อ่านเฉพาะ column ที่ต้องใช้ → เร็ว
	•	เหมาะกับ analytics และ cloud storage

⸻

6) ตัวอย่าง Data Quality check อย่างน้อย 4 รายการ
	1.	Row count check: จำนวนแถวก่อน–หลัง transform
	2.	Null check: ตรวจค่า missing ต่อคอลัมน์
	3.	Uniqueness check: เช่น user_id ต้องไม่ซ้ำ
	4.	Range check: salary ต้องอยู่ในช่วงที่กำหนด
(เสริมได้: distribution check, consistency check)

⸻

7) ถ้าเขียน Parquet ไป MinIO แล้วอ่านกลับไม่ได้ จะตรวจอะไรบ้าง?

ตรวจตามลำดับ:
	1.	Endpoint (http://minio:9000 ถูกไหม)
	2.	Bucket / Path (มี bucket และ path จริงไหม)
	3.	Credential (access key / secret ถูกต้องไหม)
	4.	storage_options / s3fs config
	5.	ดู error log เพื่อแยก permission vs network