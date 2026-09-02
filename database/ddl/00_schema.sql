-- Initial SQL Server DDL for Aavronex ERP master schema
-- Created: 2026-09-02
-- Purpose: Core tables for Companies, Branches, Security, CRM, Products, Inventory, Sales, Purchase,
-- Manufacturing, Machines, HR, Accounting, Import/Export, Audit, Documents, Notifications.

SET NOCOUNT ON;

-- Common audit columns: CreatedBy (FK to Users), CreatedAt, UpdatedBy, UpdatedAt, IsDeleted

CREATE SCHEMA IF NOT EXISTS dbo;

-- Companies
CREATE TABLE dbo.Companies (
    CompanyId INT IDENTITY(1,1) PRIMARY KEY,
    Name NVARCHAR(200) NOT NULL,
    LogoUrl NVARCHAR(1000),
    Address NVARCHAR(500),
    City NVARCHAR(150),
    State NVARCHAR(150),
    Country NVARCHAR(150),
    Pincode NVARCHAR(50),
    Mobile NVARCHAR(50),
    Email NVARCHAR(200),
    Website NVARCHAR(200),
    GSTIN NVARCHAR(50),
    PAN NVARCHAR(50),
    CIN NVARCHAR(50),
    IEC NVARCHAR(50),
    BankDetails NVARCHAR(MAX),
    FinancialYearStart DATE,
    IsActive BIT DEFAULT 1,
    CreatedBy INT NULL,
    CreatedAt DATETIME2 DEFAULT SYSUTCDATETIME(),
    UpdatedBy INT NULL,
    UpdatedAt DATETIME2 NULL,
    IsDeleted BIT DEFAULT 0
);

-- Branches
CREATE TABLE dbo.Branches (
    BranchId INT IDENTITY(1,1) PRIMARY KEY,
    CompanyId INT NOT NULL,
    Name NVARCHAR(200) NOT NULL,
    Type NVARCHAR(100), -- Head Office / Sales / Warehouse / Manufacturing
    Address NVARCHAR(500),
    City NVARCHAR(150),
    State NVARCHAR(150),
    Country NVARCHAR(150),
    Pincode NVARCHAR(50),
    Phone NVARCHAR(50),
    Email NVARCHAR(200),
    IsActive BIT DEFAULT 1,
    CreatedBy INT NULL,
    CreatedAt DATETIME2 DEFAULT SYSUTCDATETIME(),
    UpdatedBy INT NULL,
    UpdatedAt DATETIME2 NULL,
    IsDeleted BIT DEFAULT 0,
    CONSTRAINT FK_Branches_Companies FOREIGN KEY (CompanyId) REFERENCES dbo.Companies(CompanyId)
);

-- Users, Roles, Permissions
CREATE TABLE dbo.Roles (
    RoleId INT IDENTITY(1,1) PRIMARY KEY,
    Name NVARCHAR(150) NOT NULL UNIQUE,
    Description NVARCHAR(500),
    IsSystemRole BIT DEFAULT 0,
    CreatedAt DATETIME2 DEFAULT SYSUTCDATETIME()
);

CREATE TABLE dbo.Permissions (
    PermissionId INT IDENTITY(1,1) PRIMARY KEY,
    Name NVARCHAR(200) NOT NULL UNIQUE,
    Description NVARCHAR(500)
);

CREATE TABLE dbo.RolePermissions (
    RolePermissionId INT IDENTITY(1,1) PRIMARY KEY,
    RoleId INT NOT NULL,
    PermissionId INT NOT NULL,
    CONSTRAINT FK_RolePermissions_Roles FOREIGN KEY(RoleId) REFERENCES dbo.Roles(RoleId),
    CONSTRAINT FK_RolePermissions_Permissions FOREIGN KEY(PermissionId) REFERENCES dbo.Permissions(PermissionId)
);

CREATE TABLE dbo.Users (
    UserId INT IDENTITY(1,1) PRIMARY KEY,
    CompanyId INT NULL,
    BranchId INT NULL,
    Username NVARCHAR(150) NOT NULL UNIQUE,
    Email NVARCHAR(200),
    Mobile NVARCHAR(50),
    PasswordHash NVARCHAR(500) NOT NULL,
    PasswordSalt NVARCHAR(500),
    FullName NVARCHAR(250),
    IsActive BIT DEFAULT 1,
    LastLoginAt DATETIME2 NULL,
    CreatedAt DATETIME2 DEFAULT SYSUTCDATETIME(),
    UpdatedAt DATETIME2 NULL,
    CONSTRAINT FK_Users_Companies FOREIGN KEY(CompanyId) REFERENCES dbo.Companies(CompanyId),
    CONSTRAINT FK_Users_Branches FOREIGN KEY(BranchId) REFERENCES dbo.Branches(BranchId)
);

