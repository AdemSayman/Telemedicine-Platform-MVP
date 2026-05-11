-- Veritabanı Oluşturma
CREATE DATABASE IF NOT EXISTS telemedicine_db;
USE telemedicine_db;

-- 1. Kullanıcılar Tablosu (Hasta ve Doktorlar için ortak)
CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    phone_number VARCHAR(20) UNIQUE NOT NULL, -- Firebase OTP için [cite: 14]
    full_name VARCHAR(100) NOT NULL,
    role ENUM('patient', 'doctor') NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- 2. Doktor Detayları Tablosu
CREATE TABLE doctors (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    specialty VARCHAR(100) NOT NULL,
    experience_years INT,
    is_available BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- 3. Randevular Tablosu
CREATE TABLE appointments (
    id INT AUTO_INCREMENT PRIMARY KEY,
    patient_id INT,
    doctor_id INT,
    appointment_date DATETIME NOT NULL,
    status ENUM('pending', 'paid', 'completed', 'cancelled') DEFAULT 'pending', -- [cite: 31]
    payment_status BOOLEAN DEFAULT FALSE, -- Mobile Money onayı için [cite: 29]
    agora_token VARCHAR(255), -- Video görüşme yetkilendirmesi için [cite: 8]
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (patient_id) REFERENCES users(id),
    FOREIGN KEY (doctor_id) REFERENCES doctors(id)
) ENGINE=InnoDB;

-- 4. Reçeteler ve Tıbbi Kayıtlar Tablosu
CREATE TABLE prescriptions (
    id INT AUTO_INCREMENT PRIMARY KEY,
    appointment_id INT,
    diagnosis TEXT,
    medications TEXT,
    qr_code_data TEXT, -- Node.js tarafında üretilecek QR veri dizisi [cite: 43]
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (appointment_id) REFERENCES appointments(id)
) ENGINE=InnoDB;

-- Hızlı sorgulama için indeksler
CREATE INDEX idx_phone ON users(phone_number);
CREATE INDEX idx_appointment_date ON appointments(appointment_date);