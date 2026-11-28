
USE SportClothingStore;
GO

SELECT
    t.name AS TableName,
    c.name AS ColumnName,
    ty.name AS DataType,
    c.is_nullable AS IsNullable
FROM sys.tables t
JOIN sys.columns c
    ON t.object_id = c.object_id
JOIN sys.types ty
    ON c.user_type_id = ty.user_type_id
ORDER BY t.name, c.column_id;



SELECT
    fk.name AS ForeignKeyName,
    OBJECT_NAME(fk.parent_object_id) AS TableName,
    OBJECT_NAME(fk.referenced_object_id) AS ReferencedTable
FROM sys.foreign_keys fk
ORDER BY TableName;



USE SportClothingStore;
GO

SELECT
    t.name AS TableName,
    kc.name AS PrimaryKeyName
FROM sys.tables t
LEFT JOIN sys.key_constraints kc
    ON t.object_id = kc.parent_object_id
    AND kc.type = 'PK'
ORDER BY t.name;



-- Проверка ограничений CHECK

SELECT
    OBJECT_NAME(parent_object_id) AS TableName,
    name AS ConstraintName,
    definition AS Condition
FROM sys.check_constraints
ORDER BY TableName;



SELECT
    OBJECT_NAME(kc.parent_object_id) AS TableName,
    kc.name AS ConstraintName,
    kc.type_desc AS ConstraintType
FROM sys.key_constraints kc
WHERE kc.type = 'UQ'
ORDER BY TableName;
