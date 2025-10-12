CREATE TABLE Expense (
    ExID INT PRIMARY KEY,
    Total DECIMAL(10,2)
);

CREATE TABLE ClinicalActivity (
    CAID INT PRIMARY KEY,
    Time TIME,
    Date DATE,
    ExID INT,
    FOREIGN KEY (ExID) REFERENCES Expense(ExID)
);

CREATE TABLE ContactLocation (
    CLID INT PRIMARY KEY,
    City VARCHAR(50),
    Province VARCHAR(50),
    Street VARCHAR(100),
    Number VARCHAR(10),
    PostalCode VARCHAR(20),
    Phone VARCHAR(20)
);

CREATE TABLE Insurance (
    InsID INT PRIMARY KEY,
    Type VARCHAR(50),
    attatched_to INT,
    FOREIGN KEY (attatched_to) REFERENCES Insurance(InsID)
);

CREATE TABLE Patient (
    IID INT PRIMARY KEY,
    CIN VARCHAR(20),
    Name VARCHAR(100),
    Sex VARCHAR(10),
    Birth DATE,
    BloodGroup VARCHAR(10),
    Phone VARCHAR(20),
    CAID INT,
    FOREIGN KEY (CAID) REFERENCES ClinicalActivity(CAID)
);

CREATE TABLE Prescription (
    PID INT PRIMARY KEY,
    DateIssued DATE,
    CAID INT,
    FOREIGN KEY (CAID) REFERENCES ClinicalActivity(CAID)
);

CREATE TABLE Appointment (
    CAID INT PRIMARY KEY,
    Reason VARCHAR(100),
    Status VARCHAR(20),
    FOREIGN KEY (CAID) REFERENCES ClinicalActivity(CAID)
);

CREATE TABLE Emergency (
    CAID INT PRIMARY KEY,
    TriageLevel VARCHAR(20),
    Outcome VARCHAR(100),
    FOREIGN KEY (CAID) REFERENCES ClinicalActivity(CAID)
);

CREATE TABLE Staff (
    StaffID INT PRIMARY KEY,
    Name VARCHAR(100),
    Status VARCHAR(20),
    CAID INT,
    FOREIGN KEY (CAID) REFERENCES ClinicalActivity(CAID)
);

CREATE TABLE Practitioner (
    StaffID INT PRIMARY KEY,
    LicenseNumber VARCHAR(30),
    Specialty VARCHAR(50),
    Grade VARCHAR(20),
    FOREIGN KEY (StaffID) REFERENCES Staff(StaffID)
);

CREATE TABLE Caregiving (
    StaffID INT PRIMARY KEY,
    Ward VARCHAR(50),
    FOREIGN KEY (StaffID) REFERENCES Staff(StaffID)
);

CREATE TABLE Technical (
    StaffID INT PRIMARY KEY,
    Certifications VARCHAR(100),
    Modality VARCHAR(50),
    FOREIGN KEY (StaffID) REFERENCES Staff(StaffID)
);

CREATE TABLE Hospital (
    HID INT PRIMARY KEY,
    Name VARCHAR(100),
    City VARCHAR(50),
    Region VARCHAR(50)
);

CREATE TABLE Department (
    DEP_ID INT PRIMARY KEY,
    Name VARCHAR(100),
    Specialty VARCHAR(50),
    CAID INT,
    HID INT,
    FOREIGN KEY (CAID) REFERENCES ClinicalActivity(CAID),
    FOREIGN KEY (HID) REFERENCES Hospital(HID)
);

CREATE TABLE Medication (
    MID INT PRIMARY KEY,
    Class VARCHAR(50),
    Unit VARCHAR(20),
    Name VARCHAR(100),
    Form VARCHAR(50),
    Strength VARCHAR(30),
    ActiveIngredient VARCHAR(100),
    Manufacturer VARCHAR(100)
);

CREATE TABLE work_in (
    StaffID INT,
    DepartmentID INT,
    PRIMARY KEY (StaffID, DepartmentID),
    FOREIGN KEY (StaffID) REFERENCES Staff(StaffID),
    FOREIGN KEY (DepartmentID) REFERENCES Department(DEP_ID)
);

CREATE TABLE Stock (
    Drug_ID INT,
    Hospital_ID INT,
    UnitPrice DECIMAL(8,2),
    StockTimestamp DATETIME,
    Qty INT,
    ReorderLevel INT,
    PRIMARY KEY (Drug_ID, Hospital_ID),
    FOREIGN KEY (Hospital_ID) REFERENCES Hospital(HID),
    FOREIGN KEY (Drug_ID) REFERENCES Medication(MID)
);