CREATE TABLE dbo.UserRoles (
    UserRoleId INT IDENTITY(1,1) PRIMARY KEY,
    UserId INT NOT NULL,
    RoleId INT NOT NULL,
    CONSTRAINT FK_UserRoles_Users FOREIGN KEY(UserId) REFERENCES dbo.Users(UserId),
    CONSTRAINT FK_UserRoles_Roles FOREIGN KEY(RoleId) REFERENCES dbo.Roles(RoleId)
);

-- Customers / Suppliers / Contacts
CREATE TABLE dbo.Contacts (
    ContactId INT IDENTITY(1,1) PRIMARY KEY,
    CompanyId INT NULL,
    ContactType NVARCHAR(50) NOT NULL, -- Customer/Supplier/Employee/Agent/Transporter/Broker/Bank/Other
    Name NVARCHAR(200) NOT NULL,
    CompanyName NVARCHAR(200),
    GSTIN NVARCHAR(50),
    PAN NVARCHAR(50),
    Mobile NVARCHAR(50),
    WhatsApp NVARCHAR(50),
    Email NVARCHAR(200),
    Address NVARCHAR(500),
    Area NVARCHAR(200),
    City NVARCHAR(150),
    State NVARCHAR(150),
    Country NVARCHAR(150),
    Pincode NVARCHAR(50),
    CreditLimit DECIMAL(18,2) DEFAULT 0,
    PaymentTerms NVARCHAR(200),
    OpeningBalance DECIMAL(18,2) DEFAULT 0,
    IsActive BIT DEFAULT 1,
    CreatedAt DATETIME2 DEFAULT SYSUTCDATETIME(),
    UpdatedAt DATETIME2 NULL,
    CONSTRAINT FK_Contacts_Companies FOREIGN KEY(CompanyId) REFERENCES dbo.Companies(CompanyId)
);

-- CRM Leads / Followups
CREATE TABLE dbo.Leads (
    LeadId INT IDENTITY(1,1) PRIMARY KEY,
    CompanyId INT NULL,
    ContactId INT NULL,
    Source NVARCHAR(200),
    AssignedTo INT NULL, -- UserId
    ExpectedValue DECIMAL(18,2) DEFAULT 0,
    Probability INT DEFAULT 0,
    ExpectedClosingDate DATE NULL,
    Status NVARCHAR(50) DEFAULT 'New',
    Remarks NVARCHAR(MAX),
    CreatedAt DATETIME2 DEFAULT SYSUTCDATETIME(),
    UpdatedAt DATETIME2 NULL,
    CONSTRAINT FK_Leads_Contacts FOREIGN KEY(ContactId) REFERENCES dbo.Contacts(ContactId)
);

CREATE TABLE dbo.LeadFollowups (
    FollowupId INT IDENTITY(1,1) PRIMARY KEY,
    LeadId INT NOT NULL,
    FollowupDate DATETIME2 NULL,
    Notes NVARCHAR(MAX),
    CreatedBy INT NULL,
    CreatedAt DATETIME2 DEFAULT SYSUTCDATETIME(),
    CONSTRAINT FK_LeadFollowups_Leads FOREIGN KEY(LeadId) REFERENCES dbo.Leads(LeadId)
);

-- Product master
CREATE TABLE dbo.Categories (
    CategoryId INT IDENTITY(1,1) PRIMARY KEY,
    CompanyId INT NULL,
    Name NVARCHAR(200) NOT NULL,
    ParentCategoryId INT NULL,
    IsActive BIT DEFAULT 1
);

CREATE TABLE dbo.Units (
    UnitId INT IDENTITY(1,1) PRIMARY KEY,
    Name NVARCHAR(100) NOT NULL,
    Abbreviation NVARCHAR(25)
);

CREATE TABLE dbo.Products (
    ProductId INT IDENTITY(1,1) PRIMARY KEY,
    CompanyId INT NULL,
    SKU NVARCHAR(100) NULL,
    Name NVARCHAR(300) NOT NULL,
    CategoryId INT NULL,
    Brand NVARCHAR(150),
    Barcode NVARCHAR(200),
    HSN NVARCHAR(50),
    UnitId INT NULL,
    PurchaseRate DECIMAL(18,4) DEFAULT 0,
    SellingRate DECIMAL(18,4) DEFAULT 0,
    WholesaleRate DECIMAL(18,4) DEFAULT 0,
    GSTPercent DECIMAL(5,2) DEFAULT 0,
    OpeningStock DECIMAL(18,4) DEFAULT 0,
    MinStock DECIMAL(18,4) DEFAULT 0,
    MaxStock DECIMAL(18,4) DEFAULT 0,
    ReorderLevel DECIMAL(18,4) DEFAULT 0,
    IsActive BIT DEFAULT 1,
    ProductImageUrl NVARCHAR(1000),
    CreatedAt DATETIME2 DEFAULT SYSUTCDATETIME(),
    UpdatedAt DATETIME2 NULL,
    CONSTRAINT FK_Products_Categories FOREIGN KEY(CategoryId) REFERENCES dbo.Categories(CategoryId),
    CONSTRAINT FK_Products_Units FOREIGN KEY(UnitId) REFERENCES dbo.Units(UnitId)
);

