--triggers

--instead of delete : isdeleted=1 and cancel associated appointments
CREATE TRIGGER trg_PreventDoctorDelete
ON Doctor
INSTEAD OF DELETE
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE D
    SET D.IsDeleted = 1
    FROM Doctor D
    JOIN deleted Del ON D.Doctor_ID = Del.Doctor_ID;

    UPDATE A
    SET A.Status = 'Cancelled'
    FROM Appointment A
    JOIN deleted Del ON A.Doctor_ID = Del.Doctor_ID
    WHERE A.Status = 'Scheduled';

END;


-----------------------------------------------------------------------------
CREATE TRIGGER trg_PreventOverlappingAppointments
ON Appointment
INSTEAD OF INSERT
AS
BEGIN
    IF EXISTS (
        SELECT 1
        FROM Appointment A
        JOIN inserted I ON A.Doctor_ID = I.Doctor_ID
        WHERE A.Appointment_DateTime = I.Appointment_DateTime
    )
    BEGIN
        RAISERROR ('Doctor already has an appointment at this time.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END

    INSERT INTO Appointment (Appointment_DateTime, Patient_ID, Doctor_ID, Cost)
    SELECT Appointment_DateTime, Patient_ID, Doctor_ID, Cost
    FROM inserted;
END;

-------------------------------------------------------------------------------------
CREATE TRIGGER trg_PreventAppointmentDeletion
ON Appointment
INSTEAD OF DELETE
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE A
    SET A.Status = 'Cancelled'
    FROM Appointment A
    JOIN deleted d ON A.Appointment_ID = d.Appointment_ID
    WHERE A.Status <> 'Cancelled';

    PRINT 'Appointment(s) marked as cancelled instead of being deleted.';

END;

-------------------------------------------------------------------------------
CREATE TRIGGER trg_RefundCancelledAppointment
ON Appointment
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    IF UPDATE(Status)
    BEGIN
        UPDATE P
        SET P.PaymentStatus = 'Refunded'
        FROM Payment P
        JOIN inserted i ON P.Appointment_ID = i.Appointment_ID
        JOIN deleted d ON P.Appointment_ID = d.Appointment_ID
        WHERE i.Status = 'Cancelled' AND d.Status <> 'Cancelled';
		--we can add sth here for giving back payements (log ...)
    END
END;