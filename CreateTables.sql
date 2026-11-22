-- Создали первые 4 таблицы
CREATE DATABASE SportClothingStore;
GO

USE SportClothingStore;
GO


CREATE TABLE Categories (
    CategoryID INT IDENTITY(1,1) PRIMARY KEY,
    CategoryName NVARCHAR(100) NOT NULL UNIQUE
);


CREATE TABLE Colors (
    ColorID INT IDENTITY(1,1) PRIMARY KEY,
    ColorName NVARCHAR(50) NOT NULL UNIQUE
);


CREATE TABLE Sizes (
    SizeID INT IDENTITY(1,1) PRIMARY KEY,
    SizeName NVARCHAR(20) NOT NULL UNIQUE
);


CREATE TABLE Styles (
    StyleID INT IDENTITY(1,1) PRIMARY KEY,
    StyleName NVARCHAR(100) NOT NULL UNIQUE
);


INSERT INTO Categories (CategoryName)
VALUES
(N'Легинсы'),
(N'Топы'),
(N'Футболки'),
(N'Спортивные костюмы'),
(N'Шорты');

INSERT INTO Colors (ColorName)
VALUES
(N'Чёрный'),
(N'Белый'),
(N'Серый'),
(N'Розовый'),
(N'Синий');

INSERT INTO Sizes (SizeName)
VALUES
(N'XS'),
(N'S'),
(N'M'),
(N'L'),
(N'XL');

INSERT INTO Styles (StyleName)
VALUES
(N'Облегающий'),
(N'Свободный'),
(N'Укороченный'),
(N'Классический');


-- таблицы товаров и складов

USE SportClothingStore;
GO

CREATE TABLE Products (
    ProductID INT IDENTITY(1,1) PRIMARY KEY,
    ProductName NVARCHAR(100) NOT NULL,
    CategoryID INT NOT NULL,
    StyleID INT NOT NULL,
    Price DECIMAL(10,2) NOT NULL,

    CONSTRAINT FK_Products_Categories
        FOREIGN KEY (CategoryID)
        REFERENCES Categories(CategoryID),

    CONSTRAINT FK_Products_Styles
        FOREIGN KEY (StyleID)
        REFERENCES Styles(StyleID),

    CONSTRAINT CHK_Products_Price
        CHECK (Price >= 0)
);



CREATE TABLE ProductVariants (
    VariantID INT IDENTITY(1,1) PRIMARY KEY,
    ProductID INT NOT NULL,
    ColorID INT NOT NULL,
    SizeID INT NOT NULL,

    CONSTRAINT FK_Variants_Products
        FOREIGN KEY (ProductID)
        REFERENCES Products(ProductID),

    CONSTRAINT FK_Variants_Colors
        FOREIGN KEY (ColorID)
        REFERENCES Colors(ColorID),

    CONSTRAINT FK_Variants_Sizes
        FOREIGN KEY (SizeID)
        REFERENCES Sizes(SizeID),

    CONSTRAINT UQ_ProductVariant
        UNIQUE (ProductID, ColorID, SizeID)
);



CREATE TABLE Stock (
    StockID INT IDENTITY(1,1) PRIMARY KEY,
    VariantID INT NOT NULL UNIQUE,
    Quantity INT NOT NULL DEFAULT 0,

    CONSTRAINT FK_Stock_Variants
        FOREIGN KEY (VariantID)
        REFERENCES ProductVariants(VariantID),

    CONSTRAINT CHK_Stock_Quantity
        CHECK (Quantity >= 0)
);



INSERT INTO Products
    (ProductName, CategoryID, StyleID, Price)
VALUES
    (N'Спортивные легинсы', 1, 1, 2490.00),
    (N'Спортивный топ', 2, 1, 1790.00),
    (N'Футболка для тренировок', 3, 2, 1490.00);




INSERT INTO ProductVariants
    (ProductID, ColorID, SizeID)
VALUES
    (1, 1, 2),
    (1, 1, 3),
    (1, 2, 2),
    (2, 1, 2),
    (2, 2, 3),
    (3, 3, 4);



