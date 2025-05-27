--TEST AND EXECUTE

-- Select all data from all tables
SELECT * FROM Specialization;
SELECT * FROM Patient;
SELECT * FROM Doctor;
SELECT * FROM Appointment;
SELECT * FROM Prescription;
SELECT * FROM Payment;
SELECT * FROM Patient_Medical_History;
--patients

-- Test GetPatientAge function for a specific patient (e.g., Patient_ID = 1)
SELECT dbo.GetPatientAge(1) AS PatientAge;

-- Test GetLastVisitDate function for a specific patient (e.g., Patient_ID = 1)
SELECT dbo.GetLastVisitDate(1) AS LastVisitDate;

-- Retrieve list of doctors and their specializations for booking an appointment
SELECT Doctor_ID, FirstName + ' ' + LastName AS DoctorName, Specialization AS Specialization, Average_Cost FROM DoctorsWithStats;

-- Example: Create a new appointment for Patient_ID 2 with Doctor_ID 1 on a future date
EXEC CreateAppointment @Patient_ID = 2, @Doctor_ID = 1, @Appointment_DateTime = '2025-06-20 10:00:00';

-- View a specific patient's medical history (e.g., Patient_ID = 1)
SELECT Condition_Title, Condition_Description FROM Patient_Medical_History WHERE Patient_ID = 1;

-- View all prescriptions for a specific patient (e.g., Patient_ID = 1)
SELECT A.Appointment_DateTime, D.FirstName + ' ' + D.LastName AS DoctorName, S.Title AS DoctorSpecialization, P.Medication_Name, P.Dosage FROM Appointment A JOIN Prescription P ON A.Appointment_ID = P.Appointment_ID JOIN Doctor D ON A.Doctor_ID = D.Doctor_ID JOIN Specialization S ON D.Specialization_ID = S.Specialization_ID WHERE A.Patient_ID = 1 ORDER BY A.Appointment_DateTime DESC;

-- View a specific patient's appointments, costs, and payment status (e.g., Patient_ID = 1)
SELECT A.Appointment_ID, A.Appointment_DateTime, D.FirstName + ' ' + D.LastName AS DoctorName, A.Cost, A.Status AS AppointmentStatus, dbo.IsAppointmentPaid(A.Appointment_ID) AS IsPaid, Py.Payment_Method, Py.Payment_Date FROM Appointment A JOIN Doctor D ON A.Doctor_ID = D.Doctor_ID LEFT JOIN Payment Py ON A.Appointment_ID = Py.Appointment_ID WHERE A.Patient_ID = 1 ORDER BY A.Appointment_DateTime DESC;

-- Test IsAppointmentPaid function for a specific appointment (e.g., Appointment_ID = 2)
SELECT dbo.IsAppointmentPaid(2) AS IsAppointment2Paid;

-- Example: Register a payment for an appointment (e.g., Appointment_ID = 2)
EXEC RegisterPayment @Appointment_ID = 2, @Payment_Method = 'Online';

-- Showing Doctors to Patients
SELECT
    D.Doctor_ID,
    D.FirstName + ' ' + D.LastName AS DoctorName,
    S.Title AS Specialization,
    D.Visit_Fee
FROM Doctor D
JOIN Specialization S ON D.Specialization_ID = S.Specialization_ID;


-- Example of how CreateAppointment SP is called
EXEC CreateAppointment @Patient_ID = 1, @Doctor_ID = 3, @Appointment_DateTime = '2025-06-15 10:00:00';


--To check all prescription of a Patient

SELECT
    A.Appointment_DateTime,
    D.FirstName + ' ' + D.LastName AS DoctorName,
    S.Title AS DoctorSpecialization,
    P.Medication_Name,
    P.Dosage
FROM Appointment A
JOIN Prescription P ON A.Appointment_ID = P.Appointment_ID
JOIN Doctor D ON A.Doctor_ID = D.Doctor_ID
JOIN Specialization S ON D.Specialization_ID = S.Specialization_ID
WHERE A.Patient_ID = 1
ORDER BY A.Appointment_DateTime DESC; 


-- This query returns patient's payments & reserves
SELECT
    A.Appointment_ID,
    A.Appointment_DateTime,
    D.FirstName + ' ' + D.LastName AS DoctorName,
    A.Cost,
    dbo.IsAppointmentPaid(A.Appointment_ID) AS IsPaid, 
    P.Payment_Method,
    P.Payment_Date
FROM Appointment A
JOIN Doctor D ON A.Doctor_ID = D.Doctor_ID
LEFT JOIN Payment P ON A.Appointment_ID = P.Appointment_ID 
WHERE A.Patient_ID = 1
ORDER BY A.Appointment_DateTime DESC; 