-- Warehouses / Batches / Stock
CREATE TABLE dbo.Warehouses (
    WarehouseId INT IDENTITY(1,1) PRIMARY KEY,
    CompanyId INT NULL,
    BranchId INT NULL,
    Name NVARCHAR(200) NOT NULL,
    Location NVARCHAR(300),
    IsActive BIT DEFAULT 1,
    CONSTRAINT FK_Warehouses_Companies FOREIGN KEY(CompanyId) REFERENCES dbo.Companies(CompanyId),
    CONSTRAINT FK_Warehouses_Branches FOREIGN KEY(BranchId) REFERENCES dbo.Branches(BranchId)
);

CREATE TABLE dbo.Batches (
    BatchId INT IDENTITY(1,1) PRIMARY KEY,
    ProductId INT NOT NULL,
    BatchNumber NVARCHAR(200),
    MfgDate DATE NULL,
    ExpiryDate DATE NULL,
    Quantity DECIMAL(18,4) DEFAULT 0,
    CONSTRAINT FK_Batches_Products FOREIGN KEY(ProductId) REFERENCES dbo.Products(ProductId)
);

CREATE TABLE dbo.Stock (
    StockId INT IDENTITY(1,1) PRIMARY KEY,
    CompanyId INT NULL,
    WarehouseId INT NULL,
    ProductId INT NOT NULL,
    BatchId INT NULL,
    Quantity DECIMAL(18,4) DEFAULT 0,
    ReservedQuantity DECIMAL(18,4) DEFAULT 0,
    CONSTRAINT FK_Stock_Warehouses FOREIGN KEY(WarehouseId) REFERENCES dbo.Warehouses(WarehouseId),
    CONSTRAINT FK_Stock_Products FOREIGN KEY(ProductId) REFERENCES dbo.Products(ProductId),
    CONSTRAINT FK_Stock_Batches FOREIGN KEY(BatchId) REFERENCES dbo.Batches(BatchId)
);

CREATE TABLE dbo.StockTransactions (
    StockTransactionId INT IDENTITY(1,1) PRIMARY KEY,
    CompanyId INT NULL,
    TransactionType NVARCHAR(50) NOT NULL, -- Opening, Purchase, Sale, Production, Return, Transfer, Adjustment, Damage
    ReferenceNo NVARCHAR(200),
    ReferenceDate DATETIME2 DEFAULT SYSUTCDATETIME(),
    WarehouseFromId INT NULL,
    WarehouseToId INT NULL,
    ProductId INT NOT NULL,
    BatchId INT NULL,
    Quantity DECIMAL(18,4) DEFAULT 0,
    UnitPrice DECIMAL(18,4) DEFAULT 0,
    TotalAmount DECIMAL(18,4) DEFAULT 0,
    CreatedBy INT NULL,
    CreatedAt DATETIME2 DEFAULT SYSUTCDATETIME(),
    CONSTRAINT FK_StockTransactions_Products FOREIGN KEY(ProductId) REFERENCES dbo.Products(ProductId)
);

-- Sales flow (Quotation / Order / Invoice)
CREATE TABLE dbo.SalesQuotations (
    SalesQuotationId INT IDENTITY(1,1) PRIMARY KEY,
    CompanyId INT NULL,
    BranchId INT NULL,
    CustomerId INT NULL, -- ContactId
    QuotationNumber NVARCHAR(200) NOT NULL,
    Date DATETIME2 DEFAULT SYSUTCDATETIME(),
    ValidUntil DATE NULL,
    TotalAmount DECIMAL(18,4) DEFAULT 0,
    Status NVARCHAR(50) DEFAULT 'Draft',
    CreatedBy INT NULL,
    CreatedAt DATETIME2 DEFAULT SYSUTCDATETIME(),
    CONSTRAINT FK_SalesQuotations_Customers FOREIGN KEY(CustomerId) REFERENCES dbo.Contacts(ContactId)
);

