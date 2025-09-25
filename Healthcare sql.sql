CREATE DATABASE Hospital_management;
USE Hospital_management;

	-- 	CREATING TABLES --
CREATE TABLE patients (
    patient_id VARCHAR(10) NOT NULL PRIMARY KEY,
    first_name VARCHAR(15) NOT NULL,
    last_name VARCHAR(15) NOT NULL,
    gender ENUM('M', 'F') NOT NULL,
    date_of_birth DATE NOT NULL,
    contact_number VARCHAR(15),
    address VARCHAR(50),
    registration_date DATE,
    insurance_provider VARCHAR(50) NOT NULL,
    insurance_number VARCHAR(50) NOT NULL,
    email VARCHAR(50)
);

CREATE TABLE doctors (
    doctor_id VARCHAR(10) NOT NULL PRIMARY KEY,
    first_name VARCHAR(15) NOT NULL,
    last_name VARCHAR(15) NOT NULL,
    specialization VARCHAR(50) NOT NULL,
    phone_number VARCHAR(15),
    years_experience INT,
    hospital_branch VARCHAR(50),
    email VARCHAR(50) UNIQUE
);

CREATE TABLE appointments (
    appointment_id VARCHAR(10) NOT NULL PRIMARY KEY,
    patient_id VARCHAR(10) NOT NULL,
    doctor_id VARCHAR(10) NOT NULL,
    appointment_date DATE NOT NULL,
    appointment_time TIME NOT NULL,
    reason_for_visit VARCHAR(20),
    status VARCHAR(50),
    CONSTRAINT fk_patient FOREIGN KEY (patient_id)
        REFERENCES patients (patient_id),
    CONSTRAINT fk_doctor FOREIGN KEY (doctor_id)
        REFERENCES doctors (doctor_id)
);

CREATE TABLE treatments (
    treatment_id VARCHAR(10) NOT NULL PRIMARY KEY,
    appointment_id VARCHAR(10) NOT NULL,
    treatment_type VARCHAR(25) NOT NULL,
    description VARCHAR(50),
    cost DECIMAL(10 , 2 ) NOT NULL,
    treatment_date DATE NOT NULL,
    CONSTRAINT fk_appointment FOREIGN KEY (appointment_id) REFERENCES appointments(appointment_id)
);

CREATE TABLE billing (
    bill_id VARCHAR(10) NOT NULL PRIMARY KEY,
    patient_id VARCHAR(10) NOT NULL,
    treatment_id VARCHAR(10) NOT NULL,
    bill_date DATE NOT NULL,
    amount DECIMAL(10 , 2 ) NOT NULL,
    payment_method VARCHAR(25) NOT NULL,
    payment_status VARCHAR(15) NOT NULL,
    CONSTRAINT fk_patients FOREIGN KEY (patient_id)
        REFERENCES patients (patient_id),
    CONSTRAINT fk_treatment FOREIGN KEY (treatment_id)
        REFERENCES treatments (treatment_id)
);

SELECT * FROM patients;
SELECT * FROM doctors;
SELECT * FROM appointments;
SELECT * FROM treatments;
SELECT * FROM billing;

--	EDA --
	--	PATIENTS --
SELECT 
    COUNT(*)
FROM
    patients
WHERE
    first_name IS NULL OR last_name IS NULL
        OR gender IS NULL
        OR date_of_birth IS NULL
        OR contact_number IS NULL
        OR address IS NULL
        OR registration_date IS NULL
        OR insurance_number IS NULL
        OR insurance_provider IS NULL
        OR email IS NULL;

	--	DOCTORS --
SELECT 
    COUNT(*)
FROM
    doctors
WHERE
    first_name IS NULL OR last_name IS NULL
        OR specialization IS NULL
        OR phone_number IS NULL
        OR years_experience IS NULL
        OR hospital_branch IS NULL
        OR email IS NULL;

	--	APPOINTMENTS --
SELECT 
    COUNT(*)
FROM
    appointments
WHERE
    appointment_date IS NULL
        OR appointment_time IS NULL
        OR reason_for_visit IS NULL
        OR status IS NULL;

	--	TREATMENTS --
SELECT 
    COUNT(*)
FROM
    treatments
WHERE
    treatment_type IS NULL
        OR description IS NULL
        OR cost IS NULL
        OR treatment_date IS NULL;

	--	BILLING --
