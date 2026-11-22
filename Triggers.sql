
USE SportClothingStore;
GO

BEGIN TRANSACTION;

-- Уменьшаем остаток с 8 до 4
UPDATE dbo.Stock
SET Quantity = 4
WHERE VariantID = 2
  AND Quantity >= 6;

-- Проверяем остаток
SELECT *
FROM dbo.Stock
WHERE VariantID = 2;

-- Проверяем созданную заявку
SELECT
    so.SupplyOrderID,
    so.SupplierID,
    so.Status,
    si.VariantID,
    si.Quantity
FROM dbo.SupplyOrders so
JOIN dbo.SupplyOrderItems si
    ON so.SupplyOrderID = si.SupplyOrderID
WHERE si.VariantID = 2;

-- Отменяем тестовые изменения
ROLLBACK TRANSACTION;



SELECT *
FROM dbo.Stock
WHERE VariantID = 2;