CREATE TABLE Have (
    Patien_ID INT,
    Contact_ID INT,
    PRIMARY KEY (Patien_ID, Contact_ID),
    FOREIGN KEY (Patien_ID) REFERENCES Patient(IID),
    FOREIGN KEY (Contact_ID) REFERENCES ContactLocation(CLID)
);

CREATE TABLE Covers (
    Patien_ID INT,
    Insurance_ID INT,
    PRIMARY KEY (Patien_ID, Insurance_ID),
    FOREIGN KEY (Patien_ID) REFERENCES Patient(IID),
    FOREIGN KEY (Insurance_ID) REFERENCES Insurance(InsID)
);

CREATE TABLE Include (
    Prescription_ID INT,
    Drug_ID INT,
    Dosage VARCHAR(50),
    Duration VARCHAR(50),
    PRIMARY KEY (Prescription_ID, Drug_ID),
    FOREIGN KEY (Prescription_ID) REFERENCES Prescription(PID),
    FOREIGN KEY (Drug_ID) REFERENCES Medication(MID)
);

INSERT INTO Expense VALUES 
  (1, 450.00),
  (2, 200.00);

INSERT INTO ClinicalActivity VALUES 
  (101, '10:00', '2025-10-15', 1),
  (102, '14:00', '2025-10-20', 2);

INSERT INTO ContactLocation VALUES 
  (1, 'Benguerir', 'Marrakech', 'Main St', '12', '43000', '0523456789'),
  (2, 'Casablanca', 'Anfa', 'Ocean Ave', '85', '20000', '0523987654');

INSERT INTO Insurance VALUES 
  (1, 'CNSS', NULL),
  (2, 'Mutuelle', NULL);

INSERT INTO Patient VALUES 
  (1, 'MC12345', 'Sara Belmaktoub', 'F', '2002-05-15', 'A+', '0612345678', 101),
  (2, 'MC54321', 'Omar Hafidi', 'M', '2001-09-22', 'O-', '0698765432', 102);

INSERT INTO Prescription VALUES 
  (1, '2025-10-01', 101),
  (2, '2025-10-08', 102);

INSERT INTO Appointment VALUES 
  (101, 'Checkup', 'Scheduled'),
  (102, 'Follow-up', 'Scheduled');

INSERT INTO Emergency VALUES 
  (101, 'High', 'Admitted'),
  (102, 'Low', 'Discharged');

INSERT INTO Staff VALUES 
  (1, 'Dr. Habib', 'Active', 101),
  (2, 'Nurse Imane', 'Active', 102);

INSERT INTO Practitioner VALUES 
  (1, 'A123', 'Cardiology', 'Senior');

INSERT INTO Caregiving VALUES 
  (2, 'Ward B');

INSERT INTO Hospital VALUES 
  (1, 'Benguerir Hospital', 'Benguerir', 'Marrakech'),
  (2, 'Casa Clinic', 'Casablanca', 'Anfa');

INSERT INTO Department VALUES 
  (1, 'Cardiology', 'Heart', 101, 1),
  (2, 'Pediatrics', 'Children', 102, 2);

INSERT INTO Medication VALUES 
  (1, 'Antibiotic', 'Tablet', 'Amoxicillin', 'Film', '500mg', 'Amoxil', 'Pfizer'),
  (2, 'Analgesic', 'Syrup', 'Paracetamol', 'Liquid', '250mg', 'Tylenol', 'J&J');

INSERT INTO work_in VALUES 
  (1, 1),
  (2, 2);

INSERT INTO Stock VALUES 
  (1, 1, 10.00, '2025-10-13 08:00', 100, 20),
  (2, 2, 8.00, '2025-10-14 12:00', 200, 30);

INSERT INTO Have VALUES 
  (1, 1),
  (2, 2);

INSERT INTO Covers VALUES 
  (1, 1),
  (2, 2);

INSERT INTO Include VALUES 
  (1, 1, '1 tab', '7 days'),
  (2, 2, '10 ml', '5 days');

SELECT p.Name
FROM Patient p
JOIN Appointment a ON p.CAID = a.CAID
JOIN ClinicalActivity ca ON a.CAID = ca.CAID
JOIN Department d ON ca.CAID = d.CAID
JOIN Hospital h ON d.HID = h.HID
WHERE a.Status = 'Scheduled'
  AND h.City = 'Benguerir';