CREATE TABLE dbo.SalesOrders (
    SalesOrderId INT IDENTITY(1,1) PRIMARY KEY,
    CompanyId INT NULL,
    BranchId INT NULL,
    CustomerId INT NULL,
    OrderNumber NVARCHAR(200) NOT NULL,
    Date DATETIME2 DEFAULT SYSUTCDATETIME(),
    TotalAmount DECIMAL(18,4) DEFAULT 0,
    Status NVARCHAR(50) DEFAULT 'New',
    CreatedBy INT NULL,
    CreatedAt DATETIME2 DEFAULT SYSUTCDATETIME(),
    CONSTRAINT FK_SalesOrders_Customers FOREIGN KEY(CustomerId) REFERENCES dbo.Contacts(ContactId)
);

CREATE TABLE dbo.SalesOrderDetails (
    SalesOrderDetailId INT IDENTITY(1,1) PRIMARY KEY,
    SalesOrderId INT NOT NULL,
    ProductId INT NOT NULL,
    BatchId INT NULL,
    Quantity DECIMAL(18,4) DEFAULT 0,
    UnitPrice DECIMAL(18,4) DEFAULT 0,
    Discount DECIMAL(18,4) DEFAULT 0,
    TaxAmount DECIMAL(18,4) DEFAULT 0,
    LineTotal DECIMAL(18,4) DEFAULT 0,
    CONSTRAINT FK_SalesOrderDetails_SalesOrders FOREIGN KEY(SalesOrderId) REFERENCES dbo.SalesOrders(SalesOrderId),
    CONSTRAINT FK_SalesOrderDetails_Products FOREIGN KEY(ProductId) REFERENCES dbo.Products(ProductId)
);

CREATE TABLE dbo.SalesInvoices (
    SalesInvoiceId INT IDENTITY(1,1) PRIMARY KEY,
    CompanyId INT NULL,
    BranchId INT NULL,
    CustomerId INT NULL,
    InvoiceNumber NVARCHAR(200) NOT NULL,
    Date DATETIME2 DEFAULT SYSUTCDATETIME(),
    DueDate DATE NULL,
    SubTotal DECIMAL(18,4) DEFAULT 0,
    TaxTotal DECIMAL(18,4) DEFAULT 0,
    GrandTotal DECIMAL(18,4) DEFAULT 0,
    PaymentStatus NVARCHAR(50) DEFAULT 'Unpaid',
    CreatedBy INT NULL,
    CreatedAt DATETIME2 DEFAULT SYSUTCDATETIME(),
    CONSTRAINT FK_SalesInvoices_Customers FOREIGN KEY(CustomerId) REFERENCES dbo.Contacts(ContactId)
);

CREATE TABLE dbo.SalesInvoiceDetails (
    SalesInvoiceDetailId INT IDENTITY(1,1) PRIMARY KEY,
    SalesInvoiceId INT NOT NULL,
    ProductId INT NOT NULL,
    BatchId INT NULL,
    Quantity DECIMAL(18,4) DEFAULT 0,
    UnitPrice DECIMAL(18,4) DEFAULT 0,
    Discount DECIMAL(18,4) DEFAULT 0,
    TaxAmount DECIMAL(18,4) DEFAULT 0,
    LineTotal DECIMAL(18,4) DEFAULT 0,
    CONSTRAINT FK_SalesInvoiceDetails_SalesInvoices FOREIGN KEY(SalesInvoiceId) REFERENCES dbo.SalesInvoices(SalesInvoiceId),
    CONSTRAINT FK_SalesInvoiceDetails_Products FOREIGN KEY(ProductId) REFERENCES dbo.Products(ProductId)
);

-- Purchase flow
CREATE TABLE dbo.PurchaseOrders (
    PurchaseOrderId INT IDENTITY(1,1) PRIMARY KEY,
    CompanyId INT NULL,
    BranchId INT NULL,
    SupplierId INT NULL, -- ContactId
    PONumber NVARCHAR(200) NOT NULL,
    Date DATETIME2 DEFAULT SYSUTCDATETIME(),
    TotalAmount DECIMAL(18,4) DEFAULT 0,
    Status NVARCHAR(50) DEFAULT 'New',
    CreatedBy INT NULL,
    CreatedAt DATETIME2 DEFAULT SYSUTCDATETIME(),
    CONSTRAINT FK_PurchaseOrders_Suppliers FOREIGN KEY(SupplierId) REFERENCES dbo.Contacts(ContactId)
);

CREATE TABLE dbo.PurchaseOrderDetails (
    PurchaseOrderDetailId INT IDENTITY(1,1) PRIMARY KEY,
    PurchaseOrderId INT NOT NULL,
    ProductId INT NOT NULL,
    Quantity DECIMAL(18,4) DEFAULT 0,
    UnitPrice DECIMAL(18,4) DEFAULT 0,
    TaxAmount DECIMAL(18,4) DEFAULT 0,
    LineTotal DECIMAL(18,4) DEFAULT 0,
    CONSTRAINT FK_PurchaseOrderDetails_PurchaseOrders FOREIGN KEY(PurchaseOrderId) REFERENCES dbo.PurchaseOrders(PurchaseOrderId),
    CONSTRAINT FK_PurchaseOrderDetails_Products FOREIGN KEY(ProductId) REFERENCES dbo.Products(ProductId)
);

