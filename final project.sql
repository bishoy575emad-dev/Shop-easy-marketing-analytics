

-- 1. Customers
SELECT * FROM dbo.customers;

-- 2. Products
SELECT * FROM dbo.products;

-- 3. Customer Journey
SELECT * FROM dbo.customer_journey;

-- 4. Customer Reviews
SELECT * FROM dbo.customer_reviews;

-- 5. Engagement Data
SELECT * FROM dbo.engagement_data;

-- 6. Geography
SELECT * FROM dbo.geography;
/*==================================================================================*/
-- شوف structure كل جدول
EXEC sp_help 'dbo.customers';
EXEC sp_help 'dbo.products';
EXEC sp_help 'dbo.customer_journey';
EXEC sp_help 'dbo.customer_reviews';
EXEC sp_help 'dbo.engagement_data';
EXEC sp_help 'dbo.geography';
/*==================================================================================*/
SELECT 
    TABLE_NAME,
    COLUMN_NAME,
    DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'dbo'
ORDER BY TABLE_NAME, ORDINAL_POSITION;

-- نشوف عدد الصفوف في كل جدول
SELECT 'customers' AS TableName, COUNT(*) AS _RowCount FROM dbo.customers
UNION ALL
SELECT 'products', COUNT(*) FROM dbo.products
UNION ALL
SELECT 'customer_journey', COUNT(*) FROM dbo.customer_journey
UNION ALL
SELECT 'customer_reviews', COUNT(*) FROM dbo.customer_reviews
UNION ALL
SELECT 'engagement_data', COUNT(*) FROM dbo.engagement_data
UNION ALL
SELECT 'geography', COUNT(*) FROM dbo.geography;

SELECT 'customers' AS TableName, COUNT(*) AS [RowCount] FROM dbo.customers
UNION ALL
SELECT 'products', COUNT(*) FROM dbo.products
UNION ALL
SELECT 'customer_journey', COUNT(*) FROM dbo.customer_journey
UNION ALL
SELECT 'customer_reviews', COUNT(*) FROM dbo.customer_reviews
UNION ALL
SELECT 'engagement_data', COUNT(*) FROM dbo.engagement_data
UNION ALL
SELECT 'geography', COUNT(*) FROM dbo.geography;
/*====================================================================================*/

-- NULL في customers
SELECT 
    SUM(CASE WHEN CustomerName IS NULL THEN 1 ELSE 0 END) AS NullNames,
    SUM(CASE WHEN Email IS NULL THEN 1 ELSE 0 END) AS NullEmails,
    SUM(CASE WHEN Age IS NULL THEN 1 ELSE 0 END) AS NullAge,
    SUM(CASE WHEN Gender IS NULL THEN 1 ELSE 0 END) AS NullGender
FROM dbo.customers;

-- NULL في customer_journey
SELECT 
    SUM(CASE WHEN Stage IS NULL THEN 1 ELSE 0 END) AS NullStage,
    SUM(CASE WHEN Action IS NULL THEN 1 ELSE 0 END) AS NullAction,
    SUM(CASE WHEN Duration IS NULL THEN 1 ELSE 0 END) AS NullDuration
FROM dbo.customer_journey;

-- NULL في customer_reviews
SELECT 
    SUM(CASE WHEN Rating IS NULL THEN 1 ELSE 0 END) AS NullRating,
    SUM(CASE WHEN ReviewText IS NULL THEN 1 ELSE 0 END) AS NullReviewText
FROM dbo.customer_reviews;

-- Duplicates في customers
SELECT CustomerID, COUNT(*) AS [Count]
FROM dbo.customers
GROUP BY CustomerID
HAVING COUNT(*) > 1;

-- Duplicates في customer_journey
SELECT JourneyID, COUNT(*) AS [Count]
FROM dbo.customer_journey
GROUP BY JourneyID
HAVING COUNT(*) > 1;
/*===============================================*/
-- 3️⃣ FORMAT - نشوف التواريخ غلط؟
SELECT VisitDate 
FROM dbo.customer_journey
WHERE TRY_CONVERT(DATE, VisitDate) IS NULL;

-- 4️⃣ OUTLIERS - قيم غريبة
-- Age
SELECT MIN(Age) AS MinAge, MAX(Age) AS MaxAge, AVG(Age) AS AvgAge
FROM dbo.customers;

