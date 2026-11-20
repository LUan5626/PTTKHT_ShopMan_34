-- ShopMan - CSDL cho Module 1 (Tim kiem mat hang) va Module 2 (Duyet don + Xuat kho)
-- Ten bang / cot lay theo so do CSDL (hau to 4). Chay bang MySQL 8.
-- Luu y: bang Invoice4 co them cot totalAmount (so do CSDL can bo sung cot nay).

SET NAMES utf8mb4;   -- bắt buộc: để tiếng Việt không bị lỗi font khi nhập dữ liệu
DROP DATABASE IF EXISTS shopman;
CREATE DATABASE shopman CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE shopman;

CREATE TABLE User4 (
  id        INT AUTO_INCREMENT PRIMARY KEY,
  userName  VARCHAR(255) NOT NULL UNIQUE,
  passWord  VARCHAR(255) NOT NULL,
  fullName  VARCHAR(255) NOT NULL,
  phone     VARCHAR(15),
  email     VARCHAR(255),
  address   VARCHAR(255)
) ENGINE=InnoDB;

CREATE TABLE Staff4 (
  User4id     INT PRIMARY KEY,
  jobPosition VARCHAR(255),
  FOREIGN KEY (User4id) REFERENCES User4(id)
) ENGINE=InnoDB;

CREATE TABLE Customer4 (
  User4id        INT PRIMARY KEY,
  memberShipCode VARCHAR(15),
  memberShipDate DATE NULL,
  FOREIGN KEY (User4id) REFERENCES User4(id)
) ENGINE=InnoDB;

CREATE TABLE SalesStaff4 (
  Staff4User4id INT PRIMARY KEY,
  FOREIGN KEY (Staff4User4id) REFERENCES Staff4(User4id)
) ENGINE=InnoDB;

CREATE TABLE DeliveryStaff4 (
  Staff4User4id INT PRIMARY KEY,
  FOREIGN KEY (Staff4User4id) REFERENCES Staff4(User4id)
) ENGINE=InnoDB;

CREATE TABLE ProductCategory4 (
  id           INT AUTO_INCREMENT PRIMARY KEY,
  categoryName VARCHAR(255) NOT NULL
) ENGINE=InnoDB;

CREATE TABLE Product4 (
  id                 INT AUTO_INCREMENT PRIMARY KEY,
  productName        VARCHAR(255) NOT NULL,
  sellingPrice       DECIMAL(12,5) NOT NULL,
  image              VARCHAR(255) NULL,
  description        VARCHAR(255) NULL,
  inventory          INT NOT NULL DEFAULT 0,
  ProductCategory4id INT NOT NULL,
  CHECK (inventory >= 0),
  FOREIGN KEY (ProductCategory4id) REFERENCES ProductCategory4(id)
) ENGINE=InnoDB;

CREATE TABLE Order4 (
  id                          INT AUTO_INCREMENT PRIMARY KEY,
  orderDate                   DATE NOT NULL,
  status                      VARCHAR(255) NOT NULL,        -- 'Chưa xuất' | 'Đã xuất'
  totalAmount                 DECIMAL(12,5) NOT NULL,
  SalesStaff4Staff4User4id    INT NULL,
  Customer4User4id            INT NOT NULL,
  DeliveryStaff4Staff4User4id INT NULL,
  FOREIGN KEY (SalesStaff4Staff4User4id)    REFERENCES SalesStaff4(Staff4User4id),
  FOREIGN KEY (Customer4User4id)            REFERENCES Customer4(User4id),
  FOREIGN KEY (DeliveryStaff4Staff4User4id) REFERENCES DeliveryStaff4(Staff4User4id)
) ENGINE=InnoDB;

CREATE TABLE OrderDetail4 (
  id           INT AUTO_INCREMENT PRIMARY KEY,
  quantity     INT NOT NULL,
  sellingPrice DECIMAL(12,5) NOT NULL,
  Order4id     INT NOT NULL,
  Product4id   INT NOT NULL,
  FOREIGN KEY (Order4id)   REFERENCES Order4(id),
  FOREIGN KEY (Product4id) REFERENCES Product4(id)
) ENGINE=InnoDB;

CREATE TABLE Invoice4 (
  id          INT AUTO_INCREMENT PRIMARY KEY,
  createdDate DATE NOT NULL,
  totalAmount DECIMAL(12,5) NOT NULL,
  Order4id    INT NOT NULL UNIQUE,
  FOREIGN KEY (Order4id) REFERENCES Order4(id)
) ENGINE=InnoDB;

