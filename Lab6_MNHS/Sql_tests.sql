-- Create and use database
CREATE DATABASE IF NOT EXISTS lab3;
USE lab3;

-- Essential tables for your application tasks
CREATE TABLE Hospital (
    HID INT PRIMARY KEY,
    Name VARCHAR(100) NOT NULL,
    City VARCHAR(50) NOT NULL
);

CREATE TABLE Department (
    DEP_ID INT PRIMARY KEY,
    HID INT NOT NULL,
    Name VARCHAR(100) NOT NULL,
    FOREIGN KEY (HID) REFERENCES Hospital(HID)
);

CREATE TABLE Patient (
    IID INT PRIMARY KEY,
    CIN VARCHAR(10) UNIQUE NOT NULL,
    FullName VARCHAR(100) NOT NULL,
    Birth DATE,
    Sex ENUM('M','F') NOT NULL,
    BloodGroup VARCHAR(5),
    Phone VARCHAR(15)
);

CREATE TABLE Staff (
    STAFF_ID INT PRIMARY KEY,
    FullName VARCHAR(100) NOT NULL,
    Specialization VARCHAR(100)
);

CREATE TABLE ClinicalActivity (
    CAID INT PRIMARY KEY,
    IID INT NOT NULL,
    STAFF_ID INT NOT NULL,
    DEP_ID INT NOT NULL,
    Date DATE NOT NULL,
    Time TIME,
    FOREIGN KEY (IID) REFERENCES Patient(IID),
    FOREIGN KEY (STAFF_ID) REFERENCES Staff(STAFF_ID),
    FOREIGN KEY (DEP_ID) REFERENCES Department(DEP_ID)
);

CREATE TABLE Appointment (
    CAID INT PRIMARY KEY,
    Reason VARCHAR(100),
    Status ENUM('Scheduled', 'Completed', 'Cancelled') DEFAULT 'Scheduled',
    FOREIGN KEY (CAID) REFERENCES ClinicalActivity(CAID) ON DELETE CASCADE
);

CREATE TABLE Medication (
    MID INT PRIMARY KEY,
    Name VARCHAR(100) NOT NULL
);

CREATE TABLE Stock (
    HID INT,
    MID INT,
    UnitPrice DECIMAL(10,2) CHECK (UnitPrice >= 0),
    Qty INT DEFAULT 0 CHECK (Qty >= 0),
    ReorderLevel INT DEFAULT 10 CHECK (ReorderLevel >= 0),
    LastUpdated TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (HID, MID),
    FOREIGN KEY (HID) REFERENCES Hospital(HID),
    FOREIGN KEY (MID) REFERENCES Medication(MID)
);

-- =============================================================================
-- TEST DATA SPECIFICALLY FOR YOUR APPLICATION TASKS
-- =============================================================================

-- Insert Hospitals (for Task 3 & 4)
INSERT INTO Hospital (HID, Name, City) VALUES
(1, 'Benguerir Central Hospital', 'Benguerir'),
(2, 'Casablanca University Hospital', 'Casablanca'),
(3, 'Rabat Clinical Center', 'Rabat');

-- Insert Departments (for Task 2 & 4)
INSERT INTO Department (DEP_ID, HID, Name) VALUES
(101, 1, 'Cardiology'),
(102, 1, 'Pediatrics'),
(103, 2, 'Radiology'),
(104, 3, 'Emergency');

-- Insert Patients with VARIED LAST NAMES (for Task 1 sorting test)
INSERT INTO Patient (IID, CIN, FullName, Birth, Sex, BloodGroup, Phone) VALUES
(1, 'CIN001', 'Zouhair Alami', '1990-04-10', 'M', 'A+', '0612345678'),
(2, 'CIN002', 'Ahmed Benjelloun', '1988-09-22', 'M', 'O-', '0678912345'),
(3, 'CIN003', 'Karim Berrada', '1995-01-18', 'M', 'B+', '0600112233'),
(4, 'CIN004', 'Sofia El Khattabi', '1992-07-06', 'F', 'AB-', '0600223344'),
(5, 'CIN005', 'Leila Othmani', '2001-03-30', 'F', 'O+', '0600334455'),
(6, 'CIN006', 'Youssef Zahir', '1985-11-15', 'M', 'A-', '0600445566'),
(7, 'CIN007', 'Nadia Chraibi', '1993-08-25', 'F', 'B-', '0600556677'),
(8, 'CIN008', 'Mohammed Saidi', '1978-12-05', 'M', 'O+', '0600667788'),
(9, 'CIN009', 'Fatima Amrani', '1989-06-18', 'F', 'AB+', '0600778899'),
(10, 'CIN010', 'Hassan Touil', '1997-02-28', 'M', 'A+', '0600889900'),
(11, 'CIN011', 'Amina Idrissi', '1991-07-14', 'F', 'B+', '0600990011'),
(12, 'CIN012', 'Omar Lahlou', '1983-04-02', 'M', 'O-', '0601001122'),
(13, 'CIN013', 'Khadija Messari', '1994-09-09', 'F', 'A+', '0601112233'),
(14, 'CIN014', 'Rachid Guerbouzi', '1980-03-22', 'M', 'AB-', '0601223344'),
(15, 'CIN015', 'Samira Rifai', '1996-11-11', 'F', 'O+', '0601334455'),
(16, 'CIN016', 'Mehdi Mansouri', '1987-05-30', 'M', 'B+', '0601445566'),
(17, 'CIN017', 'Nora El Fassi', '1998-08-17', 'F', 'A-', '0601556677'),
(18, 'CIN018', 'Younes Benali', '1982-01-25', 'M', 'O+', '0601667788'),
(19, 'CIN019', 'Salma Zahra', '1999-12-08', 'F', 'AB+', '0601778899'),
(20, 'CIN020', 'Hamza Said', '1984-06-19', 'M', 'B-', '0601889900'),
(21, 'CIN021', 'Asmae Cherkaoui', '1992-10-13', 'F', 'A+', '0601990011');

