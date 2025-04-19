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
  package_id         INT             AUTO_INCREMENT PRIMARY KEY,
  package_name       VARCHAR(100)    NOT NULL,
  description        TEXT,
  price              DECIMAL(12,2)   NOT NULL,
  duration_days      INT             NOT NULL,      -- validity period in days
  question_limit     INT             NOT NULL       -- max questions per day
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

-- 7. Access logs
CREATE TABLE AccessLogs (
  log_id             INT             AUTO_INCREMENT PRIMARY KEY,
  user_id            INT             NOT NULL,
  action             ENUM('login','chat','feedback','payment') NOT NULL,
  timestamp          DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
  details            TEXT,
  FOREIGN KEY (user_id) REFERENCES Users(user_id) ON DELETE CASCADE
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