SELECT 
    COUNT(*)
FROM
    billing
WHERE
    bill_date IS NULL OR amount IS NULL
        OR payment_method IS NULL
        OR payment_status IS NULL;
 
 
	--	ANALYSIS --
            -- PATIENTS --
-- Ques1: How many patients are registered in the hospital by gender?
SELECT 
    gender, COUNT(*) AS patient_count
FROM
    patients
GROUP BY gender;

-- Ques2: Age distribution of patients
SELECT 
    CASE
        WHEN YEAR(CURDATE()) - YEAR(date_of_birth) < 18 THEN '0-17'
        WHEN YEAR(CURDATE()) - YEAR(date_of_birth) BETWEEN 18 AND 35 THEN '18-35'
        WHEN YEAR(CURDATE()) - YEAR(date_of_birth) BETWEEN 36 AND 55 THEN '36-55'
        ELSE '56+'
    END AS age_group,
    COUNT(*) AS patient_count
FROM
    patients
GROUP BY age_group;

-- Ques3: Insurance provider patients
SELECT 
    insurance_provider, COUNT(*) AS patient_count
FROM
    patients
GROUP BY insurance_provider;

-- Ques4: Top 10 patients who spent the most money
SELECT 
    p.patient_id,
    p.first_name,
    p.last_name,
    SUM(b.amount) AS total_spent
FROM
    billing b
        JOIN
    patients p ON b.patient_id = p.patient_id
        JOIN
    treatments t ON b.treatment_id = t.treatment_id
WHERE
    b.payment_status = 'Paid'
GROUP BY p.patient_id , p.first_name , p.last_name
ORDER BY total_spent DESC
LIMIT 10;

-- Ques5: Insurance provider with the highest claims (billed via insurance)
SELECT 
    p.insurance_provider,
    SUM(b.amount) AS total_insurance_claims
FROM
    billing b
        JOIN
    patients p ON b.patient_id = p.patient_id
WHERE
    b.payment_method = 'Insurance'
        AND b.payment_status = 'paid'
GROUP BY p.insurance_provider
ORDER BY total_insurance_claims DESC;



		-- DOCTORS --
-- Ques6: Number of doctors per specialization
SELECT 
    specialization, COUNT(*) AS doctor_count
FROM
    doctors
GROUP BY specialization;

-- Ques7: Average years of experience by specialization
SELECT 
    specialization, AVG(years_experience) AS avg_exp
FROM
    doctors
GROUP BY specialization;

-- Ques8: Doctors per hospital branch
SELECT 
    hospital_branch, COUNT(*) AS doctor_count
FROM
    doctors
GROUP BY hospital_branch;

-- Ques9: Revenue per doctor
SELECT 
    d.doctor_id,
    d.first_name,
    d.last_name,
    d.specialization,
    d.hospital_branch,
    SUM(b.amount) AS total_revenue
FROM
    billing b 
        JOIN
   treatments t ON b.treatment_id = t.treatment_id
        JOIN
    appointments a ON t.appointment_id = a.appointment_id
        JOIN
    doctors d ON a.doctor_id = d.doctor_id
WHERE
    b.payment_status = 'paid'
GROUP BY d.doctor_id , d.first_name , d.last_name , d.specialization, d.hospital_branch
ORDER BY total_revenue DESC;




        -- AAPPOINTMENT --
-- Ques10: Number of appointment per month
SELECT 
    MONTH(appointment_date) AS month, COUNT(*) AS app_count
FROM
    appointments
GROUP BY MONTH(appointment_date)
ORDER BY month;


-- Ques11: Appointment status distribution
SELECT 
    status, COUNT(*) AS count
FROM
    appointments
GROUP BY status;

-- Ques12: Avg appointents per doctor
SELECT 
    d.doctor_id,
    d.first_name,
    d.last_name,
    d.specialization,
    ROUND(COUNT(a.appointment_id) / COUNT(DISTINCT d.doctor_id),2) AS avg_appointment_per_doctor
FROM
    doctors d
        LEFT JOIN
    appointments a ON d.doctor_id = a.doctor_id
GROUP BY d.doctor_id , d.first_name , d.last_name, d.specialization
ORDER BY avg_appointment_per_doctor DESC;


