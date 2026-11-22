-- Тригеры

USE SportClothingStore;
GO

IF COL_LENGTH('dbo.Products', 'SupplierID') IS NULL
BEGIN
    ALTER TABLE dbo.Products
    ADD SupplierID INT NULL;
END;
GO

UPDATE dbo.Products
SET SupplierID = (
    SELECT SupplierID
    FROM dbo.Suppliers
    WHERE SupplierName = N'SportLine'
)
WHERE ProductName = N'Спортивные легинсы';

UPDATE dbo.Products
SET SupplierID = (
    SELECT SupplierID
    FROM dbo.Suppliers
    WHERE SupplierName = N'FitWear'
)
WHERE ProductName IN (
    N'Спортивный топ',
    N'Футболка для тренировок'
);
GO

IF NOT EXISTS (
    SELECT 1
    FROM sys.foreign_keys
    WHERE name = 'FK_Products_Suppliers'
      AND parent_object_id = OBJECT_ID('dbo.Products')
)
BEGIN
    ALTER TABLE dbo.Products
    ADD CONSTRAINT FK_Products_Suppliers
    FOREIGN KEY (SupplierID)
    REFERENCES dbo.Suppliers(SupplierID);
END;
GO


-- Создаём триггер автоматического заказа

USE SportClothingStore;
GO

CREATE OR ALTER TRIGGER dbo.trg_LowStock
ON dbo.Stock
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @VariantID INT;
    DECLARE @SupplierID INT;
    DECLARE @Quantity INT;
    DECLARE @OrderID INT;

    DECLARE low_stock_cursor CURSOR LOCAL FAST_FORWARD
    FOR
        SELECT
            i.VariantID,
            p.SupplierID,
            i.Quantity
        FROM inserted i
        JOIN deleted d
            ON i.StockID = d.StockID
        JOIN dbo.ProductVariants pv
            ON i.VariantID = pv.VariantID
        JOIN dbo.Products p
            ON pv.ProductID = p.ProductID
        WHERE i.Quantity < 6
          AND d.Quantity >= 6
          AND p.SupplierID IS NOT NULL;

    OPEN low_stock_cursor;

    FETCH NEXT FROM low_stock_cursor
    INTO @VariantID, @SupplierID, @Quantity;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        IF NOT EXISTS (
            SELECT 1
            FROM dbo.SupplyOrders so
            JOIN dbo.SupplyOrderItems si
                ON so.SupplyOrderID = si.SupplyOrderID
            WHERE si.VariantID = @VariantID
              AND so.Status IN (
                  N'Создан',
                  N'Отправлен'
              )
        )
        BEGIN
            INSERT INTO dbo.SupplyOrders (SupplierID)
            VALUES (@SupplierID);

            SET @OrderID = SCOPE_IDENTITY();

            INSERT INTO dbo.SupplyOrderItems
                (SupplyOrderID, VariantID, Quantity)
            VALUES
                (@OrderID, @VariantID, 15 - @Quantity);
        END;

        FETCH NEXT FROM low_stock_cursor
        INTO @VariantID, @SupplierID, @Quantity;
    END;

    CLOSE low_stock_cursor;
    DEALLOCATE low_stock_cursor;
END;
GO

