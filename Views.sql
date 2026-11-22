-- Функция для получения остатка

USE SportClothingStore;
GO

CREATE OR ALTER FUNCTION dbo.fn_GetStock
(
    @VariantID INT
)
RETURNS INT
AS
BEGIN
    DECLARE @Quantity INT;

    SELECT @Quantity = Quantity
    FROM Stock
    WHERE VariantID = @VariantID;

    RETURN ISNULL(@Quantity, 0);
END;
GO

-- Функция общего остатка товара

CREATE OR ALTER FUNCTION dbo.fn_GetProductStock
(
    @ProductID INT
)
RETURNS INT
AS
BEGIN
    DECLARE @TotalQuantity INT;

    SELECT @TotalQuantity = SUM(st.Quantity)
    FROM Stock st
    JOIN ProductVariants pv
        ON st.VariantID = pv.VariantID
    WHERE pv.ProductID = @ProductID;

    RETURN ISNULL(@TotalQuantity, 0);
END;
GO


SELECT dbo.fn_GetProductStock(1) AS TotalStock;

-- Функция стоимости продажи


CREATE OR ALTER FUNCTION dbo.fn_GetSaleTotal
(
    @SaleID INT
)
RETURNS DECIMAL(12,2)
AS
BEGIN
    DECLARE @Total DECIMAL(12,2);

    SELECT @Total = SUM(Quantity * UnitPrice)
    FROM SaleItems
    WHERE SaleID = @SaleID;

    RETURN ISNULL(@Total, 0);
END;
GO

SELECT dbo.fn_GetSaleTotal(1) AS SaleTotal;


SELECT
    name
FROM sys.objects
WHERE type IN ('FN', 'IF', 'TF')
  AND name IN (
      'fn_GetStock',
      'fn_GetProductStock',
      'fn_GetSaleTotal'
  );
