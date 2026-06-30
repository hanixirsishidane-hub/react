/* ============================================================
   PAYROLL INFORMATION SYSTEM - DATABASE SCRIPT
   SQL Server Database
   5 Tables: Departments, Positions, Employees, Attendance, Payroll
   ============================================================ */

CREATE DATABASE PayrollInformationSystem;
GO

USE PayrollInformationSystem;
GO

/* ============================================================
   1. DEPARTMENTS TABLE
   ============================================================ */
CREATE TABLE Departments (
    DepartmentID    INT IDENTITY(1,1) PRIMARY KEY,
    DepartmentName  NVARCHAR(100) NOT NULL,
    Description     NVARCHAR(255) NULL
);
GO

/* ============================================================
   2. POSITIONS TABLE
   ============================================================ */
CREATE TABLE Positions (
    PositionID      INT IDENTITY(1,1) PRIMARY KEY,
    PositionTitle   NVARCHAR(100) NOT NULL,
    BaseSalary      DECIMAL(10,2) NOT NULL,
    Description     NVARCHAR(255) NULL
);
GO

/* ============================================================
   3. EMPLOYEES TABLE (also used for Login Page)
   ============================================================ */
CREATE TABLE Employees (
    EmployeeID      INT IDENTITY(1,1) PRIMARY KEY,
    FullName        NVARCHAR(100) NOT NULL,
    Username        NVARCHAR(50)  NOT NULL UNIQUE,
    Password        NVARCHAR(100) NOT NULL,
    DepartmentID    INT NOT NULL,
    PositionID      INT NOT NULL,
    Phone           NVARCHAR(20)  NULL,
    Email           NVARCHAR(100) NULL,
    HireDate        DATE NOT NULL,

    CONSTRAINT FK_Employees_Departments FOREIGN KEY (DepartmentID)
        REFERENCES Departments(DepartmentID),
    CONSTRAINT FK_Employees_Positions FOREIGN KEY (PositionID)
        REFERENCES Positions(PositionID)
);
GO

/* ============================================================
   4. ATTENDANCE TABLE
   ============================================================ */
CREATE TABLE Attendance (
    AttendanceID    INT IDENTITY(1,1) PRIMARY KEY,
    EmployeeID      INT NOT NULL,
    AttendanceDate  DATE NOT NULL,
    Status          NVARCHAR(20) NOT NULL DEFAULT 'Present', -- Present / Absent / Leave
    TimeIn          TIME NULL,
    TimeOut         TIME NULL,

    CONSTRAINT FK_Attendance_Employees FOREIGN KEY (EmployeeID)
        REFERENCES Employees(EmployeeID)
);
GO

/* ============================================================
   5. PAYROLL TABLE
   ============================================================ */
CREATE TABLE Payroll (
    PayrollID       INT IDENTITY(1,1) PRIMARY KEY,
    EmployeeID      INT NOT NULL,
    PayMonth        NVARCHAR(20) NOT NULL,   -- e.g. 'June 2026'
    BasicSalary     DECIMAL(10,2) NOT NULL,
    Allowances      DECIMAL(10,2) NOT NULL DEFAULT 0,
    Deductions      DECIMAL(10,2) NOT NULL DEFAULT 0,
    NetSalary       AS (BasicSalary + Allowances - Deductions) PERSISTED,
    PaymentDate     DATE NULL,

    CONSTRAINT FK_Payroll_Employees FOREIGN KEY (EmployeeID)
        REFERENCES Employees(EmployeeID)
);
GO

/* ============================================================
   SAMPLE RECORDS
   ============================================================ */

-- Departments
INSERT INTO Departments (DepartmentName, Description) VALUES
('Human Resources', 'Handles recruitment and staff welfare'),
('Finance', 'Handles accounting and payroll processing'),
('IT', 'Handles software and technical support'),
('Sales', 'Handles customer sales and marketing');

-- Positions
INSERT INTO Positions (PositionTitle, BaseSalary, Description) VALUES
('Manager', 1200.00, 'Department manager'),
('Accountant', 800.00, 'Handles financial records'),
('Software Developer', 1000.00, 'Builds and maintains software'),
('Sales Representative', 600.00, 'Handles client sales');

-- Employees
INSERT INTO Employees (FullName, Username, Password, DepartmentID, PositionID, Phone, Email, HireDate) VALUES
('Ahmed Yusuf', 'ahmed.yusuf', 'Ahmed@123', 1, 1, '0617771111', 'ahmed@company.com', '2023-02-01'),
('Hodan Ali', 'hodan.ali', 'Hodan@123', 2, 2, '0617772222', 'hodan@company.com', '2023-05-15'),
('Khalid Mohamed', 'khalid.m', 'Khalid@123', 3, 3, '0617773333', 'khalid@company.com', '2024-01-10'),
('Sahra Abdi', 'sahra.abdi', 'Sahra@123', 4, 4, '0617774444', 'sahra@company.com', '2024-03-20');

-- Attendance
INSERT INTO Attendance (EmployeeID, AttendanceDate, Status, TimeIn, TimeOut) VALUES
(1, '2026-06-17', 'Present', '08:00', '17:00'),
(2, '2026-06-17', 'Present', '08:15', '17:00'),
(3, '2026-06-17', 'Absent', NULL, NULL),
(4, '2026-06-17', 'Leave', NULL, NULL),
(1, '2026-06-18', 'Present', '08:05', '17:00');

-- Payroll
INSERT INTO Payroll (EmployeeID, PayMonth, BasicSalary, Allowances, Deductions, PaymentDate) VALUES
(1, 'May 2026', 1200.00, 100.00, 50.00, '2026-06-01'),
(2, 'May 2026', 800.00, 50.00, 30.00, '2026-06-01'),
(3, 'May 2026', 1000.00, 80.00, 40.00, '2026-06-01'),
(4, 'May 2026', 600.00, 30.00, 20.00, '2026-06-01');
GO

/* ============================================================
   USEFUL SAMPLE QUERIES (for testing)
   ============================================================ */

-- View all employees with department and position
SELECT e.EmployeeID, e.FullName, d.DepartmentName, p.PositionTitle, p.BaseSalary
FROM Employees e
JOIN Departments d ON e.DepartmentID = d.DepartmentID
JOIN Positions p ON e.PositionID = p.PositionID;

-- Search employee by name
SELECT * FROM Employees WHERE FullName LIKE '%Ahmed%';

-- View payroll report with net salary
SELECT pr.PayrollID, e.FullName, pr.PayMonth, pr.BasicSalary,
       pr.Allowances, pr.Deductions, pr.NetSalary, pr.PaymentDate
FROM Payroll pr
JOIN Employees e ON pr.EmployeeID = e.EmployeeID;

-- View attendance report for a specific date
SELECT a.AttendanceID, e.FullName, a.AttendanceDate, a.Status, a.TimeIn, a.TimeOut
FROM Attendance a
JOIN Employees e ON a.EmployeeID = e.EmployeeID
WHERE a.AttendanceDate = '2026-06-17';