INSERT INTO Stock (VariantID, Quantity)
VALUES
    (1, 12),
    (2, 8),
    (3, 15),
    (4, 4),
    (5, 10),
    (6, 7);


-- создаем таблицы поставщики, покупатели и заказы

USE SportClothingStore;
GO

CREATE TABLE Suppliers (
    SupplierID INT IDENTITY(1,1) PRIMARY KEY,
    SupplierName NVARCHAR(100) NOT NULL,
    Phone NVARCHAR(20),
    Email NVARCHAR(100)
);


CREATE TABLE Customers (
    CustomerID INT IDENTITY(1,1) PRIMARY KEY,
    FirstName NVARCHAR(50) NOT NULL,
    LastName NVARCHAR(50) NOT NULL,
    Phone NVARCHAR(20),
    Email NVARCHAR(100)
);


CREATE TABLE Sales (
    SaleID INT IDENTITY(1,1) PRIMARY KEY,
    CustomerID INT NOT NULL,
    SaleDate DATETIME2 NOT NULL
        DEFAULT SYSDATETIME(),

    CONSTRAINT FK_Sales_Customers
        FOREIGN KEY (CustomerID)
        REFERENCES Customers(CustomerID)
);


CREATE TABLE SaleItems (
    SaleItemID INT IDENTITY(1,1) PRIMARY KEY,
    SaleID INT NOT NULL,
    VariantID INT NOT NULL,
    Quantity INT NOT NULL,
    UnitPrice DECIMAL(10,2) NOT NULL,

    CONSTRAINT FK_SaleItems_Sales
        FOREIGN KEY (SaleID)
        REFERENCES Sales(SaleID),

    CONSTRAINT FK_SaleItems_Variants
        FOREIGN KEY (VariantID)
        REFERENCES ProductVariants(VariantID),

    CONSTRAINT CHK_SaleItems_Quantity
        CHECK (Quantity > 0),

    CONSTRAINT CHK_SaleItems_Price
        CHECK (UnitPrice >= 0)
);



CREATE TABLE SupplyOrders (
    SupplyOrderID INT IDENTITY(1,1) PRIMARY KEY,
    SupplierID INT NOT NULL,
    OrderDate DATETIME2 NOT NULL
        DEFAULT SYSDATETIME(),
    Status NVARCHAR(20) NOT NULL
        DEFAULT N'Создан',

    CONSTRAINT FK_SupplyOrders_Suppliers
        FOREIGN KEY (SupplierID)
        REFERENCES Suppliers(SupplierID),

    CONSTRAINT CHK_SupplyOrders_Status
        CHECK (Status IN (
            N'Создан',
            N'Отправлен',
            N'Получен',
            N'Отменён'
        ))
);


CREATE TABLE SupplyOrderItems (
    SupplyOrderItemID INT IDENTITY(1,1) PRIMARY KEY,
    SupplyOrderID INT NOT NULL,
    VariantID INT NOT NULL,
    Quantity INT NOT NULL,
    PurchasePrice DECIMAL(10,2),

    CONSTRAINT FK_SupplyItems_Orders
        FOREIGN KEY (SupplyOrderID)
        REFERENCES SupplyOrders(SupplyOrderID),

    CONSTRAINT FK_SupplyItems_Variants
        FOREIGN KEY (VariantID)
        REFERENCES ProductVariants(VariantID),

    CONSTRAINT CHK_SupplyItems_Quantity
        CHECK (Quantity > 0),

    CONSTRAINT CHK_SupplyItems_Price
        CHECK (PurchasePrice >= 0),

    CONSTRAINT UQ_SupplyOrder_Variant
        UNIQUE (SupplyOrderID, VariantID)
);


INSERT INTO Suppliers
    (SupplierName, Phone, Email)
VALUES
    (N'SportLine', N'+79990001122',
     N'sportline@example.com'),
    (N'FitWear', N'+79990003344',
     N'fitwear@example.com');

INSERT INTO Customers
    (FirstName, LastName, Phone, Email)
VALUES
    (N'Анна', N'Иванова', N'+79991112233',
     N'anna@example.com'),
    (N'Мария', N'Петрова', N'+79994445566',
     N'maria@example.com');
