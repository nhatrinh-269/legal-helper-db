DROP DATABASE IF EXISTS legalhelperdb;

CREATE DATABASE legalhelperdb;

USE legalhelperdb;

-- 1. Users
CREATE TABLE Users (
  user_id            INT             AUTO_INCREMENT PRIMARY KEY,
  full_name          VARCHAR(255)    NOT NULL,
  email              VARCHAR(255)    NOT NULL UNIQUE,
  password_hash      VARCHAR(255)    NOT NULL,
  role               ENUM('admin','user')        NOT NULL,
  registration_time  DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
  status             ENUM('active','inactive','banned') DEFAULT 'active'
);

-- 2. Chat history
CREATE TABLE ChatHistory (
  chat_id            INT             AUTO_INCREMENT PRIMARY KEY,
  user_id            INT             NOT NULL,
  message_content    JSON            NOT NULL,
  timestamp          DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES Users(user_id) ON DELETE CASCADE
);

-- 3. Feedback
CREATE TABLE Feedback (
  feedback_id        INT             AUTO_INCREMENT PRIMARY KEY,
  user_id            INT             NOT NULL,
  content            TEXT            NOT NULL,
  timestamp          DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES Users(user_id) ON DELETE CASCADE
);

-- 4. Service packages
CREATE TABLE ServicePackages (
  package_id      INT             AUTO_INCREMENT PRIMARY KEY,
  package_name    VARCHAR(100)    NOT NULL,
  description     TEXT,
  price           DECIMAL(12,2)   NOT NULL,    
  duration_days   INT             NOT NULL,    
  question_limit  INT             NOT NULL     
);

-- 5. Subscriptions
CREATE TABLE Subscriptions (
  subscription_id    INT             AUTO_INCREMENT PRIMARY KEY,
  user_id            INT             NOT NULL,
  package_id         INT             NOT NULL,
  start_time         DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
  end_time           DATETIME,
  status             ENUM('active','expired') DEFAULT 'active',
  FOREIGN KEY (user_id) REFERENCES Users(user_id) ON DELETE CASCADE,
  FOREIGN KEY (package_id) REFERENCES ServicePackages(package_id) ON DELETE CASCADE
);

-- 6. Payments
CREATE TABLE Payments (
  payment_id         INT             AUTO_INCREMENT PRIMARY KEY,
  user_id            INT             NOT NULL,
  method             ENUM('momo','vnpay','paypal','stripe') NOT NULL,
  amount             DECIMAL(12,2)   NOT NULL,
  payment_time       DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
  status             ENUM('pending','success','failed') DEFAULT 'pending',
  package_id         INT,
  FOREIGN KEY (user_id) REFERENCES Users(user_id) ON DELETE CASCADE,
  FOREIGN KEY (package_id) REFERENCES ServicePackages(package_id) ON DELETE SET NULL
);

-- 8. Daily usage quota
CREATE TABLE UsageQuota (
  quota_id           INT             AUTO_INCREMENT PRIMARY KEY,
  user_id            INT             NOT NULL,
  usage_date         DATE            NOT NULL,
  questions_asked    INT             NOT NULL DEFAULT 0,
  question_limit     INT             NOT NULL,
  FOREIGN KEY (user_id) REFERENCES Users(user_id) ON DELETE CASCADE,
  UNIQUE KEY uq_user_date (user_id, usage_date)
);

INSERT INTO Users (full_name, email, password_hash, role, status)
VALUES ('Admin Root', 'admin@example.com', '12345', 'admin', 'active');

INSERT INTO ServicePackages (package_name, description, price, duration_days, question_limit) VALUES
  ('Free',
   'Hoi dap luat co ban\n✔ Xu ly van ban luat gioi han',
   0.00,
   100,
   10),
  ('Pro',
   'Mo rong pham vi luat\n✔ 50 cau hoi/ngay\n✔ Tra loi chinh xac hon\n✔ Ho tro email 24h',
   99000.00,
   30,
   50),
  ('Premium',
   'Tang gioi han len 200 cau hoi\n✔ Phan tich, xu ly phap ly\n✔ Ho tro chuyen sau',
   199000.00,
   30,
   200);