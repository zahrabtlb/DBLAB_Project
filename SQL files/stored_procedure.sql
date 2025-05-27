-- stored procedures

CREATE PROCEDURE CreateAppointment
    @Patient_ID INT,
    @Doctor_ID INT,
    @Appointment_DateTime DATETIME
AS
BEGIN
    DECLARE @Visit_Fee DECIMAL(10, 2);

    SELECT @Visit_Fee = Visit_Fee
    FROM Doctor
    WHERE Doctor_ID = @Doctor_ID;

    INSERT INTO Appointment (Patient_ID, Doctor_ID, Appointment_DateTime, Cost)
    VALUES (@Patient_ID, @Doctor_ID, @Appointment_DateTime, @Visit_Fee);
END;
-------------------------------------------------------------------------------


CREATE PROCEDURE CompleteAppointment
    @Appointment_ID INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @CurrentStatus NVARCHAR(50);
	DECLARE @IsPaid BIT;

    SELECT @CurrentStatus = Status
    FROM Appointment
    WHERE Appointment_ID = @Appointment_ID;

	SET @IsPaid = dbo.IsAppointmentPaid(@Appointment_ID);

    IF @CurrentStatus = 'Cancelled'
    BEGIN
        RAISERROR ('Cannot complete a cancelled appointment.', 16, 1);
        RETURN;
    END
    ELSE IF @CurrentStatus = 'Completed'
    BEGIN
        RAISERROR ('Appointment is already completed.', 16, 1);
        RETURN;
    END
	-- add a checkhere to ensure payment is processed
	ELSE IF @IsPaid = 0 -- NEW: Check if the appointment is paid
    BEGIN
        RAISERROR ('Appointment cannot be completed. Payment has not been registered yet.', 16, 1);
        RETURN;
    END
    ELSE
    BEGIN
        UPDATE Appointment
        SET Status = 'Completed'
        WHERE Appointment_ID = @Appointment_ID;
    END
END;
-------------------------------------------------------------------------------


CREATE PROCEDURE RegisterPayment
    @Appointment_ID INT,
    @Payment_Method NVARCHAR(50)
AS
BEGIN
    INSERT INTO Payment (Appointment_ID, Payment_Method, Payment_Date)
    VALUES (@Appointment_ID, @Payment_Method, GETDATE());
END;
-------------------------------------------------------------------------------



CREATE PROCEDURE InsertPrescription
    @Appointment_ID INT,
    @Medications NVARCHAR(MAX) -- Assumed to be a comma-separated list of medications
AS
BEGIN
    DECLARE @MedicationList TABLE (Medication_Name NVARCHAR(100), Dosage NVARCHAR(100));
    DECLARE @MedicationName NVARCHAR(100);
    DECLARE @Dosage NVARCHAR(100);
    
    -- Parse the medication list
    -- For each medication, extract the name and dosage and insert them into the temporary table
    -- Assuming the medications are in the format 'MedicationName:Dosage' separated by commas
    DECLARE @Position INT = 1;
    WHILE CHARINDEX(',', @Medications, @Position) > 0
    BEGIN
        SET @MedicationName = LTRIM(RTRIM(SUBSTRING(@Medications, @Position, CHARINDEX(':', @Medications, @Position) - @Position)));
        SET @Dosage = LTRIM(RTRIM(SUBSTRING(@Medications, CHARINDEX(':', @Medications, @Position) + 1, CHARINDEX(',', @Medications, @Position) - CHARINDEX(':', @Medications, @Position) - 1)));

        INSERT INTO @MedicationList (Medication_Name, Dosage)
        VALUES (@MedicationName, @Dosage);

        SET @Position = CHARINDEX(',', @Medications, @Position) + 1;
    END

    INSERT INTO Prescription (Appointment_ID, Medication_Name, Dosage)
    SELECT @Appointment_ID, Medication_Name, Dosage
    FROM @MedicationList;
END;
-------------------------------------------------------------------------------------------


CREATE PROCEDURE GetDoctorRevenueReport
    @StartDate DATETIME,
    @EndDate DATETIME
AS
BEGIN
    SELECT
        D.Doctor_ID,
        D.FirstName + ' ' + D.LastName AS DoctorName,
        S.Title AS Specialization,
        COUNT(A.Appointment_ID) AS TotalAppointments,
        SUM(A.Cost) AS TotalRevenueGenerated,
        SUM(CASE WHEN P.Payment_ID IS NOT NULL THEN A.Cost ELSE 0 END) AS TotalPaidRevenue -- Revenue that has been paid
    FROM Doctor D
    JOIN Appointment A ON D.Doctor_ID = A.Doctor_ID
    LEFT JOIN Payment P ON A.Appointment_ID = P.Appointment_ID -- LEFT JOIN to include unpaid appointments
    JOIN Specialization S ON D.Specialization_ID = S.Specialization_ID
    WHERE A.Appointment_DateTime >= @StartDate AND A.Appointment_DateTime <= @EndDate
    GROUP BY D.Doctor_ID, D.FirstName, D.LastName, S.Title
    ORDER BY TotalRevenueGenerated DESC;
END;
------------------------------------------------------------------------------------------------

CREATE PROCEDURE AddNewDoctor
    @FirstName NVARCHAR(50),
    @LastName NVARCHAR(50),
    @PhoneNumber NVARCHAR(15),
    @Specialization_ID INT,
    @Visit_Fee DECIMAL(10,2)
AS
BEGIN
    INSERT INTO Doctor (FirstName, LastName, PhoneNumber, Specialization_ID, Visit_Fee)
    VALUES (@FirstName, @LastName, @PhoneNumber, @Specialization_ID, @Visit_Fee);
END;

----------------------------------------------------------------------------------------------
CREATE PROCEDURE AddNewPatient
    @First_Name NVARCHAR(50),
    @Last_Name NVARCHAR(50),
    @Birth_Date DATE,
    @Phone_Number NVARCHAR(15)
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO Patient (First_Name, Last_Name, Birth_Date, Phone_Number)
    VALUES (@First_Name, @Last_Name, @Birth_Date, @Phone_Number);
END;
--------------------------------------------------------------------------------------------

CREATE PROCEDURE UpdateDoctorInfo
    @Doctor_ID INT,
    @FirstName NVARCHAR(50) = NULL,
    @LastName NVARCHAR(50) = NULL,
    @PhoneNumber NVARCHAR(15) = NULL,
    @Specialization_ID INT = NULL,
    @Visit_Fee DECIMAL(10,2) = NULL
AS
BEGIN
    UPDATE Doctor
    SET
        FirstName = ISNULL(@FirstName, FirstName),
        LastName = ISNULL(@LastName, LastName),
        PhoneNumber = ISNULL(@PhoneNumber, PhoneNumber),
        Specialization_ID = ISNULL(@Specialization_ID, Specialization_ID),
        Visit_Fee = ISNULL(@Visit_Fee, Visit_Fee)
    WHERE Doctor_ID = @Doctor_ID;
END;
---------------------------------------------------------------------------------------


CREATE PROCEDURE CancelOverdueScheduledAppointments
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE Appointment
    SET Status = 'Cancelled'
    WHERE Status = 'Scheduled'
      AND Appointment_DateTime < GETDATE();

    PRINT CAST(@@ROWCOUNT AS NVARCHAR(10)) + ' scheduled appointments were cancelled due to being overdue.';
END;

---------------------------------------------------------------------------------------