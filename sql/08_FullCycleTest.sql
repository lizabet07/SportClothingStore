

USE SportClothingStore;
GO

SELECT
    VariantID,
    Quantity
FROM dbo.Stock
WHERE VariantID = 2;

SELECT
    so.SupplyOrderID,
    so.Status,
    si.VariantID,
    si.Quantity
FROM dbo.SupplyOrders so
JOIN dbo.SupplyOrderItems si
    ON so.SupplyOrderID = si.SupplyOrderID
WHERE si.VariantID = 2;





USE SportClothingStore;
GO

BEGIN TRY
    BEGIN TRANSACTION;

    -- 1. Продаём 4 пары легинсов
    EXEC dbo.sp_CreateSale
        @CustomerID = 1,
        @VariantID = 2,
        @Quantity = 4;

    -- 2. Проверяем остаток после продажи
    SELECT VariantID, Quantity
    FROM dbo.Stock
    WHERE VariantID = 2;

    -- 3. Находим автоматически созданный заказ
    DECLARE @OrderID INT;

    SELECT TOP 1
        @OrderID = so.SupplyOrderID
    FROM dbo.SupplyOrders so
    JOIN dbo.SupplyOrderItems si
        ON so.SupplyOrderID = si.SupplyOrderID
    WHERE si.VariantID = 2
      AND so.Status = N'Создан'
    ORDER BY so.SupplyOrderID DESC;

    IF @OrderID IS NULL
        THROW 50010, N'Заявка не создалась', 1;

    -- 4. Проверяем заказ поставщику
    SELECT
        so.SupplyOrderID,
        so.Status,
        si.VariantID,
        si.Quantity
    FROM dbo.SupplyOrders so
    JOIN dbo.SupplyOrderItems si
        ON so.SupplyOrderID = si.SupplyOrderID
    WHERE so.SupplyOrderID = @OrderID;

    -- 5. Получаем поставку
    EXEC dbo.sp_ReceiveSupply
        @SupplyOrderID = @OrderID;

    -- 6. Проверяем склад после поставки
    SELECT VariantID, Quantity
    FROM dbo.Stock
    WHERE VariantID = 2;

    -- 7. Проверяем статус заказа
    SELECT SupplyOrderID, Status
    FROM dbo.SupplyOrders
    WHERE SupplyOrderID = @OrderID;

    -- Отменяем все тестовые изменения
    ROLLBACK TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;

    THROW;
END CATCH;
GO


