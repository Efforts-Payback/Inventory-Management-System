# 📦 Inventory Management System (SQL Project)

## 📖 Overview
The **Inventory Management System** is a database-driven project developed using **SQL Server**.  
It is designed to manage products, suppliers, inventory levels, and transactions efficiently.  

This project demonstrates the use of:
- **Database design principles**
- **Triggers**
- **Stored Procedures**
- **Views**
- **Constraints & Relationships**

It simulates a real-world inventory system for businesses such as retail stores, suppliers, and warehouses.  

---

## ⚙️ Features

### 🛒 Products
- Add, update, delete products  
- Store product details such as ID, name, description, category, and price  

### 🚚 Suppliers
- Manage supplier details (name, contact info, phone number)  
- Link suppliers to products  

### 📦 Inventory
- Track product stock quantity  
- Maintain supplier association  
- Auto-update quantity on **purchase** or **sale** transactions  

### 💰 Transactions
- Record **sales** and **purchases**  
- Auto-adjust inventory via **triggers**  

### 🔍 Queries & Views
- **Product Search View** – search products by name or category  
- **Low Stock Report View** – identify products below threshold stock  

### ⚡ Stored Procedures
- `AddNewProduct` → Add product with supplier & initial stock  
- `UpdateProduct` → Update details and quantity  
- `DeleteProduct` → Delete product & related records  
- `ViewProductDetails` → Get complete product details  

---

## 🗂️ Database Structure

### **Tables**
- `Products` → Product details  
- `Suppliers` → Supplier details  
- `Inventory` → Tracks stock & supplier mapping  
- `Transactions` → Sales and purchase records  

### **Triggers**
- `trg_UpdateInventory_AfterInsert` → Auto-updates inventory on insert into transactions  

### **Views**
- `View_ProductSearch` → Easy product lookup  
- `View_LowStockReport` → Report of products low on stock  

### **Stored Procedures**
- `AddNewProduct`  
- `UpdateProduct`  
- `DeleteProduct`  
- `ViewProductDetails`  

---

## 🛠️ Tech Stack
- **SQL Server**  
- Database Concepts: **Normalization, Triggers, Views, Stored Procedures**  

---

## ▶️ Example Queries

-- 1. Search products
SELECT * FROM View_ProductSearch 
WHERE product_name LIKE '%Laptop%' OR category LIKE '%Electronics%';

-- 2. View low stock report
SELECT * FROM View_LowStockReport;

-- 3. Add a new product
EXEC AddNewProduct 
    @name = N'Mouse', 
    @description = N'Wireless Mouse', 
    @price = 25.99, 
    @category = N'Electronics', 
    @quantity = 50, 
    @supplier_id = 1;

-- 4. Update product details
EXEC UpdateProduct 
    @product_id = 1, 
    @name = N'Gaming Laptop', 
    @price = 1500.00, 
    @quantity = 8;

-- 5. Delete a product
EXEC DeleteProduct @product_id = 3;

-- 6. View product details
EXEC ViewProductDetails @product_id = 1;


### **🎯 Learning Outcomes**
✔️ Designed a normalized relational database
✔️ Implemented triggers for automatic inventory updates
✔️ Built views for quick data access and reports
✔️ Created stored procedures for CRUD operations
✔️ Learned real-world business logic implementation in SQL
