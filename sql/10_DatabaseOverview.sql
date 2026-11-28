
USE SportClothingStore;
GO

SELECT
    N'Таблицы' AS ObjectType,
    COUNT(*) AS ObjectCount
FROM sys.tables

UNION ALL

SELECT
    N'Представления',
    COUNT(*)
FROM sys.views

UNION ALL

SELECT
    N'Функции',
    COUNT(*)
FROM sys.objects
WHERE type IN ('FN', 'IF', 'TF')

UNION ALL

SELECT
    N'Процедуры',
    COUNT(*)
FROM sys.procedures

UNION ALL

SELECT
    N'Триггеры',
    COUNT(*)
FROM sys.triggers
WHERE parent_class = 1;
