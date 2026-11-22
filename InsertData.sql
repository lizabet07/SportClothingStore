-- Полный каталог товаров


USE SportClothingStore;
GO

CREATE VIEW vw_ProductCatalog AS
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

-- Представление складских остатков

CREATE VIEW vw_StockBalance AS
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

-- Представление товаров с низким остатком

CREATE VIEW vw_LowStock AS
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



SELECT * FROM vw_ProductCatalog;

SELECT * FROM vw_StockBalance;

SELECT * FROM vw_LowStock;

