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
