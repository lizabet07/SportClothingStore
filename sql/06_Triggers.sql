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
