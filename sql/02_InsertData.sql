USE SportClothingStore;
GO

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

-- Назначение поставщиков товарам
UPDATE dbo.Products SET SupplierID = (SELECT SupplierID FROM dbo.Suppliers WHERE SupplierName = N'SportLine') WHERE ProductName = N'Спортивные легинсы';
UPDATE dbo.Products SET SupplierID = (SELECT SupplierID FROM dbo.Suppliers WHERE SupplierName = N'FitWear') WHERE ProductName IN (N'Спортивный топ', N'Футболка для тренировок');
GO