-- Ques13: Patients with most appointments
SELECT 
    p.patient_id,
    p.first_name,
    p.last_name,
    COUNT(a.appointment_id) AS total_appointments
FROM
    appointments a
        JOIN
    patients p ON a.patient_id = p.patient_id
GROUP BY p.patient_id , p.first_name , p.last_name
ORDER BY total_appointments DESC
LIMIT 10;

-- Ques14: Peak hours of appointments
SELECT 
    HOUR(appointment_time) AS hour_of_day,
    COUNT(*) AS total_appointments
FROM
    appointments
GROUP BY HOUR(appointment_time)
ORDER BY hour_of_day ASC;

-- Ques15: Doctor utilization rate
SELECT 
    d.doctor_id,
    d.first_name,
    d.last_name,
    d.specialization,
    ROUND((COUNT(a.appointment_id) * 100.0) / (SELECT 
                    COUNT(*)
                FROM
                    appointments),
            2) AS utilization_rate_percent
FROM
    doctors d
        LEFT JOIN
    appointments a ON d.doctor_id = a.doctor_id
GROUP BY d.doctor_id , d.first_name , d.last_name , d.specialization
ORDER BY utilization_rate_percent DESC;


-- Ques16: Average waiting time between registration and first appointment
SELECT 
    ROUND(AVG(DATEDIFF(first_appointment.first_appointment_date, p.registration_date)), 2) AS avg_waiting_days
FROM patients p
JOIN (
    SELECT 
        patient_id, 
        MIN(appointment_date) AS first_appointment_date
    FROM appointments
    GROUP BY patient_id
) AS first_appointment 
ON p.patient_id = first_appointment.patient_id;


     -- TREATMENT --
     
 -- Ques17: Most common reason for visit
SELECT 
    reason_for_visit, COUNT(*) AS count
FROM
    appointments
GROUP BY reason_for_visit
ORDER BY count ASC;    
     
-- Ques18: Most common treatment type
SELECT 
    treatment_type, COUNT(*) AS treatment_count
FROM
    treatments
GROUP BY treatment_type
ORDER BY treatment_count DESC;

-- Ques19: AVG treatment cost by type
SELECT 
    treatment_type, AVG(cost) AS avg_cost
FROM
    treatments
GROUP BY treatment_type;

-- Ques20: Treatments performed per month
SELECT 
    MONTH(treatment_date) AS month, COUNT(*) AS count
FROM
    treatments
GROUP BY MONTH(treatment_date)
ORDER BY month;

-- Ques21: Tretament cost per hospital branch
SELECT 
    d.hospital_branch,
    ROUND(AVG(t.cost), 2) AS avg_treatment_cost,
    MIN(t.cost) AS min_tretament_cost,
    MAX(t.cost) AS max_treatment_cost
FROM
    treatments t
        JOIN
    appointments a ON t.appointment_id = a.appointment_id
        JOIN
    doctors d ON a.doctor_id = d.doctor_id
GROUP BY d.hospital_branch
ORDER BY avg_treatment_cost DESC;

-- Ques22: Whcih hospital branch generates the most revenue
SELECT 
    d.hospital_branch, SUM(b.amount) AS total_revenue
FROM
    billing b
        JOIN
    treatments t ON b.treatment_id = t.treatment_id
        JOIN
    appointments a ON t.appointment_id = a.appointment_id
        JOIN
    doctors d ON a.doctor_id = d.doctor_id
WHERE
    b.payment_status = 'Paid'
GROUP BY d.hospital_branch
ORDER BY total_revenue DESC;


     -- BILLING --
-- Ques23: Total revenue by payment method
SELECT 
    payment_method, SUM(amount) AS total_revenue
FROM
    billing
WHERE
    payment_status = 'paid'
GROUP BY payment_method;

-- Ques24: Total revenue per month
SELECT 
    MONTH(bill_date) AS month, SUM(amount) AS total_revenue
FROM
    billing
WHERE
    payment_status = 'paid'
GROUP BY MONTH(bill_date)
ORDER BY month;

-- Ques25: Pending or failed payments
SELECT 
    payment_status,
    COUNT(*) AS count,
    SUM(amount) AS total_amount
FROM
    billing
WHERE
    payment_status IN ('pending' , 'failed')
GROUP BY payment_status;




