USE SportClothingStore;
GO

CREATE OR ALTER VIEW vw_ProductCatalog AS
SELECT
    pv.VariantID,
    p.ProductName,
    cat.CategoryName,
    sty.StyleName,
    c.ColorName,
    s.SizeName,
    p.Price,
    st.Quantity
FROM ProductVariants pv
JOIN Products p
    ON pv.ProductID = p.ProductID
JOIN Categories cat
    ON p.CategoryID = cat.CategoryID
JOIN Styles sty
    ON p.StyleID = sty.StyleID
JOIN Colors c
    ON pv.ColorID = c.ColorID
JOIN Sizes s
    ON pv.SizeID = s.SizeID
JOIN Stock st
    ON pv.VariantID = st.VariantID;
GO

CREATE OR ALTER VIEW vw_StockBalance AS
SELECT
    pv.VariantID,
    p.ProductName,
    c.ColorName,
    s.SizeName,
    st.Quantity
FROM Stock st
JOIN ProductVariants pv
    ON st.VariantID = pv.VariantID
JOIN Products p
    ON pv.ProductID = p.ProductID
JOIN Colors c
    ON pv.ColorID = c.ColorID
JOIN Sizes s
    ON pv.SizeID = s.SizeID;
GO

CREATE OR ALTER VIEW vw_LowStock AS
SELECT
    pv.VariantID,
    p.ProductName,
    c.ColorName,
    s.SizeName,
    st.Quantity
FROM Stock st
JOIN ProductVariants pv
    ON st.VariantID = pv.VariantID
JOIN Products p
    ON pv.ProductID = p.ProductID
JOIN Colors c
    ON pv.ColorID = c.ColorID
JOIN Sizes s
    ON pv.SizeID = s.SizeID
WHERE st.Quantity < 6;
GO