CREATE TABLE dbo.PurchaseInvoices (
    PurchaseInvoiceId INT IDENTITY(1,1) PRIMARY KEY,
    CompanyId INT NULL,
    BranchId INT NULL,
    SupplierId INT NULL,
    InvoiceNumber NVARCHAR(200) NOT NULL,
    Date DATETIME2 DEFAULT SYSUTCDATETIME(),
    TotalAmount DECIMAL(18,4) DEFAULT 0,
    DueDate DATE NULL,
    CreatedBy INT NULL,
    CreatedAt DATETIME2 DEFAULT SYSUTCDATETIME(),
    CONSTRAINT FK_PurchaseInvoices_Suppliers FOREIGN KEY(SupplierId) REFERENCES dbo.Contacts(ContactId)
);

CREATE TABLE dbo.PurchaseInvoiceDetails (
    PurchaseInvoiceDetailId INT IDENTITY(1,1) PRIMARY KEY,
    PurchaseInvoiceId INT NOT NULL,
    ProductId INT NOT NULL,
    Quantity DECIMAL(18,4) DEFAULT 0,
    UnitPrice DECIMAL(18,4) DEFAULT 0,
    TaxAmount DECIMAL(18,4) DEFAULT 0,
    LineTotal DECIMAL(18,4) DEFAULT 0,
    CONSTRAINT FK_PurchaseInvoiceDetails_PurchaseInvoices FOREIGN KEY(PurchaseInvoiceId) REFERENCES dbo.PurchaseInvoices(PurchaseInvoiceId),
    CONSTRAINT FK_PurchaseInvoiceDetails_Products FOREIGN KEY(ProductId) REFERENCES dbo.Products(ProductId)
);

-- Import / Export
CREATE TABLE dbo.ImportInvoices (
    ImportInvoiceId INT IDENTITY(1,1) PRIMARY KEY,
    CompanyId INT NULL,
    SupplierId INT NULL,
    InvoiceNumber NVARCHAR(200),
    Currency NVARCHAR(10),
    ExchangeRate DECIMAL(18,6) DEFAULT 1,
    FOBValue DECIMAL(18,4) DEFAULT 0,
    Freight DECIMAL(18,4) DEFAULT 0,
    Insurance DECIMAL(18,4) DEFAULT 0,
    CustomsDuty DECIMAL(18,4) DEFAULT 0,
    PortCharges DECIMAL(18,4) DEFAULT 0,
    OtherCharges DECIMAL(18,4) DEFAULT 0,
    LandedCost DECIMAL(18,4) DEFAULT 0,
    CreatedAt DATETIME2 DEFAULT SYSUTCDATETIME()
);

CREATE TABLE dbo.BillOfEntry (
    BillOfEntryId INT IDENTITY(1,1) PRIMARY KEY,
    ImportInvoiceId INT NOT NULL,
    BOENumber NVARCHAR(200),
    BOEDate DATE NULL,
    AssessableValue DECIMAL(18,4) DEFAULT 0,
    CustomsDuty DECIMAL(18,4) DEFAULT 0,
    IGST DECIMAL(18,4) DEFAULT 0,
    CONSTRAINT FK_BillOfEntry_ImportInvoices FOREIGN KEY(ImportInvoiceId) REFERENCES dbo.ImportInvoices(ImportInvoiceId)
);

CREATE TABLE dbo.ExportInvoices (
    ExportInvoiceId INT IDENTITY(1,1) PRIMARY KEY,
    CompanyId INT NULL,
    CustomerId INT NULL,
    InvoiceNumber NVARCHAR(200),
    Currency NVARCHAR(10),
    ExchangeRate DECIMAL(18,6) DEFAULT 1,
    TotalAmount DECIMAL(18,4) DEFAULT 0,
    ShippingDetails NVARCHAR(MAX),
    CreatedAt DATETIME2 DEFAULT SYSUTCDATETIME()
);

-- Manufacturing (BOM / Production)
CREATE TABLE dbo.BOM (
    BOMId INT IDENTITY(1,1) PRIMARY KEY,
    CompanyId INT NULL,
    FinishedProductId INT NOT NULL,
    Name NVARCHAR(300),
    CreatedAt DATETIME2 DEFAULT SYSUTCDATETIME(),
    CONSTRAINT FK_BOM_Products FOREIGN KEY(FinishedProductId) REFERENCES dbo.Products(ProductId)
);

