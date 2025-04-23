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

-- Admin
INSERT INTO Users (full_name, email, password_hash, role, status)
VALUES ('Admin Root', 'admin@example.com', '12345', 'admin', 'active');

-- Gói dịch vụ
INSERT INTO ServicePackages (package_name, description, price, duration_days, question_limit)
VALUES
  ('free',    'Goi mien phi voi 10 cau hoi ve phap luat co ban, ho tro tra cuu van ban gioi han',                0.00,      100, 10),
  ('pro',     'Goi nang cao mo rong pham vi cau hoi, 50 cau hoi moi ngay, tra loi nhanh va chinh xac hon',      99000.00,   30, 50),
  ('premium', 'Goi cao cap ho tro den 200 cau hoi moi thang, phan tich va xu ly tinh huong phap ly chuyen sau', 199000.00,  30, 200),
  ('enterprise', 'Goi doanh nghiep voi giai phap API rieng, tuy chinh theo nhu cau va trien khai he thong rieng biet', 0.00, 365, 0);

-- Thêm 20 user
INSERT INTO Users (full_name, email, password_hash, role, status) VALUES 
  ('Nguyen Van A', 'a@example.com', 'pass1', 'user', 'active'),
  ('Tran Thi B', 'b@example.com', 'pass2', 'user', 'active'),
  ('Le Van C', 'c@example.com', 'pass3', 'user', 'inactive'),
  ('Pham Thi D', 'd@example.com', 'pass4', 'user', 'banned'),
  ('Hoang Van E', 'e@example.com', 'pass5', 'user', 'active'),
  ('Do Thi F', 'f@example.com', 'pass6', 'user', 'inactive'),
  ('Vo Van G', 'g@example.com', 'pass7', 'user', 'active'),
  ('Bui Thi H', 'h@example.com', 'pass8', 'user', 'banned'),
  ('Dang Van I', 'i@example.com', 'pass9', 'user', 'active'),
  ('Ngo Thi J', 'j@example.com', 'pass10', 'user', 'active'),
  ('Mai Van K', 'k@example.com', 'pass11', 'user', 'active'),
  ('Vu Thi L', 'l@example.com', 'pass12', 'user', 'active'),
  ('Ly Van M', 'm@example.com', 'pass13', 'user', 'inactive'),
  ('Ton Nu N', 'n@example.com', 'pass14', 'user', 'active'),
  ('Phan Van O', 'o@example.com', 'pass15', 'user', 'banned'),
  ('Nguyen Thi P', 'p@example.com', 'pass16', 'user', 'active'),
  ('Tran Van Q', 'q@example.com', 'pass17', 'user', 'inactive'),
  ('Do Thi R', 'r@example.com', 'pass18', 'user', 'active'),
  ('Vo Van S', 's@example.com', 'pass19', 'user', 'active'),
  ('Bui Thi T', 't@example.com', 'pass20', 'user', 'active');

-- Subscriptions (4 người dùng Free: id 2,5,11,14)
INSERT INTO Subscriptions (user_id, package_id, start_time, end_time, status) VALUES 
  (2, 1, NOW(), DATE_ADD(NOW(), INTERVAL 100 DAY), 'active'),
  (3, 2, NOW(), DATE_ADD(NOW(), INTERVAL 30 DAY), 'active'),
  (4, 3, NOW(), DATE_ADD(NOW(), INTERVAL 30 DAY), 'expired'),
  (5, 1, NOW(), DATE_ADD(NOW(), INTERVAL 100 DAY), 'active'),
  (6, 2, NOW(), DATE_ADD(NOW(), INTERVAL 30 DAY), 'expired'),
  (7, 3, NOW(), DATE_ADD(NOW(), INTERVAL 30 DAY), 'active'),
  (8, 2, NOW(), DATE_ADD(NOW(), INTERVAL 30 DAY), 'active'),
  (9, 3, NOW(), DATE_ADD(NOW(), INTERVAL 30 DAY), 'active'),
  (10,2, NOW(), DATE_ADD(NOW(), INTERVAL 30 DAY), 'active'),
  (11,1, NOW(), DATE_ADD(NOW(), INTERVAL 100 DAY), 'active'),
  (12,2, NOW(), DATE_ADD(NOW(), INTERVAL 30 DAY), 'active'),
  (13,3, NOW(), DATE_ADD(NOW(), INTERVAL 30 DAY), 'expired'),
  (14,1, NOW(), DATE_ADD(NOW(), INTERVAL 100 DAY), 'active'),
  (15,2, NOW(), DATE_ADD(NOW(), INTERVAL 30 DAY), 'expired'),
  (16,3, NOW(), DATE_ADD(NOW(), INTERVAL 30 DAY), 'active'),
  (17,2, NOW(), DATE_ADD(NOW(), INTERVAL 30 DAY), 'active'),
  (18,3, NOW(), DATE_ADD(NOW(), INTERVAL 30 DAY), 'active'),
  (19,2, NOW(), DATE_ADD(NOW(), INTERVAL 30 DAY), 'active'),
  (20,3, NOW(), DATE_ADD(NOW(), INTERVAL 30 DAY), 'active'),
  (21,2, NOW(), DATE_ADD(NOW(), INTERVAL 30 DAY), 'active');

