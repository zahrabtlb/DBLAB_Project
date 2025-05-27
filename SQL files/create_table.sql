--create tables

--drop table Patient_Medical_History
--drop table Prescription
--drop table Payment
--drop table Appointment
--drop table Patient
--drop table Doctor
--drop table Specialization

CREATE TABLE Specialization (
    Specialization_ID INT PRIMARY KEY IDENTITY,
    Title NVARCHAR(100) NOT NULL UNIQUE,
    Description NVARCHAR(255)
);


CREATE TABLE Patient (
    Patient_ID INT PRIMARY KEY IDENTITY,
    First_Name NVARCHAR(50) NOT NULL,
    Last_Name NVARCHAR(50) NOT NULL,
    Birth_Date DATE NOT NULL,
    Phone_Number NVARCHAR(15) NOT NULL
);


CREATE TABLE Doctor (
    Doctor_ID INT PRIMARY KEY IDENTITY,
    FirstName NVARCHAR(50) NOT NULL,
    LastName NVARCHAR(50) NOT NULL,
    PhoneNumber NVARCHAR(15),
	Visit_Fee DECIMAL(10,2) NOT NULL,
    Specialization_ID INT FOREIGN KEY REFERENCES Specialization(Specialization_ID),
	IsDeleted BIT DEFAULT 0
);



CREATE TABLE Appointment (
    Appointment_ID INT PRIMARY KEY IDENTITY,
    Appointment_DateTime DATETIME NOT NULL,
    Patient_ID INT NOT NULL,
    Doctor_ID INT NOT NULL,
    Cost DECIMAL(10,2) NOT NULL,
    Status NVARCHAR(50) DEFAULT 'Scheduled', -- NEW: Added Status column with default value
    FOREIGN KEY (Patient_ID) REFERENCES Patient(Patient_ID),
    FOREIGN KEY (Doctor_ID) REFERENCES Doctor(Doctor_ID)
);
ALTER TABLE Appointment
ADD CONSTRAINT CHK_Appointment_Status
CHECK (Status IN ('Scheduled', 'Completed', 'Cancelled'));


CREATE TABLE Payment (
    Payment_ID INT PRIMARY KEY IDENTITY,
    Appointment_ID INT NOT NULL UNIQUE,
    Payment_Method NVARCHAR(50),
    Payment_Date DATETIME DEFAULT GETDATE(),
	PaymentStatus NVARCHAR(50) DEFAULT 'Paid', --NEW: for refunded payments
    FOREIGN KEY (Appointment_ID) REFERENCES Appointment(Appointment_ID)
);
ALTER TABLE Payment
ADD CONSTRAINT CHK_Payment_Status
CHECK (PaymentStatus IN ('Paid', 'Refunded'));


CREATE TABLE Prescription (
    ID INT PRIMARY KEY IDENTITY,
    Appointment_ID INT NOT NULL,
    Medication_Name NVARCHAR(100),
    Dosage NVARCHAR(100),
    FOREIGN KEY (Appointment_ID) REFERENCES Appointment(Appointment_ID)
);


CREATE TABLE Patient_Medical_History (
    Patient_Medical_History_ID INT PRIMARY KEY IDENTITY,
    Patient_ID INT NOT NULL,
    Condition_Title NVARCHAR(100),
    Condition_Description NVARCHAR(255),
    FOREIGN KEY (Patient_ID) REFERENCES Patient(Patient_ID)
);

