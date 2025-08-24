-- Create database
IF DB_ID('InventoryDB') IS NULL
    CREATE DATABASE InventoryDB;
GO
USE InventoryDB;
GO

-- Create tables
CREATE TABLE Products (
    product_id INT IDENTITY(1,1) PRIMARY KEY,
    product_name VARCHAR(255) NOT NULL,
    description TEXT,
    price DECIMAL(10, 2) NOT NULL CHECK (price >= 0),
    category VARCHAR(100)
);
GO

CREATE TABLE Suppliers (
    supplier_id INT IDENTITY(1,1) PRIMARY KEY,
    supplier_name VARCHAR(255) NOT NULL,
    contact_email VARCHAR(255),
    phone_number VARCHAR(15)
);
GO

CREATE TABLE Inventory (
    inventory_id INT IDENTITY(1,1) PRIMARY KEY,
    product_id INT NOT NULL,
    quantity INT DEFAULT 0 CHECK (quantity >= 0),
    supplier_id INT NOT NULL,
    last_updated DATE DEFAULT GETDATE(),
    FOREIGN KEY (product_id) REFERENCES Products(product_id),
    FOREIGN KEY (supplier_id) REFERENCES Suppliers(supplier_id)
);
GO

CREATE TABLE Transactions (
    transaction_id INT IDENTITY(1,1) PRIMARY KEY,
    product_id INT NOT NULL,
    transaction_type VARCHAR(10) NOT NULL CHECK (transaction_type IN ('sale', 'purchase')),
    transaction_date DATE DEFAULT GETDATE(),
    quantity INT NOT NULL CHECK (quantity > 0),
    FOREIGN KEY (product_id) REFERENCES Products(product_id)
);
GO

-- Insert sample data
INSERT INTO Products (product_name, description, price, category) VALUES
('Laptop', 'High performance laptop', 1200.00, 'Electronics'),
('Desk Chair', 'Ergonomic office chair', 150.00, 'Furniture'),
('Notebook', '200-page ruled notebook', 2.50, 'Stationery');
GO

INSERT INTO Suppliers (supplier_name, contact_email, phone_number) VALUES
('Tech Supplies Co.', 'contact@techsupplies.com', '1234567890'),
('Office Furniture Inc.', 'support@officefurniture.com', '0987654321');
GO

INSERT INTO Inventory (product_id, quantity, supplier_id) VALUES
(1, 10, 1),
(2, 20, 2),
(3, 100, 2);
GO

-- Insert sample transactions
INSERT INTO Transactions (product_id, transaction_type, quantity) VALUES
(1, 'purchase', 10),
(2, 'purchase', 20),
(3, 'purchase', 100),
(1, 'sale', 5);
GO

-- Create Triggers
CREATE TRIGGER trg_UpdateInventory_AfterInsert
ON Transactions
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    -- Handle purchases
    UPDATE inv
    SET inv.quantity = inv.quantity + i.quantity,
        inv.last_updated = GETDATE()
    FROM Inventory inv
    INNER JOIN inserted i ON inv.product_id = i.product_id
    WHERE i.transaction_type = 'purchase';

    -- Handle sales
    UPDATE inv
    SET inv.quantity = inv.quantity - i.quantity,
        inv.last_updated = GETDATE()
    FROM Inventory inv
    INNER JOIN inserted i ON inv.product_id = i.product_id
    WHERE i.transaction_type = 'sale';
END;
GO

-- Create Views
CREATE VIEW View_ProductSearch AS
SELECT 
    p.product_id,
    p.product_name,
    p.category,
    p.price,
    i.quantity
FROM Products p
JOIN Inventory i ON p.product_id = i.product_id;
GO

CREATE VIEW View_LowStockReport AS
SELECT 
    p.product_name,
    i.quantity,
    p.category,
    s.supplier_name
FROM Inventory i
JOIN Products p ON i.product_id = p.product_id
JOIN Suppliers s ON i.supplier_id = s.supplier_id
WHERE i.quantity < 10;
GO

-- Stored Procedures

-- Add product
CREATE PROCEDURE AddNewProduct
    @name VARCHAR(255),
    @description TEXT,
    @price DECIMAL(10,2),
    @category VARCHAR(100),
    @quantity INT,
    @supplier_id INT
AS
BEGIN
    SET XACT_ABORT ON;
    BEGIN TRANSACTION;
    
    INSERT INTO Products (product_name, description, price, category)
    VALUES (@name, @description, @price, @category);

    DECLARE @newProductId INT = SCOPE_IDENTITY();

    INSERT INTO Inventory (product_id, quantity, supplier_id)
    VALUES (@newProductId, @quantity, @supplier_id);

    COMMIT;
END;
GO

-- Update product
CREATE PROCEDURE UpdateProduct
    @product_id INT,
    @name VARCHAR(255),
    @price DECIMAL(10,2),
    @quantity INT
AS
BEGIN
    UPDATE Products
    SET product_name = @name,
        price = @price
    WHERE product_id = @product_id;

    UPDATE Inventory
    SET quantity = @quantity,
        last_updated = GETDATE()
    WHERE product_id = @product_id;
END;
GO

-- Delete product
CREATE PROCEDURE DeleteProduct
    @product_id INT
AS
BEGIN
    DELETE FROM Inventory WHERE product_id = @product_id;
    DELETE FROM Transactions WHERE product_id = @product_id;
    DELETE FROM Products WHERE product_id = @product_id;
END;
GO

-- View product
CREATE PROCEDURE ViewProductDetails
    @product_id INT
AS
BEGIN
    SELECT 
        p.product_id,
        p.product_name,
        p.description,
        p.category,
        p.price,
        i.quantity,
        s.supplier_name
    FROM Products p
    JOIN Inventory i ON p.product_id = i.product_id
    JOIN Suppliers s ON i.supplier_id = s.supplier_id
    WHERE p.product_id = @product_id;
END;
GO



-- 1. Search products
SELECT * FROM View_ProductSearch 
WHERE product_name LIKE '%Laptop%' OR category LIKE '%Electronics%';

-- 2. View low stock
SELECT * FROM View_LowStockReport;

-- 3. Add new product
EXEC AddNewProduct 
    @name = N'Mouse', 
    @description = N'Wireless Mouse', 
    @price = 25.99, 
    @category = N'Electronics', 
    @quantity = 50, 
    @supplier_id = 1;

-- 4. Update product
EXEC UpdateProduct 
    @product_id = 1, 
    @name = N'Gaming Laptop', 
    @price = 1500.00, 
    @quantity = 8;

-- 5. Delete product
EXEC DeleteProduct @product_id = 3;

-- 6. View product details
EXEC ViewProductDetails @product_id = 1;

select * from Products;