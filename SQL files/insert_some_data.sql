-- Inserting data into Specialization table
INSERT INTO Specialization (Title, Description) VALUES
('Cardiology', 'Heart and blood vessels specialist'),
('Neurology', 'Brain and nervous system specialist'),
('Pediatrics', 'Child health specialist'),
('Dermatology', 'Skin and hair specialist'),
('Orthopedics', 'Bones and muscles specialist'),
('Ophthalmology', 'Eye care specialist'),
('Psychiatry', 'Mental health specialist'),
('Gastroenterology', 'Digestive system specialist'),
('Endocrinology', 'Hormone and metabolism specialist'),
('Oncology', 'Cancer specialist');


-- Inserting data into Patient table (10 records)
INSERT INTO Patient (First_Name, Last_Name, Birth_Date, Phone_Number) VALUES
('John', 'Doe', '1990-05-10', '09121234567'),
('Jane', 'Smith', '1985-03-25', '09351239876'),
('Michael', 'Johnson', '2000-11-02', '09201231234'),
('Emily', 'Brown', '1993-08-15', '09123456789'),
('David', 'Williams', '1978-12-01', '09361234567'),
('Sarah', 'Jones', '1995-07-20', '09191112233'),
('Robert', 'Miller', '1980-01-05', '09104445566'),
('Laura', 'Davis', '2002-09-12', '09377778899'),
('Chris', 'Garcia', '1975-04-30', '09159990011'),
('Maria', 'Rodriguez', '1998-02-18', '09301230000');


-- Inserting data into Doctor table (10 records, linking to Specialization_ID)
INSERT INTO Doctor (FirstName, LastName, PhoneNumber, Specialization_ID, Visit_Fee, IsDeleted) VALUES
('Dr. Alex', 'Chen', '09123456789', 1, 12.5, 0), -- Cardiology
('Dr. Brenda', 'Lee', '09121234567', 3, 14.0, 0), -- Pediatrics
('Dr. Charles', 'Wang', '09129876543', 2, 50.0, 0), -- Neurology
('Dr. Diana', 'Nguyen', '09351239876', 4, 45.0, 0), -- Dermatology
('Dr. Ethan', 'Kim', '09384567890', 5, 32.2, 0), -- Orthopedics
('Dr. Fiona', 'Scott', '09125556677', 6, 20.0, 0), -- Ophthalmology
('Dr. George', 'Hall', '09334445588', 7, 60.0, 0), -- Psychiatry
('Dr. Hannah', 'Clark', '09101012020', 8, 30.0, 0), -- Gastroenterology
('Dr. Ian', 'Lewis', '09113334455', 9, 25.0, 0), -- Endocrinology
('Dr. Jessica', 'Young', '09367778899', 10, 70.0, 0); -- Oncology

-- Inserting data into Appointment table (10 records with Status)
INSERT INTO Appointment (Appointment_DateTime, Patient_ID, Doctor_ID, Cost, Status) VALUES
('2025-05-06 10:00:00', 1, 1, 12.5, 'Completed'), -- Completed appointment
('2025-05-06 11:00:00', 2, 2, 14.0, 'Scheduled'), -- Scheduled appointment
('2025-05-07 09:30:00', 3, 3, 50.0, 'Completed'), -- Completed appointment
('2025-05-08 14:00:00', 4, 4, 45.0, 'Cancelled'), -- Cancelled appointment
('2025-05-08 15:30:00', 5, 5, 32.2, 'Scheduled'), -- Scheduled appointment
('2025-05-09 10:00:00', 6, 6, 20.0, 'Completed'), -- Completed appointment
('2025-05-09 14:00:00', 7, 7, 60.0, 'Scheduled'), -- Scheduled appointment
('2025-05-10 09:00:00', 8, 8, 30.0, 'Completed'), -- Completed appointment
('2025-05-10 11:00:00', 9, 9, 25.0, 'Cancelled'), -- Cancelled appointment
('2025-05-11 16:00:00', 10, 10, 70.0, 'Scheduled'); -- Scheduled appointment


-- Inserting data into Payment table (at least 6 records, some intentional unpaid for testing)
INSERT INTO Payment (Appointment_ID, Payment_Method, PaymentStatus) VALUES
(1, 'Credit Card', 'Paid'),
(3, 'Online', 'Paid'),
(5, 'Cash', 'Paid'),
(6, 'Online', 'Paid'),
(8, 'Cash', 'Paid'),
(10, 'Credit Card', 'Paid');


-- Inserting data into Prescription table (at least 8 records)
INSERT INTO Prescription (Appointment_ID, Medication_Name, Dosage) VALUES
(1, 'Paracetamol', '500mg every 6 hours'),
(1, 'Vitamin C', '1000mg daily'),
(3, 'Amoxicillin', '250mg three times a day'),
(6, 'Eye Drops', '2 drops in each eye, twice daily'),
(7, 'Sertraline', '50mg daily'),
(7, 'Xanax', '0.25mg as needed'),
(8, 'Omeprazole', '20mg daily before breakfast'),
(10, 'Chemotherapy Drug X', 'Dosage as per protocol');


-- Inserting data into Patient_Medical_History table (10 records)
INSERT INTO Patient_Medical_History (Patient_ID, Condition_Title, Condition_Description) VALUES
(1, 'Diabetes', 'Type 2 diabetes diagnosed 5 years ago'),
(2, 'Hypertension', 'High blood pressure, under medication'),
(3, 'Allergy', 'Allergic to penicillin'),
(4, 'Asthma', 'Mild asthma since childhood'),
(5, 'Migraines', 'Chronic migraines triggered by stress'),
(6, 'Myopia', 'Nearsightedness, uses corrective lenses'),
(7, 'Depression', 'Diagnosed clinical depression, undergoing therapy'),
(8, 'GERD', 'Gastroesophageal Reflux Disease'),
(9, 'Hypothyroidism', 'Underactive thyroid, on medication'),
(10, 'Breast Cancer', 'Diagnosed 1 year ago, post-surgery');



-- Select statements to verify data (optional, for your reference)
select * from Patient_Medical_History;
select * from Prescription;
select * from Payment;
select * from Appointment;
select * from Patient;
select * from Doctor;
select * from Specialization;