CREATE TABLE dbo.BOMDetails (
    BOMDetailId INT IDENTITY(1,1) PRIMARY KEY,
    BOMId INT NOT NULL,
    RawMaterialProductId INT NOT NULL,
    Quantity DECIMAL(18,4) DEFAULT 0,
    WastagePercent DECIMAL(5,2) DEFAULT 0,
    CONSTRAINT FK_BOMDetails_BOM FOREIGN KEY(BOMId) REFERENCES dbo.BOM(BOMId),
    CONSTRAINT FK_BOMDetails_Products FOREIGN KEY(RawMaterialProductId) REFERENCES dbo.Products(ProductId)
);

CREATE TABLE dbo.ProductionOrders (
    ProductionOrderId INT IDENTITY(1,1) PRIMARY KEY,
    CompanyId INT NULL,
    BOMId INT NOT NULL,
    Quantity DECIMAL(18,4) DEFAULT 0,
    Status NVARCHAR(50) DEFAULT 'Planned',
    CreatedAt DATETIME2 DEFAULT SYSUTCDATETIME(),
    CONSTRAINT FK_ProductionOrders_BOM FOREIGN KEY(BOMId) REFERENCES dbo.BOM(BOMId)
);

-- Machine management
CREATE TABLE dbo.Machines (
    MachineId INT IDENTITY(1,1) PRIMARY KEY,
    CompanyId INT NULL,
    Name NVARCHAR(300) NOT NULL,
    Type NVARCHAR(200),
    Brand NVARCHAR(200),
    Model NVARCHAR(200),
    SerialNumber NVARCHAR(200),
    PurchaseDate DATE NULL,
    PurchaseCost DECIMAL(18,4) DEFAULT 0,
    Location NVARCHAR(300),
    Department NVARCHAR(200),
    Capacity NVARCHAR(200),
    OperatorId INT NULL, -- EmployeeId
    WarrantyEndDate DATE NULL,
    AMCInfo NVARCHAR(500),
    Status NVARCHAR(50) DEFAULT 'Running'
);

CREATE TABLE dbo.MachineLogs (
    MachineLogId INT IDENTITY(1,1) PRIMARY KEY,
    MachineId INT NOT NULL,
    StartTime DATETIME2 NULL,
    StopTime DATETIME2 NULL,
    RunningHours DECIMAL(18,4) NULL,
    IdleHours DECIMAL(18,4) NULL,
    ProductionQty DECIMAL(18,4) NULL,
    OperatorId INT NULL,
    Notes NVARCHAR(MAX),
    CONSTRAINT FK_MachineLogs_Machines FOREIGN KEY(MachineId) REFERENCES dbo.Machines(MachineId)
);

CREATE TABLE dbo.MachineMaintenance (
    MaintenanceId INT IDENTITY(1,1) PRIMARY KEY,
    MachineId INT NOT NULL,
    MaintenanceType NVARCHAR(50), -- Preventive / Breakdown
    ScheduledDate DATE NULL,
    CompletedDate DATE NULL,
    Cost DECIMAL(18,4) DEFAULT 0,
    Notes NVARCHAR(MAX),
    CONSTRAINT FK_MachineMaintenance_Machines FOREIGN KEY(MachineId) REFERENCES dbo.Machines(MachineId)
);

-- HR / Employee / Attendance / Payroll
CREATE TABLE dbo.Employees (
    EmployeeId INT IDENTITY(1,1) PRIMARY KEY,
    CompanyId INT NULL,
    BranchId INT NULL,
    EmployeeCode NVARCHAR(100),
    FirstName NVARCHAR(150),
    LastName NVARCHAR(150),
    FatherGuardian NVARCHAR(200),
    Department NVARCHAR(200),
    Designation NVARCHAR(200),
    JoiningDate DATE NULL,
    Mobile NVARCHAR(50),
    Email NVARCHAR(200),
    Address NVARCHAR(500),
    BankDetails NVARCHAR(500),
    Salary DECIMAL(18,4) DEFAULT 0,
    Status NVARCHAR(50) DEFAULT 'Active'
);

CREATE TABLE dbo.Attendance (
    AttendanceId INT IDENTITY(1,1) PRIMARY KEY,
    EmployeeId INT NOT NULL,
    Date DATE NOT NULL,
    CheckIn DATETIME2 NULL,
    CheckOut DATETIME2 NULL,
    Status NVARCHAR(50), -- Present/Absent/HalfDay/Leave
    OvertimeHours DECIMAL(18,4) DEFAULT 0,
    CONSTRAINT FK_Attendance_Employees FOREIGN KEY(EmployeeId) REFERENCES dbo.Employees(EmployeeId)
);

