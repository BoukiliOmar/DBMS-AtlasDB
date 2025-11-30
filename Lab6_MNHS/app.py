"""
Flask Backend for MNHS Web Application
"""

from flask import Flask, request, jsonify, render_template
from flask_cors import CORS
import mysql.connector
from mysql.connector import Error
import os
from dotenv import load_dotenv
import logging

# Load environment variables
load_dotenv()

app = Flask(__name__)
CORS(app)

# Database configuration
cfg = {
    "host": os.getenv("MYSQL_HOST", "127.0.0.1"),
    "port": int(os.getenv("MYSQL_PORT", "3306")),
    "database": os.getenv("MYSQL_DB", "lab3"),
    "user": os.getenv("MYSQL_USER", "mnhs_user"),
    "password": os.getenv("MYSQL_PASSWORD", "STRONG_PASSWORD")
}

def get_connection():
    """Get database connection"""
    try:
        return mysql.connector.connect(**cfg)
    except Error as e:
        logging.error(f"Database connection failed: {e}")
        raise

@app.route('/')
def index():
    """Serve the main HTML page"""
    return render_template('index.html')  # Your HTML file

# TASK 1: List patients ordered by last name
@app.route('/api/patients', methods=['GET'])
def get_patients():
    """Get patients ordered by last name"""
    try:
        sql = """
        SELECT IID, FullName
        FROM Patient
        ORDER BY SUBSTRING_INDEX(FullName, ' ', -1), FullName
        LIMIT 20
        """
        
        with get_connection() as cnx:
            with cnx.cursor(dictionary=True) as cur:
                cur.execute(sql)
                patients = cur.fetchall()
                
        return jsonify({
            "success": True,
            "data": patients,
            "count": len(patients)
        })
        
    except Exception as e:
        return jsonify({
            "success": False,
            "error": str(e)
        }), 500

# TASK 2: Schedule appointment
@app.route('/api/schedule_appt', methods=['POST'])
def schedule_appointment():
    """Schedule a new appointment"""
    try:
        data = request.json
        caid = data.get('caid')
        iid = data.get('iid')
        staff_id = data.get('staff_id')
        dep_id = data.get('dep_id')
        date = data.get('date')
        time = data.get('time')
        reason = data.get('reason', 'General Consultation')
        
        ins_ca = """
        INSERT INTO ClinicalActivity(CAID, IID, STAFF_ID, DEP_ID, Date, Time)
        VALUES (%s, %s, %s, %s, %s, %s)
        """
        
        ins_appt = """
        INSERT INTO Appointment(CAID, Reason, Status)
        VALUES (%s, %s, 'Scheduled')
        """
        
        with get_connection() as cnx:
            try:
                with cnx.cursor() as cur:
                    cur.execute(ins_ca, (caid, iid, staff_id, dep_id, date, time))
                    cur.execute(ins_appt, (caid, reason))
                    cnx.commit()
                    
                return jsonify({
                    "success": True,
                    "appointment_id": caid,
                    "message": "Appointment scheduled successfully"
                })
                
            except Exception as e:
                cnx.rollback()
                return jsonify({
                    "success": False,
                    "error": str(e)
                }), 400
                
    except Exception as e:
        return jsonify({
            "success": False,
            "error": str(e)
        }), 500

# TASK 3: Low stock medications
@app.route('/api/low_stock', methods=['GET'])
def get_low_stock():
    """Get medications below reorder level"""
    try:
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
                low_stock = cur.fetchall()
                
        return jsonify({
            "success": True,
            "data": low_stock,
            "count": len(low_stock)
        })
        
    except Exception as e:
        return jsonify({
            "success": False,
            "error": str(e)
        }), 500

# TASK 4: Staff share analysis
@app.route('/api/staff_share', methods=['GET'])
def get_staff_share():
    """Get staff appointment share analytics"""
    try:
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
                staff_data = cur.fetchall()
                
        return jsonify({
            "success": True,
            "data": staff_data
        })
        
    except Exception as e:
        return jsonify({
            "success": False,
            "error": str(e)
        }), 500

# NEW: Insert patient endpoint
@app.route('/api/patients', methods=['POST'])
def insert_patient():
    """Insert a new patient"""
    try:
        data = request.json
        iid = data.get('iid')
        cin = data.get('cin')
        full_name = data.get('full_name')
        birth = data.get('birth')
        sex = data.get('sex')
        blood_group = data.get('blood_group')
        phone = data.get('phone')
        
        sql = """
        INSERT INTO Patient(IID, CIN, FullName, Birth, Sex, BloodGroup, Phone)
        VALUES (%s, %s, %s, %s, %s, %s, %s)
        """
        
        with get_connection() as cnx:
            try:
                with cnx.cursor() as cur:
                    cur.execute(sql, (iid, cin, full_name, birth, sex, blood_group, phone))
                    cnx.commit()
                    
                return jsonify({
                    "success": True,
                    "patient_id": iid,
                    "message": "Patient added successfully"
                })
                
            except Exception as e:
                cnx.rollback()
                return jsonify({
                    "success": False,
                    "error": str(e)
                }), 400
                
    except Exception as e:
        return jsonify({
            "success": False,
            "error": str(e)
        }), 500

# Additional endpoints for dropdowns
@app.route('/api/departments', methods=['GET'])
def get_departments():
    """Get departments for dropdown"""
    try:
        sql = "SELECT DEP_ID, Name FROM Department ORDER BY Name"
        
        with get_connection() as cnx:
            with cnx.cursor(dictionary=True) as cur:
                cur.execute(sql)
                departments = cur.fetchall()
                
        return jsonify({
            "success": True,
            "data": departments
        })
        
    except Exception as e:
        return jsonify({
            "success": False,
            "error": str(e)
        }), 500

@app.route('/api/staff', methods=['GET'])
def get_staff():
    """Get staff for dropdown"""
    try:
        sql = "SELECT STAFF_ID, FullName FROM Staff ORDER BY FullName"
        
        with get_connection() as cnx:
            with cnx.cursor(dictionary=True) as cur:
                cur.execute(sql)
                staff = cur.fetchall()
                
        return jsonify({
            "success": True,
            "data": staff
        })
        
    except Exception as e:
        return jsonify({
            "success": False,
            "error": str(e)
        }), 500
    
  

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)