-- Payments (bỏ các user có package_id = 1 (Free))
INSERT INTO Payments (user_id, method, amount, payment_time, status, package_id) VALUES 
  (3,  'vnpay',   99000.00, NOW(), 'success', 2),
  (4,  'paypal',  199000.00, NOW(), 'success', 3),
  (6,  'vnpay',   99000.00, NOW(), 'failed', 2),
  (7,  'stripe',  199000.00, NOW(), 'success', 3),
  (8,  'paypal',  99000.00, NOW(), 'success', 2),
  (9,  'stripe',  199000.00, NOW(), 'success', 3),
  (10, 'momo',    99000.00, NOW(), 'success', 2),
  (12, 'vnpay',   99000.00, NOW(), 'success', 2),
  (13, 'paypal',  199000.00, NOW(), 'failed', 3),
  (15, 'vnpay',   99000.00, NOW(), 'pending', 2),
  (16, 'stripe',  199000.00, NOW(), 'success', 3),
  (17, 'momo',    99000.00, NOW(), 'success', 2),
  (18, 'vnpay',   199000.00, NOW(), 'success', 3),
  (19, 'paypal',  99000.00, NOW(), 'success', 2),
  (20, 'stripe',  199000.00, NOW(), 'success', 3),
  (21, 'vnpay',   99000.00, NOW(), 'success', 2);

-- UsageQuota (dùng ON DUPLICATE để tránh lỗi nếu tồn tại)
INSERT INTO UsageQuota (user_id, usage_date, questions_asked, question_limit)
VALUES
  (2, CURDATE(), 2, 10),
  (3, CURDATE(), 25, 50),
  (4, CURDATE(), 170, 200),
  (5, CURDATE(), 3, 10),
  (6, CURDATE(), 50, 50),
  (7, CURDATE(), 150, 200),
  (8, CURDATE(), 14, 50),
  (9, CURDATE(), 199, 200),
  (10, CURDATE(), 22, 50),
  (11, CURDATE(), 1, 10),
  (12, CURDATE(), 49, 50),
  (13, CURDATE(), 150, 200),
  (14, CURDATE(), 7, 10),
  (15, CURDATE(), 12, 50),
  (16, CURDATE(), 178, 200),
  (17, CURDATE(), 10, 50),
  (18, CURDATE(), 200, 200),
  (19, CURDATE(), 35, 50),
  (20, CURDATE(), 160, 200),
  (21, CURDATE(), 20, 50)
ON DUPLICATE KEY UPDATE
  questions_asked = VALUES(questions_asked),
  question_limit = VALUES(question_limit);

-- FEEDBACK (khong dau)
INSERT INTO Feedback (user_id, content, timestamp) VALUES
-- User 2
(2, 'Dich vu rat huu ich.', NOW()),
(2, 'Toi muon co them ho tro phap ly chuyen sau.', NOW()),
-- User 3
(3, 'Cau tra loi nhanh va ro rang.', NOW()),
-- User 4
(4, 'Ung dung de dung nhung doi khi cham.', NOW()),
(4, 'Nen bo sung them muc luat doanh nghiep.', NOW()),
(4, 'Toi danh gia cao su nhiet tinh.', NOW()),
-- User 5
(5, 'Goi Free kha han che, nhung chap nhan duoc.', NOW()),
-- User 6
(6, 'Can them vi du minh hoa.', NOW()),
-- User 7
(7, 'Toi hai long voi toc do phan hoi.', NOW()),
(7, 'Co the cai thien giao dien nguoi dung.', NOW()),
-- User 8
(8, 'Moi thu deu on, se gioi thieu cho ban be.', NOW()),
-- User 9
(9, 'Kha on nhung doi khi loi ket noi.', NOW()),
(9, 'Toi mong co chatbot thong minh hon.', NOW()),
-- User 10
(10, 'Tra loi dung van de toi can.', NOW()),
-- User 11
(11, 'Toi moi dung thu, se danh gia sau.', NOW()),
-- User 12
(12, 'Toi can them ho tro ve phap luat hon nhan.', NOW()),
-- User 13
(13, 'Ung dung chay tot, chua thay loi.', NOW()),
(13, 'Dich vu tra phi rat dang tien.', NOW()),
-- User 14
(14, 'Hy vong co ban mobile trong tuong lai.', NOW()),
-- User 15
(15, 'Hoi dap nhanh va chi tiet.', NOW()),
(15, 'Hoi kho tim lai cau hoi cu.', NOW()),
-- User 16
(16, 'Giao dien dep va de dung.', NOW()),
-- User 17
(17, 'Toi dung hang ngay, rat on.', NOW()),
(17, 'Neu co them voice chatbot thi tot.', NOW()),
-- User 18
(18, 'Can cai thien he thong loc cau hoi.', NOW()),
-- User 19
(19, 'Phan hoi trong ngay la dieu toi thich.', NOW()),
-- User 20
(20, 'Toi danh gia 5 sao cho dich vu nay.', NOW()),
(20, 'Cau tra loi giup toi tiet kiem thoi gian.', NOW()),
(20, 'Nen co them phan tich theo luat hien hanh.', NOW()),
-- User 21
(21, 'Rat thich tinh nang theo doi goi dich vu.', NOW());