CREATE TABLE dbo.LeaveRequests (
    LeaveRequestId INT IDENTITY(1,1) PRIMARY KEY,
    EmployeeId INT NOT NULL,
    LeaveType NVARCHAR(100),
    FromDate DATE NOT NULL,
    ToDate DATE NOT NULL,
    Days DECIMAL(5,2) DEFAULT 0,
    Status NVARCHAR(50) DEFAULT 'Pending',
    Remarks NVARCHAR(MAX),
    CONSTRAINT FK_LeaveRequests_Employees FOREIGN KEY(EmployeeId) REFERENCES dbo.Employees(EmployeeId)
);

CREATE TABLE dbo.Payrolls (
    PayrollId INT IDENTITY(1,1) PRIMARY KEY,
    CompanyId INT NULL,
    Month INT NOT NULL,
    Year INT NOT NULL,
    TotalGross DECIMAL(18,4) DEFAULT 0,
    TotalDeductions DECIMAL(18,4) DEFAULT 0,
    TotalNet DECIMAL(18,4) DEFAULT 0,
    CreatedAt DATETIME2 DEFAULT SYSUTCDATETIME()
);

CREATE TABLE dbo.PayrollDetails (
    PayrollDetailId INT IDENTITY(1,1) PRIMARY KEY,
    PayrollId INT NOT NULL,
    EmployeeId INT NOT NULL,
    Basic DECIMAL(18,4) DEFAULT 0,
    HRA DECIMAL(18,4) DEFAULT 0,
    OtherAllowances DECIMAL(18,4) DEFAULT 0,
    Deductions DECIMAL(18,4) DEFAULT 0,
    NetPay DECIMAL(18,4) DEFAULT 0,
    CONSTRAINT FK_PayrollDetails_Payrolls FOREIGN KEY(PayrollId) REFERENCES dbo.Payrolls(PayrollId),
    CONSTRAINT FK_PayrollDetails_Employees FOREIGN KEY(EmployeeId) REFERENCES dbo.Employees(EmployeeId)
);

-- Accounting: Chart of Accounts, Journal Entries, Payments, Receipts
CREATE TABLE dbo.ChartOfAccounts (
    AccountId INT IDENTITY(1,1) PRIMARY KEY,
    CompanyId INT NULL,
    AccountCode NVARCHAR(100) NOT NULL,
    AccountName NVARCHAR(300) NOT NULL,
    AccountType NVARCHAR(50), -- Asset/Liability/Income/Expense/Equity
    ParentAccountId INT NULL
);

CREATE TABLE dbo.JournalEntries (
    JournalEntryId INT IDENTITY(1,1) PRIMARY KEY,
    CompanyId INT NULL,
    EntryDate DATE NOT NULL,
    ReferenceNo NVARCHAR(200),
    Narration NVARCHAR(MAX),
    CreatedAt DATETIME2 DEFAULT SYSUTCDATETIME()
);

CREATE TABLE dbo.JournalEntryDetails (
    JournalEntryDetailId INT IDENTITY(1,1) PRIMARY KEY,
    JournalEntryId INT NOT NULL,
    AccountId INT NOT NULL,
    Debit DECIMAL(18,4) DEFAULT 0,
    Credit DECIMAL(18,4) DEFAULT 0,
    CONSTRAINT FK_JournalEntryDetails_JournalEntries FOREIGN KEY(JournalEntryId) REFERENCES dbo.JournalEntries(JournalEntryId),
    CONSTRAINT FK_JournalEntryDetails_Account FOREIGN KEY(AccountId) REFERENCES dbo.ChartOfAccounts(AccountId)
);

CREATE TABLE dbo.Payments (
    PaymentId INT IDENTITY(1,1) PRIMARY KEY,
    CompanyId INT NULL,
    Date DATETIME2 DEFAULT SYSUTCDATETIME(),
    Amount DECIMAL(18,4) DEFAULT 0,
    PaymentMode NVARCHAR(50), -- Cash/Cheque/NEFT/RTGS/UPI
    ReferenceNo NVARCHAR(200),
    SupplierId INT NULL,
    CustomerId INT NULL
);

CREATE TABLE dbo.Receipts (
    ReceiptId INT IDENTITY(1,1) PRIMARY KEY,
    CompanyId INT NULL,
    Date DATETIME2 DEFAULT SYSUTCDATETIME(),
    Amount DECIMAL(18,4) DEFAULT 0,
    ReceiptMode NVARCHAR(50),
    ReferenceNo NVARCHAR(200),
    CustomerId INT NULL,
    SupplierId INT NULL
);

