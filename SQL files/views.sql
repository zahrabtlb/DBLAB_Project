--views

CREATE VIEW DoctorsWithStats AS
SELECT 
    d.Doctor_ID,
    d.FirstName,
    d.LastName,
    s.Title AS Specialization,
    AVG(a.Cost) AS Average_Cost,
    COUNT(DISTINCT a.Patient_ID) AS Unique_Patient_Count
FROM Doctor d
LEFT JOIN Specialization s ON d.Specialization_ID = s.Specialization_ID
LEFT JOIN Appointment a ON d.Doctor_ID = a.Doctor_ID
GROUP BY d.Doctor_ID, d.FirstName, d.LastName, s.Title;

--------------------------------------------------------------------------------
CREATE VIEW UnpaidAppointments AS
SELECT 
    a.Appointment_ID,
    a.Appointment_DateTime,
    a.Patient_ID,
    a.Doctor_ID,
    a.Cost
FROM Appointment a
LEFT JOIN Payment p ON a.Appointment_ID = p.Appointment_ID
WHERE p.Appointment_ID IS NULL;

---------------------------------------------------------------------------------
CREATE VIEW PatientMedicalSummary AS
SELECT 
    p.Patient_ID,
    p.First_Name,
    p.Last_Name,
    STRING_AGG(h.Condition_Title, ', ') AS Condition_Summary
FROM Patient p
LEFT JOIN Patient_Medical_History h ON p.Patient_ID = h.Patient_ID
GROUP BY p.Patient_ID, p.First_Name, p.Last_Name;


-- View for overall clinic statistics (visits and revenue)-----------------------------------
CREATE VIEW ClinicOverallStats AS
SELECT
    COUNT(A.Appointment_ID) AS TotalAppointments,
    SUM(A.Cost) AS TotalPotentialRevenue,
    SUM(CASE WHEN A.Status = 'Completed' THEN A.Cost ELSE 0 END) AS RevenueFromCompletedVisits,
    SUM(CASE WHEN dbo.IsAppointmentPaid(A.Appointment_ID) = 1 THEN A.Cost ELSE 0 END) AS TotalPaidRevenue,
    COUNT(CASE WHEN A.Status = 'Completed' THEN 1 ELSE NULL END) AS CompletedAppointments,
    COUNT(CASE WHEN A.Status = 'Scheduled' THEN 1 ELSE NULL END) AS ScheduledAppointments,
    COUNT(CASE WHEN A.Status = 'Cancelled' THEN 1 ELSE NULL END) AS CancelledAppointments
FROM Appointment A;


-------------------------------------------------------------------------------------------
CREATE VIEW AppointmentsWithPaymentStatus AS
SELECT
    A.Appointment_ID,
    A.Appointment_DateTime,
    P.First_Name + ' ' + P.Last_Name AS PatientName,
    D.FirstName + ' ' + D.LastName AS DoctorName,
    A.Cost,
    A.Status AS AppointmentStatus,
    dbo.IsAppointmentPaid(A.Appointment_ID) AS IsPaid,
    Py.Payment_Method,
    Py.Payment_Date
FROM Appointment A
JOIN Patient P ON A.Patient_ID = P.Patient_ID
JOIN Doctor D ON A.Doctor_ID = D.Doctor_ID
LEFT JOIN Payment Py ON A.Appointment_ID = Py.Appointment_ID;
------------------------------------------------------------------------------------------