-- Duration
SELECT MIN(Duration) AS MinDuration, MAX(Duration) AS MaxDuration, AVG(Duration) AS AvgDuration
FROM dbo.customer_journey;

-- Rating
SELECT MIN(Rating) AS MinRating, MAX(Rating) AS MaxRating
FROM dbo.customer_reviews;

-- Price
SELECT MIN(Price) AS MinPrice, MAX(Price) AS MaxPrice
FROM dbo.products;

-- 5️⃣ INCONSISTENCY - قيم متناقضة
-- Gender
SELECT Gender, COUNT(*) AS [Count]
FROM dbo.customers
GROUP BY Gender;

-- Stage
SELECT Stage, COUNT(*) AS [Count]
FROM dbo.customer_journey
GROUP BY Stage;

-- Action
SELECT Action, COUNT(*) AS [Count]
FROM dbo.customer_journey
GROUP BY Action;

-- ContentType
SELECT ContentType, COUNT(*) AS [Count]
FROM dbo.engagement_data
GROUP BY ContentType;

-- نشوف الصفوف المكررة
SELECT *
FROM dbo.customer_journey
WHERE JourneyID IN (
    SELECT JourneyID
    FROM dbo.customer_journey
    GROUP BY JourneyID
    HAVING COUNT(*) > 1
)
ORDER BY JourneyID;
/*=======================================*/
WITH CTE AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY JourneyID 
            ORDER BY JourneyID
        ) AS RowNum
    FROM dbo.customer_journey
)
DELETE FROM CTE WHERE RowNum > 1;
/*==============================================*/
SELECT ContentType,
CASE
    WHEN ContentType = 'newsletter' THEN 'Newsletter'
    WHEN ContentType = 'video' THEN 'Video'
    WHEN ContentType = 'Socialmedia' THEN 'Social Media'
    WHEN ContentType = 'Blog' THEN 'Blog'
    ELSE ContentType
END AS NewValue
FROM dbo.engagement_data;
/*=========================================*/
UPDATE dbo.engagement_data
SET ContentType =
CASE
    WHEN ContentType = 'newsletter' THEN 'Newsletter'
    WHEN ContentType = 'video' THEN 'Video'
    WHEN ContentType = 'Socialmedia' THEN 'Social Media'
    WHEN ContentType = 'Blog' THEN 'Blog'
    ELSE ContentType
END;
/*=========================================*/
ALTER TABLE dbo.customers
DROP COLUMN Email;

/*=========================================*/
SELECT * FROM dbo.engagement_data;
SELECT * FROM dbo.customer_journey;


/*=========================================*/
    CREATE VIEW vw_customers AS
SELECT *
FROM dbo.customers;

/*=========================================*/
CREATE VIEW vw_products AS
SELECT *
FROM dbo.products;

/*=========================================*/
CREATE VIEW vw_customer_journey AS
SELECT *
FROM dbo.customer_journey;

/*=========================================*/

CREATE VIEW vw_customer_reviews AS
SELECT *
FROM dbo.customer_reviews;
/*=========================================*/

CREATE VIEW vw_engagement_data AS
SELECT *
FROM dbo.engagement_data;
/*=========================================*/
CREATE VIEW vw_geography AS
SELECT *
FROM dbo.geography;

/*=========================================*/
SELECT COUNT(*) FROM vw_customers;
SELECT COUNT(*) FROM vw_products;
SELECT COUNT(*) FROM vw_customer_journey;
SELECT COUNT(*) FROM vw_engagement_data;
SELECT COUNT(*) FROM vw_customer_reviews;
SELECT COUNT(*) FROM vw_geography;
============================
-- التأكد من Duplicates في كل الجداول
SELECT 'customer_journey' AS TableName, COUNT(*) - COUNT(DISTINCT JourneyID) AS Duplicates
FROM dbo.customer_journey
UNION ALL
SELECT 'customers', COUNT(*) - COUNT(DISTINCT CustomerID)
FROM dbo.customers
UNION ALL
SELECT 'customer_reviews', COUNT(*) - COUNT(DISTINCT ReviewID)
FROM dbo.customer_reviews
UNION ALL
SELECT 'engagement_data', COUNT(*) - COUNT(DISTINCT EngagementID)
FROM dbo.engagement_data
UNION ALL
SELECT 'products', COUNT(*) - COUNT(DISTINCT ProductID)
FROM dbo.products;