CREATE TABLE dbo.BankAccounts (
    BankAccountId INT IDENTITY(1,1) PRIMARY KEY,
    CompanyId INT NULL,
    BankName NVARCHAR(200),
    AccountNumber NVARCHAR(200),
    IFSC NVARCHAR(100),
    OpeningBalance DECIMAL(18,4) DEFAULT 0
);

CREATE TABLE dbo.BankTransactions (
    BankTransactionId INT IDENTITY(1,1) PRIMARY KEY,
    BankAccountId INT NOT NULL,
    Date DATETIME2 DEFAULT SYSUTCDATETIME(),
    Amount DECIMAL(18,4) DEFAULT 0,
    TransactionType NVARCHAR(50), -- Deposit/Withdrawal
    ReferenceNo NVARCHAR(200),
    CONSTRAINT FK_BankTransactions_BankAccount FOREIGN KEY(BankAccountId) REFERENCES dbo.BankAccounts(BankAccountId)
);

-- Documents / Audit / History / Notifications
CREATE TABLE dbo.AuditLogs (
    AuditLogId INT IDENTITY(1,1) PRIMARY KEY,
    CompanyId INT NULL,
    UserId INT NULL,
    Module NVARCHAR(200),
    Action NVARCHAR(200),
    RecordId NVARCHAR(200),
    OldValue NVARCHAR(MAX),
    NewValue NVARCHAR(MAX),
    IpAddress NVARCHAR(100),
    DeviceInfo NVARCHAR(500),
    CreatedAt DATETIME2 DEFAULT SYSUTCDATETIME()
);

CREATE TABLE dbo.DocumentHistory (
    DocumentHistoryId INT IDENTITY(1,1) PRIMARY KEY,
    DocumentType NVARCHAR(100), -- Invoice / PO / GRN etc
    DocumentNo NVARCHAR(200),
    Action NVARCHAR(100), -- Created/Edited/PDFGenerated/Printed/WhatsApp/Email
    PerformedBy INT NULL,
    PerformedAt DATETIME2 DEFAULT SYSUTCDATETIME(),
    Notes NVARCHAR(MAX)
);

CREATE TABLE dbo.EmailHistory (
    EmailHistoryId INT IDENTITY(1,1) PRIMARY KEY,
    CompanyId INT NULL,
    ToAddress NVARCHAR(500),
    Subject NVARCHAR(500),
    Body NVARCHAR(MAX),
    Attachments NVARCHAR(MAX),
    SentBy INT NULL,
    SentAt DATETIME2 DEFAULT SYSUTCDATETIME(),
    Status NVARCHAR(50)
);

CREATE TABLE dbo.WhatsAppHistory (
    WhatsAppHistoryId INT IDENTITY(1,1) PRIMARY KEY,
    CompanyId INT NULL,
    Mobile NVARCHAR(100),
    Message NVARCHAR(MAX),
    Attachments NVARCHAR(MAX),
    SentBy INT NULL,
    SentAt DATETIME2 DEFAULT SYSUTCDATETIME(),
    Status NVARCHAR(50)
);

CREATE TABLE dbo.Notifications (
    NotificationId INT IDENTITY(1,1) PRIMARY KEY,
    CompanyId INT NULL,
    Title NVARCHAR(300),
    Body NVARCHAR(MAX),
    ForUserId INT NULL,
    IsRead BIT DEFAULT 0,
    CreatedAt DATETIME2 DEFAULT SYSUTCDATETIME()
);

CREATE TABLE dbo.Tasks (
    TaskId INT IDENTITY(1,1) PRIMARY KEY,
    CompanyId INT NULL,
    Title NVARCHAR(300),
    Description NVARCHAR(MAX),
    AssignedTo INT NULL,
    Priority NVARCHAR(50),
    StartDate DATE NULL,
    DueDate DATE NULL,
    Status NVARCHAR(50) DEFAULT 'Pending',
    CreatedAt DATETIME2 DEFAULT SYSUTCDATETIME()
);

CREATE TABLE dbo.SystemSettings (
    SettingId INT IDENTITY(1,1) PRIMARY KEY,
    CompanyId INT NULL,
    KeyName NVARCHAR(200) NOT NULL,
    Value NVARCHAR(MAX),
    Description NVARCHAR(500)
);

-- Indexes: commonly searched columns
CREATE INDEX IDX_Products_Name ON dbo.Products(Name);
CREATE INDEX IDX_Contacts_Name ON dbo.Contacts(Name);
CREATE INDEX IDX_SalesInvoices_Number ON dbo.SalesInvoices(InvoiceNumber);
CREATE INDEX IDX_PurchaseInvoices_Number ON dbo.PurchaseInvoices(InvoiceNumber);

-- NOTE: This is a starter schema. For production, add more constraints, check constraints, UDFs, stored procedures and adjust datatypes and sizes per needs.

PRINT 'DDL script executed (starter schema)';