-- already paid and can't pay again
EXEC RegisterPayment @Appointment_ID = 1, @Payment_Method = 'Online';


--doctors

-- View all patients who have appointments with a specific doctor (e.g., Doctor_ID = 1)
SELECT DISTINCT P.Patient_ID, P.First_Name, P.Last_Name, P.Phone_Number, P.Birth_Date, dbo.GetPatientAge(P.Patient_ID) AS Age, dbo.GetLastVisitDate(P.Patient_ID) AS LastVisitDate FROM Patient P JOIN Appointment A ON P.Patient_ID = A.Patient_ID WHERE A.Doctor_ID = 1 ORDER BY P.Last_Name, P.First_Name;

-- View full medical history for a specific patient (e.g., Patient_ID = 1)
SELECT Condition_Title, Condition_Description FROM Patient_Medical_History WHERE Patient_ID = 1;

-- View a specific doctor's appointment schedule (e.g., Doctor_ID = 1)
SELECT A.Appointment_ID, A.Appointment_DateTime, P.First_Name + ' ' + P.Last_Name AS PatientName, P.Phone_Number AS PatientPhoneNumber, A.Cost, A.Status AS AppointmentStatus, dbo.IsAppointmentPaid(A.Appointment_ID) AS IsPaidStatus FROM Appointment A JOIN Patient P ON A.Patient_ID = P.Patient_ID WHERE A.Doctor_ID = 1 ORDER BY A.Appointment_DateTime ASC;

-- Example: Complete an appointment (e.g., Appointment_ID = 2) after the visit
EXEC CompleteAppointment @Appointment_ID = 2;

-- Example: Insert a prescription for a completed appointment (e.g., Appointment_ID = 1)
EXEC InsertPrescription @Appointment_ID = 1, @Medications = 'Aspirin:100mg daily, Folic Acid:1mg daily';

-- list of a doctor's patients
SELECT DISTINCT
    P.Patient_ID,
    P.First_Name,
    P.Last_Name,
    P.Phone_Number,
    P.Birth_Date,
    dbo.GetPatientAge(P.Patient_ID) AS Age, -- Using the existing function to get age
    dbo.GetLastVisitDate(P.Patient_ID) AS LastVisitDate -- Using the existing function to get last visit date
FROM Patient P
JOIN Appointment A ON P.Patient_ID = A.Patient_ID
WHERE A.Doctor_ID = 1
ORDER BY P.Last_Name, P.First_Name;

-- How Doctors check medical history
SELECT
    PMH.Condition_Title,
    PMH.Condition_Description
FROM Patient_Medical_History PMH
WHERE PMH.Patient_ID = 1;

-- Example of how InsertPrescription SP is called after a visit
-- This assumes Appointment_ID is known for the completed visit
EXEC InsertPrescription @Appointment_ID = 1, @Medications = 'Amoxicillin:250mg three times a day, Ibuprofen:400mg after meal';

-- a doctor's appointments list
SELECT
    A.Appointment_ID,
    A.Appointment_DateTime,
    P.First_Name + ' ' + P.Last_Name AS PatientName,
    P.Phone_Number AS PatientPhoneNumber,
    A.Cost,
    dbo.IsAppointmentPaid(A.Appointment_ID) AS IsPaidStatus
FROM Appointment A
JOIN Patient P ON A.Patient_ID = P.Patient_ID
WHERE A.Doctor_ID = 1
ORDER BY A.Appointment_DateTime ASC;


--admin

-- View overall clinic statistics
SELECT * FROM ClinicOverallStats;

-- View doctor statistics (from existing view)
SELECT * FROM DoctorsWithStats;

-- View revenue report for doctors for a specific period (e.g., between '2025-05-01' and '2025-05-31')
EXEC GetDoctorRevenueReport @StartDate = '2025-05-01', @EndDate = '2025-05-31';

-- Example: Add a new doctor
EXEC AddNewDoctor @FirstName = 'Kamran', @LastName = 'Norouzi', @PhoneNumber = '09121002030', @Specialization_ID = 1, @Visit_Fee = 75.0;

-- Example: Update an existing doctor's information (e.g., Doctor_ID = 1)
EXEC UpdateDoctorInfo @Doctor_ID = 1, @PhoneNumber = '09121239999', @Visit_Fee = 15.0;

-- View all appointments with their payment status
SELECT * FROM AppointmentsWithPaymentStatus;

-- View unpaid appointments
SELECT * FROM UnpaidAppointments;