-- Insert Staff (for Task 2 & 4)
INSERT INTO Staff (STAFF_ID, FullName, Specialization) VALUES
(201, 'Dr. Amina Idrissi', 'Cardiology'),
(202, 'Dr. Mehdi Touil', 'Cardiology'),
(203, 'Dr. Khaoula Messari', 'Pediatrics'),
(204, 'Dr. Omar Lahlou', 'Radiology'),
(205, 'Dr. Firdawse Guerbouzi', 'Emergency');

-- Insert Clinical Activities with VARIOUS DATES (for Task 4)
INSERT INTO ClinicalActivity (CAID, IID, STAFF_ID, DEP_ID, Date, Time) VALUES
-- Recent appointments for workload analysis
(1001, 1, 201, 101, '2025-01-15', '10:00:00'),
(1002, 2, 201, 101, '2025-01-16', '11:00:00'),
(1003, 3, 201, 101, '2025-01-17', '14:00:00'),
(1004, 4, 202, 101, '2025-01-15', '09:30:00'),
(1005, 5, 202, 101, '2025-01-18', '15:00:00'),
(1006, 6, 203, 102, '2025-01-16', '10:30:00'),
(1007, 7, 203, 102, '2025-01-19', '11:30:00'),
(1008, 8, 204, 103, '2025-01-17', '13:00:00'),
(1009, 9, 205, 104, '2025-01-18', '16:00:00'),
(1010, 10, 205, 104, '2025-01-20', '17:30:00'),

-- Future appointments for testing
(1011, 11, 201, 101, '2025-01-25', '10:00:00'),
(1012, 12, 202, 101, '2025-01-26', '11:00:00'),
(1013, 13, 203, 102, '2025-01-27', '14:00:00');

-- Insert Appointments with DIFFERENT STATUSES (for Task 4)
INSERT INTO Appointment (CAID, Reason, Status) VALUES
(1001, 'Heart checkup', 'Completed'),
(1002, 'Cardiac follow-up', 'Completed'),
(1003, 'Blood pressure monitoring', 'Scheduled'),
(1004, 'Echocardiogram', 'Completed'),
(1005, 'Cardiac consultation', 'Scheduled'),
(1006, 'Child vaccination', 'Completed'),
(1007, 'Pediatric consultation', 'Scheduled'),
(1008, 'X-ray examination', 'Completed'),
(1009, 'Emergency treatment', 'Completed'),
(1010, 'Fever consultation', 'Scheduled'),
(1011, 'Routine cardiac check', 'Scheduled'),
(1012, 'Heart surgery consultation', 'Scheduled'),
(1013, 'Child health check', 'Scheduled');

-- Insert Medications (for Task 3)
INSERT INTO Medication (MID, Name) VALUES
(501, 'Paracetamol'),
(502, 'Amoxicillin'),
(503, 'Ibuprofen'),
(504, 'Insulin'),
(505, 'Aspirin'),
(506, 'Ventolin'),
(507, 'Azithromycin');

-- Insert Stock with SPECIFIC TEST CASES for Task 3
INSERT INTO Stock (HID, MID, UnitPrice, Qty, ReorderLevel) VALUES
-- Hospital 1: Mixed stock levels
(1, 501, 2.50, 150, 100),    -- Good stock (above reorder)
(1, 502, 8.75, 15, 50),      -- LOW STOCK (below reorder)
(1, 503, 5.25, 5, 20),       -- VERY LOW STOCK
(1, 504, 25.00, 0, 10),      -- NO STOCK
(1, 505, 12.00, 200, 30),    -- Good stock

-- Hospital 2: Mixed stock levels  
(2, 501, 2.75, 80, 100),     -- LOW STOCK
(2, 502, 9.00, 200, 50),     -- Good stock
(2, 506, 15.50, 3, 15),      -- VERY LOW STOCK
(2, 507, 18.00, 0, 20),      -- NO STOCK

-- Hospital 3: Good stock
(3, 501, 2.60, 300, 100),    -- Good stock
(3, 503, 5.50, 150, 20),     -- Good stock
(3, 505, 12.50, 180, 30);    -- Good stock

-- =============================================================================
-- VERIFICATION QUERIES (Test your application results against these)
-- =============================================================================

-- Verify Task 1: Patients ordered by last name
SELECT IID, FullName 
FROM Patient 
ORDER BY SUBSTRING_INDEX(FullName, ' ', -1), FullName 
LIMIT 20;

-- Verify Task 3: Low stock medications (should match your app output)
SELECT 
    h.Name AS HospitalName,
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
ORDER BY h.Name, m.Name;

-- Verify Task 4: Staff appointment share (should match your app output)
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
ORDER BY h.Name, TotalAppointments DESC;