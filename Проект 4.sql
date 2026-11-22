-- Оформляет продажу и уменьшает остаток товара

USE SportClothingStore;
GO

CREATE OR ALTER PROCEDURE dbo.sp_CreateSale
    @CustomerID INT,
    @VariantID INT,
    @Quantity INT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @Price DECIMAL(10,2);
    DECLARE @SaleID INT;

    IF @Quantity <= 0
        THROW 50001, N'Количество должно быть больше нуля', 1;

    BEGIN TRY
        BEGIN TRANSACTION;

        SELECT @Price = p.Price
        FROM dbo.Products p
        JOIN dbo.ProductVariants pv
            ON p.ProductID = pv.ProductID
        WHERE pv.VariantID = @VariantID;

        IF @Price IS NULL
            THROW 50002, N'Товар не найден', 1;

        IF NOT EXISTS (
            SELECT 1
            FROM dbo.Customers
            WHERE CustomerID = @CustomerID
        )
            THROW 50003, N'Покупатель не найден', 1;

        UPDATE dbo.Stock
        SET Quantity = Quantity - @Quantity
        WHERE VariantID = @VariantID
          AND Quantity >= @Quantity;

        IF @@ROWCOUNT = 0
            THROW 50004, N'Недостаточно товара на складе', 1;

        INSERT INTO dbo.Sales (CustomerID)
        VALUES (@CustomerID);

        SET @SaleID = SCOPE_IDENTITY();

        INSERT INTO dbo.SaleItems
            (SaleID, VariantID, Quantity, UnitPrice)
        VALUES
            (@SaleID, @VariantID, @Quantity, @Price);

        COMMIT TRANSACTION;

        SELECT @SaleID AS SaleID;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        THROW;
    END CATCH
END;
GO

/*
проверка продаж

EXEC dbo.sp_CreateSale
    @CustomerID = 1,
    @VariantID = 4,
    @Quantity = 1;



SELECT * FROM dbo.Stock
WHERE VariantID = 4;

SELECT * FROM dbo.Sales;

SELECT * FROM dbo.SaleItems;
*/


-- 	Ищет товары по названию


CREATE OR ALTER PROCEDURE dbo.sp_SearchProducts
    @SearchText NVARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT *
    FROM dbo.vw_ProductCatalog
    WHERE ProductName LIKE N'%' + @SearchText + N'%';
END;
GO

-- Добавляет товар на склад, увеличивая его количество

USE SportClothingStore;
GO

CREATE OR ALTER PROCEDURE dbo.sp_AddStock
    @VariantID INT,
    @Quantity INT
AS
BEGIN
    SET NOCOUNT ON;

    IF @Quantity <= 0
        THROW 50005, N'Количество должно быть больше нуля', 1;

    UPDATE dbo.Stock
    SET Quantity = Quantity + @Quantity
    WHERE VariantID = @VariantID;

    IF @@ROWCOUNT = 0
    BEGIN
        INSERT INTO dbo.Stock (VariantID, Quantity)
        VALUES (@VariantID, @Quantity);
    END;
END;
GO

USE SportClothingStore;
GO

SELECT name
FROM sys.procedures
WHERE name IN (
    'sp_CreateSale',
    'sp_AddStock',
    'sp_SearchProducts'
);

-- получение поставки

USE SportClothingStore;
GO

CREATE OR ALTER PROCEDURE dbo.sp_ReceiveSupply
    @SupplyOrderID INT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        IF NOT EXISTS (
            SELECT 1
            FROM dbo.SupplyOrders WITH (UPDLOCK, HOLDLOCK)
            WHERE SupplyOrderID = @SupplyOrderID
              AND Status IN (N'Создан', N'Отправлен')
        )
            THROW 50007, N'Заказ не найден или уже обработан', 1;

        IF NOT EXISTS (
            SELECT 1
            FROM dbo.SupplyOrderItems
            WHERE SupplyOrderID = @SupplyOrderID
        )
            THROW 50008, N'В заказе нет товаров', 1;

        UPDATE st
        SET st.Quantity = st.Quantity + si.Quantity
        FROM dbo.Stock st
        JOIN dbo.SupplyOrderItems si
            ON st.VariantID = si.VariantID
        WHERE si.SupplyOrderID = @SupplyOrderID;

        INSERT INTO dbo.Stock (VariantID, Quantity)
        SELECT si.VariantID, si.Quantity
        FROM dbo.SupplyOrderItems si
        WHERE si.SupplyOrderID = @SupplyOrderID
          AND NOT EXISTS (
              SELECT 1
              FROM dbo.Stock st
              WHERE st.VariantID = si.VariantID
          );

        UPDATE dbo.SupplyOrders
        SET Status = N'Получен'
        WHERE SupplyOrderID = @SupplyOrderID;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        THROW;
    END CATCH
END;
GO