-- ---------------- DU LIEU MAU ----------------
-- Mat khau mau cua moi tai khoan la 123456 (luu dang bam PBKDF2, xem util/PasswordUtil4.java).
INSERT INTO User4 (id,userName,passWord,fullName,phone,email,address) VALUES
 (1,'giaohang01', 'pbkdf2$120000$SMzgxR87Tva5eICiE7cTsw==$KIL6lPpEkZTKqMgOoWNW63kgzxpb+5dYfjWXGj9TA7k=','Lê Văn C',    '0901 111 111','c@example.com','Hà Nội'),
 (2,'giaohang02', 'pbkdf2$120000$/FIoQLztk5lOn8qq5xOe3w==$BLarl1r0B+256Ye/HFxBIrU7272YOme6F73syI/wguI=','Phạm Văn D',  '0902 222 222','d@example.com','Hà Nội'),
 (3,'giaohang03', 'pbkdf2$120000$5MSRNy9cfakr44yBFB0nTg==$XQrYNnqGLmoPgVEGG2wMGQXl4AonTYbktmozm1v9q0M=','Hoàng Thị E', '0903 333 333','e@example.com','Hà Nội'),
 (4,'banhang01',  'pbkdf2$120000$U+yuyVNaC4I23EBjZTMwYQ==$NjjzDRpm3MOjQz13+cR9EnJmKVtLDWODVnVf1N4nNpQ=','Nguyễn Thị G','0912 000 004','g@example.com','Hà Nội'),
 (5,'khach01',    'pbkdf2$120000$ATskFnXkU0qXdaDIkw0IIg==$69rncqnTz2VAlrkJG5mP8ObZWOhSD665eduPx8ce2E8=','Nguyễn Văn A','0911 000 001','a@example.com','12 Trần Phú, Hà Nội'),
 (6,'khach02',    'pbkdf2$120000$3o0+s+AV7l2I/mBCu8UJ0g==$hX8ge+M1jyphFZ7kSIebXHoRCZYPJJhf464Bs4jJxc4=','Trần Thị B',  '0911 000 002','b@example.com','45 Nguyễn Trãi, Hà Nội'),
 (7,'khach03',    'pbkdf2$120000$Fx4mA5JoTAZXVcoH+7p3QA==$aWnNgihD2uLLvB3e8VW1koZhGYm7r5r00tVbTTI7md4=','Võ Thị F',    '0911 000 003','f@example.com','8 Láng Hạ, Hà Nội');

INSERT INTO Staff4 (User4id,jobPosition) VALUES
 (1,'Nhân viên giao hàng'),(2,'Nhân viên giao hàng'),(3,'Nhân viên giao hàng'),(4,'Nhân viên bán hàng');
INSERT INTO Customer4 (User4id,memberShipCode,memberShipDate) VALUES
 (5,'TV001','2026-09-15'),(6,NULL,NULL),(7,NULL,NULL);
INSERT INTO SalesStaff4 (Staff4User4id) VALUES (4);
INSERT INTO DeliveryStaff4 (Staff4User4id) VALUES (1),(2),(3);

INSERT INTO ProductCategory4 (id,categoryName) VALUES
 (1,'Sữa'),(2,'Dầu ăn & gia vị'),(3,'Gạo & thực phẩm khô'),(4,'Hóa phẩm');

INSERT INTO Product4 (id,productName,sellingPrice,image,description,inventory,ProductCategory4id) VALUES
 (1,'Sữa tươi Vinamilk 1L',   32000, NULL,'Sữa tươi tiệt trùng không đường, hộp 1 lít',120,1),
 (2,'Sữa đặc Ông Thọ 380g',   24000, NULL,'Sữa đặc có đường, lon 380g',85,1),
 (3,'Sữa chua Vinamilk 100g',  7000, NULL,'Sữa chua có đường, hộp 100g',240,1),
 (4,'Dầu ăn Simply 1L',       62000, NULL,'Dầu đậu nành nguyên chất, chai 1 lít',60,2),
 (5,'Gạo ST25 5kg',          135000, NULL,'Gạo thơm ST25, túi 5kg',40,3),
 (6,'Mì Hảo Hảo gói',          4500, NULL,'Mì ăn liền tôm chua cay, gói 75g',500,3),
 (7,'Nước mắm Nam Ngư 500ml', 38000, NULL,'Nước mắm cá cơm, chai 500ml',90,2),
 (8,'Bột giặt OMO 3kg',      120000, NULL,'Bột giặt cho máy giặt, túi 3kg',30,4);

INSERT INTO Order4 (id,orderDate,status,totalAmount,SalesStaff4Staff4User4id,Customer4User4id,DeliveryStaff4Staff4User4id) VALUES
 (1,'2026-10-29','Chưa xuất',350000,NULL,5,NULL),
 (2,'2026-10-30','Chưa xuất',520000,NULL,6,NULL),
 (3,'2026-10-31','Chưa xuất',185000,NULL,7,NULL);

INSERT INTO OrderDetail4 (id,quantity,sellingPrice,Order4id,Product4id) VALUES
 (1,2,135000,1,5),(2,1,62000,1,4),(3,4,4500,1,6),
 (4,3,7000,2,3),(5,2,62000,2,4),(6,1,135000,2,5),(7,2,120000,2,8),
 (8,1,135000,3,5),(9,1,32000,3,1),(10,4,4500,3,6);
