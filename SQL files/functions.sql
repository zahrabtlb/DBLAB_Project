--functions

--this function gets a patient id and return patient age base on their Birth_Date--------
CREATE FUNCTION GetPatientAge (@PatientID INT)
RETURNS INT
AS
BEGIN
    DECLARE @BirthDate DATE;
    DECLARE @Age INT;

    SELECT @BirthDate = Birth_Date FROM Patient WHERE Patient_ID = @PatientID;

    IF @BirthDate IS NULL
        RETURN NULL;

    SET @Age = DATEDIFF(YEAR, @BirthDate, GETDATE());

    -- Adjustment if birthday hasn’t occurred yet this year
    IF (MONTH(@BirthDate) > MONTH(GETDATE())) OR 
       (MONTH(@BirthDate) = MONTH(GETDATE()) AND DAY(@BirthDate) > DAY(GETDATE()))
        SET @Age = @Age - 1;

    RETURN @Age;
END;


--returns patient last visit dateTime--------------------------------------------------
CREATE FUNCTION GetLastVisitDate (@PatientID INT)
RETURNS DATETIME
AS
BEGIN
    DECLARE @LastVisit DATETIME;

    SELECT @LastVisit = MAX(Appointment_DateTime)
    FROM Appointment
    WHERE Patient_ID = @PatientID and status ='Completed';

    RETURN @LastVisit;
END;

--check if appointment is paid------------------------------------------------------
CREATE or alter FUNCTION IsAppointmentPaid (@AppointmentID INT)
RETURNS BIT
AS
BEGIN
    IF EXISTS (
        SELECT 1
        FROM Payment
        WHERE Appointment_ID = @AppointmentID
    )
        RETURN 1;
    RETURN 0;
END;

