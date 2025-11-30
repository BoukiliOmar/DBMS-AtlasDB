"""
MNHS Hospital Management System
OPTIMIZED VERSION ALIGNED WITH LAB REQUIREMENTS
"""

import os
import mysql.connector
from mysql.connector import errorcode, Error
from dotenv import load_dotenv
import argparse
import logging

# Configure logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

# Load environment variables
load_dotenv()

# Database configuration matching lab example exactly
cfg = dict(
    host=os.getenv("MYSQL_HOST", "127.0.0.1"),
    port=int(os.getenv("MYSQL_PORT", "3306")),
    database=os.getenv("MYSQL_DB", "lab3"),
    user=os.getenv("MYSQL_USER", "mnhs_user"),
    password=os.getenv("MYSQL_PASSWORD", "STRONG_PASSWORD")
)

def get_connection():
    """Get database connection - matches lab example exactly"""
    try:
        return mysql.connector.connect(**cfg)
    except Error as e:
        logger.error(f"Database connection failed: {e}")
        raise

def list_patients_ordered_by_last_name(limit=20):
    """
    TASK 1: Print first twenty patients ordered by last name
    Matches lab example exactly
    """
    sql = """
    SELECT IID, FullName
    FROM Patient
    ORDER BY SUBSTRING_INDEX(FullName, ' ', -1), FullName
    LIMIT %s
    """
    
    with get_connection() as cnx:
        with cnx.cursor(dictionary=True) as cur:
            cur.execute(sql, (limit,))
            return cur.fetchall()

def schedule_appointment(caid, iid, staff_id, dep_id, date_str, time_str, reason):
    """
    TASK 2: Create clinical activity and appointment in one transaction
    Matches lab example structure exactly
    """
    ins_ca = """
    INSERT INTO ClinicalActivity(CAID, IID, STAFF_ID, DEP_ID, Date, Time)
    VALUES (%s, %s, %s, %s, %s, %s)
    """
    
    ins_appt = """
    INSERT INTO Appointment(AID, CAID, Reason, Status)
    VALUES (%s, %s, %s, 'Scheduled')
    """
    
    # Using CAID as AID for simplicity (as shown in lab example)
    aid = caid
    
    with get_connection() as cnx:
        try:
            with cnx.cursor() as cur:
                # Insert into ClinicalActivity
                cur.execute(ins_ca, (caid, iid, staff_id, dep_id, date_str, time_str))
                # Insert into Appointment
                cur.execute(ins_appt, (aid, caid, reason))
                cnx.commit()
        except Exception:
            cnx.rollback()
            raise

def check_low_stock():
    """
    TASK 3: List medications below ReorderLevel per hospital with left join
    Ensures medications without stock also appear
    """
    sql = """
    SELECT 
        h.Name AS HospitalName,
        m.MID, 
        m.Name AS MedicationName,
        COALESCE(s.Qty, 0) AS CurrentQuantity,
        COALESCE(s.ReorderLevel, 0) AS ReorderLevel,
        CASE 
            WHEN s.Qty IS NULL THEN 'NO STOCK'
            WHEN s.Qty <= s.ReorderLevel THEN 'LOW STOCK' 
            ELSE 'IN STOCK'
        END AS StockStatus
    FROM Medication m
    LEFT JOIN Stock s ON m.MID = s.MID
    LEFT JOIN Hospital h ON s.HID = h.HID
    WHERE s.Qty IS NULL OR s.Qty <= s.ReorderLevel
    ORDER BY h.Name, m.Name
    """
    
    with get_connection() as cnx:
        with cnx.cursor(dictionary=True) as cur:
            cur.execute(sql)
            return cur.fetchall()

def staff_share_analysis():
    """
    TASK 4: Staff appointment share within hospital
    Computes total appointments and percentage share
    """
    sql = """
    SELECT 
        s.STAFF_ID,
        s.FullName,
        h.Name AS HospitalName,
        COUNT(ca.CAID) AS TotalAppointments,
        ROUND(
            (COUNT(ca.CAID) * 100.0 / NULLIF(SUM(COUNT(ca.CAID)) OVER (PARTITION BY h.HID), 0)),
            2
        ) AS PercentageShare
    FROM Staff s
    JOIN ClinicalActivity ca ON s.STAFF_ID = ca.STAFF_ID
    JOIN Department d ON ca.DEP_ID = d.DEP_ID
    JOIN Hospital h ON d.HID = h.HID
    GROUP BY s.STAFF_ID, s.FullName, h.Name, h.HID
    ORDER BY h.Name, TotalAppointments DESC
    """
    
    with get_connection() as cnx:
        with cnx.cursor(dictionary=True) as cur:
            cur.execute(sql)
            return cur.fetchall()

# Additional function matching lab example
def insert_patient(iid, cin, full_name, birth, sex, blood, phone):
    """
    Additional function matching lab example exactly
    """
    sql = """
    INSERT INTO Patient(IID, CIN, FullName, Birth, Sex, BloodGroup, Phone)
    VALUES (%s, %s, %s, %s, %s, %s, %s)
    """
    
    with get_connection() as cnx:
        try:
            with cnx.cursor() as cur:
                cur.execute(sql, (iid, cin, full_name, birth, sex, blood, phone))
                cnx.commit()
        except Exception:
            cnx.rollback()
            raise

def main():
    """Main CLI application matching lab structure"""
    parser = argparse.ArgumentParser(description="MNHS CLI")
    sub = parser.add_subparsers(dest="cmd", required=True)
    
    # Task 1: list_patients
    sub.add_parser("list_patients")
    
    # Task 2: schedule_appt  
    appt = sub.add_parser("schedule_appt")
    appt.add_argument("--caid", type=int, required=True)
    appt.add_argument("--iid", type=int, required=True)
    appt.add_argument("--staff", type=int, required=True)
    appt.add_argument("--dep", type=int, required=True)
    appt.add_argument("--date", required=True)  # YYYY-MM-DD
    appt.add_argument("--time", required=True)  # HH:MM:SS
    appt.add_argument("--reason", required=True)
    
    # Task 3: low_stock
    sub.add_parser("low_stock")
    
    # Task 4: staff_share
    sub.add_parser("staff_share")
    
    args = parser.parse_args()
    
    if args.cmd == "list_patients":
        for row in list_patients_ordered_by_last_name():
            print(f"{row['IID']} {row['FullName']}")
            
    elif args.cmd == "schedule_appt":
        schedule_appointment(args.caid, args.iid, args.staff, args.dep,
                           args.date, args.time, args.reason)
        print("Appointment scheduled")
        
    elif args.cmd == "low_stock":
        results = check_low_stock()
        if results:
            current_hospital = None
            for item in results:
                if item['HospitalName'] != current_hospital:
                    current_hospital = item['HospitalName']
                    print(f"\n{current_hospital}:")
                status = "NO STOCK" if item['StockStatus'] == 'NO STOCK' else f"LOW STOCK ({item['CurrentQuantity']} units)"
                print(f"  {item['MedicationName']}: {status}")
        else:
            print("No low stock items found")
            
    elif args.cmd == "staff_share":
        results = staff_share_analysis()
        if results:
            current_hospital = None
            for staff in results:
                if staff['HospitalName'] != current_hospital:
                    current_hospital = staff['HospitalName']
                    print(f"\n{current_hospital}:")
                print(f"  {staff['FullName']}: {staff['TotalAppointments']} appointments ({staff['PercentageShare']}%)")
        else:
            print("No staff data found")

if __name__ == "__main__":
    main()