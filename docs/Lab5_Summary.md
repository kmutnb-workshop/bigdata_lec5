# สรุปเนื้อหา Lab 5: High-Performance ETL with Pandas vs Polars

## 📋 สารบัญ
1. [ภาพรวมโปรเจค](#ภาพรวมโปรเจค)
2. [แนวคิดหลัก](#แนวคิดหลัก)
3. [สถาปัตยกรรมและเทคโนโลยี](#สถาปัตยกรรมและเทคโนโลยี)
4. [รายละเอียดการทำงานแต่ละส่วน](#รายละเอียดการทำงานแต่ละส่วน)
5. [ผลลัพธ์และบทสรุป](#ผลลัพธ์และบทสรุป)
6. [สรุปการเรียนรู้](#สรุปการเรียนรู้)

---

## ภาพรวมโปรเจค

### วัตถุประสงค์
โปรเจคนี้เป็นการบ้าน Lab 5 ที่มีวัตถุประสงค์หลัก 4 ข้อ:

1. **เปรียบเทียบประสิทธิภาพ** Pandas vs Polars ด้วยข้อมูล 1,000,000 records
2. **ตรวจสอบ Data Quality (DQ)** ด้วยการสร้าง age_outlier flag
3. **สร้าง Gold Table** สำหรับ KPI analysis โดยสรุปข้อมูลตาม salary_class
4. **ออกแบบ Partition Structure** สำหรับ Data Lake ตาม signup_date

### ขอบเขตการทำงาน
- สร้างข้อมูล mock จำนวน 1,000,000 records
- ทำ ETL (Extract, Transform, Load) ด้วย Pandas และ Polars
- วัดประสิทธิภาพและเปรียบเทียบ
- ตรวจสอบคุณภาพข้อมูล (Data Quality)
- สร้าง Gold Table และเขียนลง MinIO
- ออกแบบและสร้าง Partition Structure
- สร้าง Data Quality Audit Report

---

## แนวคิดหลัก

### 1. ETL (Extract, Transform, Load)
**ETL** เป็นกระบวนการพื้นฐานในการจัดการข้อมูล:

- **Extract (ดึงข้อมูล)**: ดึงข้อมูลจากแหล่งต่างๆ (ในกรณีนี้คือการสร้างข้อมูล mock)
- **Transform (แปลงข้อมูล)**: 
  - คำนวณอายุจากวันเกิด
  - Mask email (ปกปิดส่วนหลัง @)
  - สร้าง salary_class (Low, Medium, High)
  - สร้าง age_outlier flag
- **Load (โหลดข้อมูล)**: เขียนข้อมูลลง Data Lake (MinIO) ในรูปแบบ Parquet

### 2. Pandas vs Polars
**Pandas**:
- Library มาตรฐานสำหรับ data manipulation ใน Python
- ใช้ Python objects และ NumPy arrays
- เหมาะสำหรับข้อมูลขนาดเล็กถึงกลาง
- มี API ที่คุ้นเคยและใช้งานง่าย

**Polars**:
- High-performance DataFrame library
- ใช้ Apache Arrow เป็น backend
- รองรับ Lazy Evaluation (query optimization)
- รองรับ parallel processing
- เหมาะสำหรับข้อมูลขนาดใหญ่ (millions+ records)
- เร็วกว่า Pandas หลายเท่า

**ความแตกต่างหลัก**:
- **Memory Layout**: Polars ใช้ columnar format (Apache Arrow) ซึ่งมีประสิทธิภาพสูงกว่า row-based format ของ Pandas
- **Query Optimization**: Polars Lazy mode สามารถ optimize query plan ได้ดีกว่า
- **Parallel Processing**: Polars รองรับ multi-threading โดยอัตโนมัติ

### 3. Data Quality (DQ)
**Data Quality** คือการตรวจสอบคุณภาพของข้อมูลเพื่อให้มั่นใจว่าข้อมูลมีความถูกต้อง ครบถ้วน และพร้อมใช้งาน

**DQ Checks ที่ใช้ในโปรเจค**:
1. **Age Outlier Detection**: ตรวจสอบอายุที่ผิดปกติ (< 18 หรือ > 80)
2. **Null Value Check**: ตรวจสอบค่าที่เป็น null ในแต่ละคอลัมน์
3. **Duplicate Check**: ตรวจสอบ user_id ที่ซ้ำกัน
4. **Salary Range Validation**: ตรวจสอบช่วงเงินเดือน
5. **Email Format Validation**: ตรวจสอบรูปแบบ email
6. **Age Range Validation**: ตรวจสอบช่วงอายุ

### 4. Data Lake และ Partitioning
**Data Lake** คือที่เก็บข้อมูลขนาดใหญ่ในรูปแบบดิบ (raw format) เช่น Parquet

**Partitioning** คือการจัดระเบียบข้อมูลโดยแยกตามคอลัมน์ที่สำคัญ (เช่น year, month) เพื่อ:
- เพิ่มประสิทธิภาพในการ query (อ่านเฉพาะ partition ที่ต้องการ)
- ลด cost ในการอ่านข้อมูล
- ง่ายต่อการจัดการข้อมูล (retention, backup)

**Hive-Style Partitioning**: ใช้รูปแบบ `key=value/` เช่น `year=2020/month=01/` ซึ่งเป็นมาตรฐานที่ tools หลายตัวรองรับ

### 5. Gold Table
**Gold Table** คือข้อมูลที่ผ่านการ clean, transform, และ aggregate แล้ว พร้อมสำหรับการวิเคราะห์และรายงาน

ในโปรเจคนี้ Gold Table สรุป KPI ตาม salary_class:
- count: จำนวน records
- avg_age: อายุเฉลี่ย
- avg_salary: เงินเดือนเฉลี่ย
- min/max age และ salary

---

## สถาปัตยกรรมและเทคโนโลยี

### เทคโนโลยีที่ใช้

1. **Python 3.11**
   - ภาษาโปรแกรมหลัก

2. **Pandas**
   - Library สำหรับ data manipulation (baseline)

3. **Polars**
   - High-performance DataFrame library

4. **MinIO**
   - S3-compatible object storage (Data Lake)
   - Endpoint: `http://localhost:9000`
   - Console: `http://localhost:9001`

5. **s3fs**
   - Python library สำหรับเข้าถึง S3-compatible storage

6. **Faker**
   - Library สำหรับสร้างข้อมูล mock

7. **PyArrow**
   - Apache Arrow Python bindings (ใช้โดย Polars)

### โครงสร้าง Data Lake

```
s3://data/
├── gold/
│   └── users_kpi_by_salary_class.parquet
├── processed/
│   └── users/
│       ├── year=2020/
│       │   ├── month=01/
│       │   │   └── data.parquet
│       │   ├── month=02/
│       │   │   └── data.parquet
│       │   └── ...
│       ├── year=2021/
│       └── ...
└── audit/
    └── dq_report.json
```

---

## รายละเอียดการทำงานแต่ละส่วน

### ข้อ 1: เปรียบเทียบประสิทธิภาพ Pandas vs Polars

#### 1.1 การสร้างข้อมูล
- สร้างข้อมูล mock จำนวน 1,000,000 records
- ใช้ Faker library เพื่อสร้างข้อมูลที่เหมือนจริง
- Fields: user_id, name, email, birthdate, salary, signup_date

#### 1.2 ETL Workload

**Pandas Workload**:
```python
def pandas_workload():
    # คำนวณอายุ
    pdf_etl["age"] = current_year - pdf_etl["birthdate"].dt.year
    
    # Mask email
    local_part = pdf_etl["email"].str.split("@").str[0]
    pdf_etl["masked_email"] = local_part + "@***.com"
    
    # สร้าง salary_class
    pdf_etl["salary_class"] = pd.cut(
        pdf_etl["salary"],
        bins=[-1, 50_000, 100_000, 10**9],
        labels=["Low", "Medium", "High"]
    )
    
    # Aggregate
    stats = pdf_etl.groupby("salary_class").agg(...)
    return stats
```

**Polars Workload (Lazy)**:
```python
def polars_workload():
    result = (
        df.lazy()
        .with_columns([
            # คำนวณอายุ
            (pl.lit(current_year) - pl.col("birthdate").dt.year())
                .cast(pl.Int32).alias("age"),
            # Mask email
            pl.concat_str([
                pl.col("email").str.split("@").list.get(0),
                pl.lit("@***.com")
            ]).alias("masked_email"),
            # สร้าง salary_class
            pl.when(pl.col("salary") > 100_000).then(pl.lit("High"))
              .when(pl.col("salary") > 50_000).then(pl.lit("Medium"))
              .otherwise(pl.lit("Low")).alias("salary_class")
        ])
        .group_by("salary_class")
        .agg([...])
        .collect()  # Execute query
    )
    return result
```

#### 1.3 Benchmark
- รัน 3 rounds + 1 warmup round
- วัดเวลาด้วย `time.perf_counter()`
- คำนวณค่าเฉลี่ยและ speedup

#### 1.4 ผลลัพธ์
จากผลการทดสอบ:
- **Pandas**: ~0.87 วินาที (baseline)
- **Polars**: ~0.015 วินาที
- **Speedup**: Polars เร็วกว่า Pandas ประมาณ **57 เท่า**

**สาเหตุที่ Polars เร็วกว่า**:
1. **Apache Arrow Backend**: ใช้ columnar in-memory format ที่มีประสิทธิภาพสูง
2. **Query Optimization**: Lazy mode สามารถ optimize query plan ได้ดี
3. **Parallel Processing**: รองรับ multi-threading โดยอัตโนมัติ
4. **Memory Efficiency**: ใช้ memory อย่างมีประสิทธิภาพมากกว่า

---

### ข้อ 2: Data Quality Check - Age Outlier Detection

#### 2.1 การสร้าง age_outlier Flag
```python
df_transformed = (
    df.lazy()
    .with_columns([
        # คำนวณอายุ
        (pl.lit(current_year) - pl.col("birthdate").dt.year())
            .cast(pl.Int32).alias("age"),
        # สร้าง age_outlier flag
        ((pl.col("age") < 18) | (pl.col("age") > 80))
            .alias("age_outlier")
    ])
    .collect()
)
```

#### 2.2 สรุป Outliers
- นับจำนวน outliers และ valid records
- คำนวณ percentage
- แสดงสถิติ (min, max, avg age)

#### 2.3 ผลลัพธ์
- **Total Outliers**: 229 records (0.02%)
- **Valid Records**: 999,771 records (99.98%)
- Outliers ส่วนใหญ่เป็นอายุ 81 ปี (เกิน 80)

---

### ข้อ 3: สร้าง Gold Table - KPI by Salary Class

#### 3.1 การสร้าง Gold Table
```python
gold_table = (
    df_transformed
    .group_by("salary_class")
    .agg([
        pl.len().alias("count"),
        pl.col("age").mean().alias("avg_age"),
        pl.col("salary").mean().alias("avg_salary"),
        pl.col("age").min().alias("min_age"),
        pl.col("age").max().alias("max_age"),
        pl.col("salary").min().alias("min_salary"),
        pl.col("salary").max().alias("max_salary"),
    ])
    .sort("avg_salary", descending=True)
)
```

#### 3.2 การเขียนลง MinIO
```python
gold_file_path = f"{BUCKET}/gold/users_kpi_by_salary_class.parquet"

with fs.open(gold_file_path, "wb") as f:
    gold_table.write_parquet(f)
```

#### 3.3 ผลลัพธ์
Gold Table แสดง KPI ตาม salary_class:
- **High**: 416,727 records, avg_salary = 124,979
- **Medium**: 416,364 records, avg_salary = 75,003
- **Low**: 166,909 records, avg_salary = 40,005

---

### ข้อ 4: ออกแบบ Partition Structure

#### 4.1 การสร้าง Partition Columns
```python
df_partitioned = (
    df_transformed
    .with_columns([
        pl.col("signup_date").dt.year().alias("year"),
        pl.col("signup_date").dt.month().alias("month"),
    ])
)
```

#### 4.2 การเขียน Partitioned Data
```python
# สำหรับแต่ละ year-month combination
for row in unique_partitions.iter_rows(named=True):
    year = row["year"]
    month = row["month"]
    
    # Filter data สำหรับ partition นี้
    partition_df = df_partitioned.filter(
        (pl.col("year") == year) & (pl.col("month") == month)
    )
    
    # ลบ partition columns (อยู่ใน path แล้ว)
    data_to_write = partition_df.drop(["year", "month"])
    
    # เขียนลง MinIO
    partition_path = f"{base_path}/year={year}/month={month:02d}/data.parquet"
    with fs.open(partition_path, "wb") as f:
        data_to_write.write_parquet(f)
```

#### 4.3 โครงสร้าง Partition
```
s3://data/processed/users/
├── year=2020/
│   ├── month=01/data.parquet (14,124 records)
│   ├── month=02/data.parquet (13,109 records)
│   └── ...
├── year=2021/
└── ...
```

**Total Partitions**: 72 partitions (6 years × 12 months)

#### 4.4 เหตุผลในการออกแบบ

1. **Hive-Style Partitioning**
   - ใช้รูปแบบ `year=YYYY/month=MM` ซึ่งเป็นมาตรฐาน
   - รองรับโดย Spark, Presto, Athena

2. **Query Performance**
   - อ่านเฉพาะ partition ที่ต้องการ
   - ลด I/O และเพิ่มความเร็ว

3. **Cost Optimization**
   - ลด cost ในการอ่านข้อมูล (เฉพาะ partition ที่ต้องการ)

4. **Data Management**
   - ง่ายต่อการจัดการ (retention, backup)
   - สามารถลบข้อมูลเก่าได้ง่าย

5. **Scalability**
   - แต่ละ partition สามารถ process แยกกันได้
   - เหมาะสำหรับข้อมูลขนาดใหญ่

6. **Time-based Queries**
   - signup_date มักถูก query ตามช่วงเวลา
   - Partition ตามเวลาจึงเหมาะสม

---

### ข้อ 5: Data Quality Audit Report

#### 5.1 DQ Checks ที่ทำ

1. **DQ001: Age Outlier Detection**
   - ตรวจสอบอายุ < 18 หรือ > 80
   - Status: WARNING (229 outliers, 0.02%)

2. **DQ002: Null Value Check**
   - ตรวจสอบ null values ในทุกคอลัมน์
   - Status: PASS (ไม่มี null values)

3. **DQ003: Duplicate User ID Check**
   - ตรวจสอบ user_id ที่ซ้ำกัน
   - Status: PASS (ไม่มี duplicates)

4. **DQ004: Salary Range Validation**
   - ตรวจสอบช่วงเงินเดือน (30,000 - 150,000)
   - Status: PASS (อยู่ในช่วงที่กำหนด)

5. **DQ005: Email Format Validation**
   - ตรวจสอบรูปแบบ email (ต้องมี @)
   - Status: PASS (ทุก email ถูกต้อง)

6. **DQ006: Age Range Validation**
   - ตรวจสอบช่วงอายุ (18 - 80)
   - Status: WARNING (มีอายุ 81 ปี)

#### 5.2 Audit Report Structure
```json
{
  "audit_timestamp": "2025-12-27T10:18:21.178312",
  "dataset_name": "users_dataset",
  "total_records": 1000000,
  "data_quality_checks": [
    {
      "check_id": "DQ001",
      "check_name": "Age Outlier Detection",
      "status": "WARNING",
      "outlier_count": 229,
      "outlier_percentage": 0.02,
      ...
    },
    ...
  ],
  "summary": {
    "total_checks": 6,
    "passed": 4,
    "warnings": 2,
    "failed": 0
  }
}
```

#### 5.3 การบันทึก Audit Report
- เขียนเป็น JSON ลง MinIO: `s3://data/audit/dq_report.json`
- ใช้สำหรับ tracking และ monitoring คุณภาพข้อมูล

---

## ผลลัพธ์และบทสรุป

### ผลลัพธ์ที่ได้

1. **Performance Benchmark**
   - Polars เร็วกว่า Pandas **57 เท่า** (0.015s vs 0.87s)
   - เหมาะสำหรับข้อมูลขนาดใหญ่

2. **Data Quality**
   - พบ outliers 229 records (0.02%)
   - ข้อมูลส่วนใหญ่มีคุณภาพดี (4/6 checks passed)

3. **Gold Table**
   - สร้าง KPI summary ตาม salary_class สำเร็จ
   - บันทึกลง MinIO: `s3://data/gold/users_kpi_by_salary_class.parquet`

4. **Partition Structure**
   - สร้าง 72 partitions (6 years × 12 months)
   - ใช้ Hive-style partitioning
   - บันทึกลง MinIO: `s3://data/processed/users/year=YYYY/month=MM/data.parquet`

5. **Audit Report**
   - สร้าง JSON report พร้อม 6 DQ checks
   - บันทึกลง MinIO: `s3://data/audit/dq_report.json`

### ไฟล์ที่สร้าง

1. **Gold Table**
   - Path: `s3://data/gold/users_kpi_by_salary_class.parquet`
   - Format: Parquet
   - Content: KPI summary by salary_class

2. **Partitioned Data**
   - Path: `s3://data/processed/users/year=YYYY/month=MM/data.parquet`
   - Format: Parquet
   - Content: User data partitioned by signup_date

3. **Audit Report**
   - Path: `s3://data/audit/dq_report.json`
   - Format: JSON
   - Content: Data Quality Audit Report

---

## สรุปการเรียนรู้

### สิ่งที่ได้เรียนรู้

1. **Polars vs Pandas**
   - Polars เหมาะสำหรับข้อมูลขนาดใหญ่
   - Lazy Evaluation ช่วย optimize query
   - Apache Arrow backend ให้ประสิทธิภาพสูง

2. **Data Quality**
   - สำคัญต่อการวิเคราะห์ข้อมูล
   - ควรตรวจสอบหลายมิติ (outliers, nulls, duplicates, ranges)
   - Audit Report ช่วยในการ tracking

3. **Data Lake Architecture**
   - Partitioning ช่วยเพิ่มประสิทธิภาพ
   - Hive-style partitioning เป็นมาตรฐาน
   - Gold Table สำหรับข้อมูลที่พร้อมวิเคราะห์

4. **ETL Best Practices**
   - ใช้ Lazy Evaluation เมื่อเป็นไปได้
   - วัดประสิทธิภาพและเปรียบเทียบ
   - ตรวจสอบคุณภาพข้อมูลก่อนใช้งาน

### Best Practices

1. **Performance**
   - ใช้ Polars สำหรับข้อมูลขนาดใหญ่
   - ใช้ Lazy Evaluation เพื่อ optimize query
   - วัดประสิทธิภาพและเปรียบเทียบ

2. **Data Quality**
   - ตรวจสอบหลายมิติ (outliers, nulls, duplicates)
   - สร้าง Audit Report เพื่อ tracking
   - กำหนด threshold ที่เหมาะสม

3. **Data Lake**
   - ใช้ Partitioning เพื่อเพิ่มประสิทธิภาพ
   - ใช้ Hive-style partitioning
   - แยกข้อมูลตาม use case (gold, processed, audit)

4. **Documentation**
   - บันทึก Audit Report
   - เก็บ metadata ของข้อมูล
   - สร้าง documentation ที่ชัดเจน

### ข้อควรระวัง

1. **Partition Skew**
   - บาง partition อาจมีข้อมูลมากเกินไป
   - ควรตรวจสอบ distribution

2. **Partition Granularity**
   - ไม่ควรเล็กเกินไป (มีไฟล์เยอะเกินไป)
   - ไม่ควรใหญ่เกินไป (ไม่มีประโยชน์)

3. **Memory Usage**
   - ข้อมูลขนาดใหญ่อาจใช้ memory มาก
   - ควรใช้ Lazy Evaluation และ streaming

---

## อ้างอิง

- [Polars Documentation](https://pola-rs.github.io/polars/)
- [Apache Arrow](https://arrow.apache.org/)
- [MinIO Documentation](https://min.io/docs/)
- [Parquet Format](https://parquet.apache.org/)
- [Hive Partitioning](https://cwiki.apache.org/confluence/display/Hive/LanguageManual+DDL#LanguageManualDDL-PartitionedTables)

---

**วันที่สร้าง**: 2025-12-27  
**เวอร์ชัน**: 1.0  
**ผู้สร้าง**: Lab 5 Homework Summary

