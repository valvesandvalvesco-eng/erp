# Aavronex ERP - Database DDL

This folder contains the initial SQL Server DDL starter schema for the Aavronex ERP system. It provides core tables to begin development for an industrial valves manufacturer covering:

- Companies & Branches
- Users, Roles, Permissions
- Contacts (Customers/Suppliers) & CRM (Leads/Followups)
- Products, Categories, Units, Warehouses, Stock, Batches
- Sales, Purchase, Invoices and order flows
- Manufacturing (BOM, Production Orders)
- Machine Management (Machines, Logs, Maintenance)
- HR (Employees, Attendance, Leave, Payroll)
- Accounting (Chart of Accounts, Journal Entries, Payments, Bank Transactions)
- Import/Export (ImportInvoices, BillOfEntry, ExportInvoices)
- Audit, Document, Email, WhatsApp history, Notifications, Tasks, SystemSettings

Files added:
- 00_schema.sql  — Combined starter DDL script.

Next recommended steps:
1. Review the schema and add missing fields specific to your business (e.g., GST/e-invoicing fields, IEC handling, multi-currency rules).
2. Split DDL into per-table files if desired. Add migrations (Flyway/EF Core Migrations) for versioning.
3. Add primary constraints, check constraints, default values, and stored procedures for common operations (e.g., create invoice, post stock transactions, calculate landed cost).
4. Create sample seed data and test scripts for development.
5. Scaffold application layer (Domain/Application/Infrastructure) to map to these tables.

If you want, I can now:
- Split the combined DDL into individual files per table.
- Generate an ER diagram (SVG) from this schema.
- Create EF Core entity models and DbContext mapping.
- Scaffold migrations using EF Core in a new branch.

Branch: feature/db-schema (created)
Commit: Added database/ddl/00_schema.sql and README
