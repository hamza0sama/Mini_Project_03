
IF NOT EXISTS (SELECT 1 FROM sys.databases WHERE name = 'Mini_Project_02')
    CREATE DATABASE Mini_Project_02;


use Mini_Project_02;    
GO
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'staging')
    EXEC('CREATE SCHEMA staging');
GO
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'bronze')
    EXEC('CREATE SCHEMA bronze');
GO
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'silver')
    EXEC('CREATE SCHEMA silver');
GO
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'gold')
    EXEC('CREATE SCHEMA gold');
GO

SELECT *
FROM sys.schemas WHERE name ='staging';

GO

-- ==============================================================================
-- STAGING LAYER


IF OBJECT_ID('staging.raw_encounters', 'U') IS NULL
BEGIN
    CREATE TABLE staging.raw_encounters (
        "Row ID" NVARCHAR(255),
        "Order ID" NVARCHAR(255),
        "Order Date" NVARCHAR(255),
        "Ship Date" NVARCHAR(255),
        "Ship Mode" NVARCHAR(255),
        "Customer ID" NVARCHAR(255),
        "Customer Name" NVARCHAR(255),
        "Segment" NVARCHAR(255),
        "Country" NVARCHAR(255),
        "City" NVARCHAR(255),
        "State" NVARCHAR(255),
        "Postal Code" NVARCHAR(255),
        "Region" NVARCHAR(255),
        "Product ID" NVARCHAR(255),
        "Category" NVARCHAR(255),
        "Sub Category" NVARCHAR(255),
        "Product Name" NVARCHAR(255),
        "Sales" NVARCHAR(255),
        "Quantity" NVARCHAR(255),
        "Discount" NVARCHAR(255),
        "Profit" NVARCHAR(255)
    );
END;
GO
TRUNCATE TABLE staging.raw_encounters;
GO
BULK INSERT staging.raw_encounters
FROM 'C:\Users\Mohamed Ahmed Rashed\Desktop\Mini_Project_03\Central_Superstore.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0a',
    FORMAT = 'CSV',
    FIELDQUOTE = '"',
    CODEPAGE = '65001',
    MAXERRORS = 0,
    ERRORFILE = 'C:\Users\Mohamed Ahmed Rashed\Desktop\Mini_Project_03\raw_encounters_err.log'
);
GO


-- =========================================================
-- BRONZE LAYER


IF OBJECT_ID('bronze.encounters', 'U') IS NULL
BEGIN
    CREATE TABLE bronze.encounters (
    bronze_id INT IDENTITY(1,1) PRIMARY KEY,
    "Row ID"  NVARCHAR(255),
    "Order ID" NVARCHAR(255),
    "Order Date"  NVARCHAR(255),
    "Ship Date"  NVARCHAR(255),
    "Ship Mode"  NVARCHAR(255),
    "Customer ID"  NVARCHAR(255),
    "Customer Name"  NVARCHAR(255),
    "Segment"   NVARCHAR(255),
    "Country"  NVARCHAR(255),
    "City"  NVARCHAR(255),
    "State"  NVARCHAR(255),
    "Postal Code"  NVARCHAR(255),
    "Region" NVARCHAR(255),
    "Product ID"  NVARCHAR(255),
    "Category"  NVARCHAR(255),
    "Sub Category"  NVARCHAR(255),
    "Product Name" NVARCHAR(255),
    "Sales" NVARCHAR(255),
    "Quantity" NVARCHAR(255),
    "Discount" NVARCHAR(255),
    "Profit" NVARCHAR(255)
    );
END;
GO
INSERT INTO bronze.encounters ("Row ID", "Order ID","Order Date","Ship Date" ,"Ship Mode","Customer ID","Customer Name", "Segment","Country",
                               "City","State","Postal Code","Region","Product ID","Category",
                               "Sub Category","Product Name","Sales","Quantity","Discount","Profit"
                               )

SELECT "Row ID", "Order ID","Order Date","Ship Date" ,"Ship Mode","Customer ID","Customer Name", "Segment","Country",
                               "City","State","Postal Code","Region","Product ID","Category",
                               "Sub Category","Product Name","Sales","Quantity","Discount","Profit"
FROM staging.raw_encounters

EXCEPT

SELECT "Row ID", "Order ID","Order Date","Ship Date" ,"Ship Mode","Customer ID","Customer Name", "Segment","Country",
                               "City","State","Postal Code","Region","Product ID","Category",
                               "Sub Category","Product Name","Sales","Quantity","Discount","Profit"
FROM bronze.encounters;
GO

select *
FROM bronze.encounters;
GO

-- ==============================================================================
-- SILVER LAYER

IF OBJECT_ID('silver.encounters', 'U') IS NULL
BEGIN
        CREATE TABLE silver.encounters (
            "Row ID"  int NOT NULL,
            "Order ID" NVARCHAR(255),
            "Order Date"  DATETIME2,
            "Ship Date"  DATETIME2,
            "Ship Mode"  NVARCHAR(255),
            "Customer ID"  NVARCHAR(255),
            "Customer Name"  NVARCHAR(255),
            "Segment"   NVARCHAR(255),
            "Country"  NVARCHAR(255),
            "City"  NVARCHAR(255),
            "State"  NVARCHAR(255),
            "Postal Code"  NVARCHAR(255),
            "Region" NVARCHAR(255),
            "Product ID"  NVARCHAR(255),
            "Category"  NVARCHAR(255),
            "Sub Category"  NVARCHAR(255),
            "Product Name" NVARCHAR(255),
            "Sales" DECIMAL(18,2),
            "Quantity" INT,
            "Discount" DECIMAL(5,2),
            "Profit" DECIMAL(18,2),
        has_missing_value BIT NOT NULL DEFAULT 0,
        has_invalid_value BIT NOT NULL DEFAULT 0,
        has_outlier_value BIT NOT NULL DEFAULT 0,
        CONSTRAINT PK_silver_encounters PRIMARY KEY ("Row ID")
        )
END;
GO
TRUNCATE TABLE silver.encounters;
GO
WITH bronze_latest AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY "Row ID"
            ORDER BY bronze_id DESC
        ) AS rn
    FROM bronze.encounters
    WHERE NULLIF(LTRIM(RTRIM("Row ID")), '') IS NOT NULL
),

cleaned AS (
    SELECT

        TRY_CAST(LTRIM(RTRIM("Row ID")) AS INT) AS "Row ID",

        NULLIF(LTRIM(RTRIM("Order ID")), '') AS "Order ID",

        TRY_CAST(LTRIM(RTRIM("Order Date")) AS DATETIME2) AS "Order Date",

        TRY_CAST(LTRIM(RTRIM("Ship Date")) AS DATETIME2) AS "Ship Date",

        NULLIF(LTRIM(RTRIM("Ship Mode")), '') AS "Ship Mode",

        NULLIF(LTRIM(RTRIM("Customer ID")), '') AS "Customer ID",

        NULLIF(LTRIM(RTRIM("Customer Name")), '') AS "Customer Name",

        NULLIF(LTRIM(RTRIM("Segment")), '') AS "Segment",

        NULLIF(LTRIM(RTRIM("Country")), '') AS "Country",

        NULLIF(LTRIM(RTRIM("City")), '') AS "City",

        NULLIF(LTRIM(RTRIM("State")), '') AS "State",

        NULLIF(LTRIM(RTRIM("Postal Code")), '') AS "Postal Code",

        NULLIF(LTRIM(RTRIM("Region")), '') AS "Region",

        NULLIF(LTRIM(RTRIM("Product ID")), '') AS "Product ID",

        NULLIF(LTRIM(RTRIM("Category")), '') AS "Category",

        NULLIF(LTRIM(RTRIM("Sub Category")), '') AS "Sub Category",

        NULLIF(LTRIM(RTRIM("Product Name")), '') AS "Product Name",

        TRY_CAST(REPLACE(REPLACE(LTRIM(RTRIM("Sales")), CHAR(13), ''), CHAR(10), '')AS DECIMAL(18,2)) AS "Sales",

        TRY_CAST(
        REPLACE(REPLACE(LTRIM(RTRIM("Quantity")), CHAR(13), ''), CHAR(10), '')
        AS INT
        ) AS "Quantity",

TRY_CAST(
    REPLACE(REPLACE(LTRIM(RTRIM("Discount")), CHAR(13), ''), CHAR(10), '')
    AS DECIMAL(5,2)
) AS "Discount",

TRY_CAST(
    REPLACE(REPLACE(LTRIM(RTRIM("Profit")), CHAR(13), ''), CHAR(10), '')
    AS DECIMAL(18,2)
) AS "Profit"

    FROM bronze_latest
    WHERE rn = 1
),

iqr_bounds AS (
    SELECT
        MIN(q1_sales) AS q1_sales,
        MIN(q3_sales) AS q3_sales
    FROM (
        SELECT
            PERCENTILE_CONT(0.25)
            WITHIN GROUP (ORDER BY "Sales") OVER () AS q1_sales,

            PERCENTILE_CONT(0.75)
            WITHIN GROUP (ORDER BY "Sales") OVER () AS q3_sales
        FROM cleaned
        WHERE "Sales" IS NOT NULL
    ) AS percentile_data
),

flagged AS (
    SELECT
        c."Row ID",
        c."Order ID",
        c."Order Date",
        c."Ship Date",
        c."Ship Mode",
        c."Customer ID",
        c."Customer Name",
        c."Segment",
        c."Country",
        c."City",
        c."State",
        c."Postal Code",
        c."Region",
        c."Product ID",
        c."Category",
        c."Sub Category",
        c."Product Name",
        c."Sales",
        c."Quantity",
        c."Discount",
        c."Profit",

        CASE WHEN
                 c."Row ID" IS NULL
              OR c."Order ID" IS NULL
              OR c."Order Date" IS NULL
              OR c."Ship Date" IS NULL
              OR c."Ship Mode" IS NULL
              OR c."Customer ID" IS NULL
              OR c."Customer Name" IS NULL
              OR c."Segment" IS NULL
              OR c."Country" IS NULL
              OR c."City" IS NULL
              OR c."State" IS NULL
              OR c."Postal Code" IS NULL
              OR c."Region" IS NULL
              OR c."Product ID" IS NULL
              OR c."Category" IS NULL
              OR c."Sub Category" IS NULL
              OR c."Product Name" IS NULL
              OR c."Sales" IS NULL
              OR c."Quantity" IS NULL
              OR c."Discount" IS NULL
              OR c."Profit" IS NULL
            THEN 1
            ELSE 0
        END AS has_missing_value,

         CASE
            WHEN c."Sales" < 0
              OR c."Quantity" <= 0
              OR c."Discount" < 0
              OR c."Discount" > 1
              OR (
                    c."Order Date" IS NOT NULL
                    AND c."Ship Date" IS NOT NULL
                    AND c."Ship Date" < c."Order Date"
                 )
            THEN 1
            ELSE 0
        END AS has_invalid_value,


CASE
            WHEN c."Sales" IS NOT NULL
             AND (
                    c."Sales" <
                    (
                        b.q1_sales
                        - 1.5 * (b.q3_sales - b.q1_sales)
                    )

                    OR

                    c."Sales" >
                    (
                        b.q3_sales
                        + 1.5 * (b.q3_sales - b.q1_sales)
                    )
                 )
            THEN 1
            ELSE 0
        END AS has_outlier_value

    FROM cleaned c
    CROSS JOIN iqr_bounds b
)

INSERT INTO silver.encounters (
    "Row ID",
    "Order ID",
    "Order Date",
    "Ship Date",
    "Ship Mode",
    "Customer ID",
    "Customer Name",
    "Segment",
    "Country",
    "City",
    "State",
    "Postal Code",
    "Region",
    "Product ID",
    "Category",
    "Sub Category",
    "Product Name",
    "Sales",
    "Quantity",
    "Discount",
    "Profit",
    has_missing_value,
    has_invalid_value,
    has_outlier_value
)

SELECT
    "Row ID",
    "Order ID",
    "Order Date",
    "Ship Date",
    "Ship Mode",
    "Customer ID",
    "Customer Name",
    "Segment",
    "Country",
    "City",
    "State",
    "Postal Code",
    "Region",
    "Product ID",
    "Category",
    "Sub Category",
    "Product Name",
    "Sales",
    "Quantity",
    "Discount",
    "Profit",
    has_missing_value,
    has_invalid_value,
    has_outlier_value

FROM flagged
WHERE "Row ID" IS NOT NULL;
GO

SELECT *
FROM silver.encounters 
--=============================================================================

-- GOLD LAYER

IF OBJECT_ID('gold.FactSales', 'U') IS NOT NULL
    DROP TABLE gold.FactSales;
GO

IF OBJECT_ID('gold.dimCustomer', 'U') IS NOT NULL
    DROP TABLE gold.dimCustomer;
GO

IF OBJECT_ID('gold.dimDate', 'U') IS NOT NULL
    DROP TABLE gold.dimDate;
GO

IF OBJECT_ID('gold.dimProduct', 'U') IS NOT NULL
    DROP TABLE gold.dimProduct;
GO

IF OBJECT_ID('gold.dimLocation', 'U') IS NOT NULL
    DROP TABLE gold.dimLocation;
GO


CREATE TABLE gold.dimCustomer (
    CustomerKey INT IDENTITY(1,1) PRIMARY KEY,

    "Customer ID" NVARCHAR(255) NOT NULL,
    "Customer Name" NVARCHAR(255),
    "Segment" NVARCHAR(255),

    CONSTRAINT UQ_dimCustomer_CustomerID UNIQUE ("Customer ID")
);

GO

CREATE TABLE gold.dimDate (
    DateKey INT PRIMARY KEY,

FullDate DATE NOT NULL,
DayNumber INT,
    MonthNumber INT,
MonthName NVARCHAR(20),
    QuarterNumber INT,
    YearNumber INT,
    DayName NVARCHAR(20),
    IsWeekend BIT
);
GO

CREATE TABLE gold.dimProduct (
    ProductKey INT IDENTITY(1,1) PRIMARY KEY,
    "Product ID" NVARCHAR(255) NOT NULL,
    "Category" NVARCHAR(255),
    "Sub Category" NVARCHAR(255),
    "Product Name" NVARCHAR(255),

    CONSTRAINT UQ_dimProduct_ProductID
        UNIQUE ("Product ID")
);

GO

CREATE TABLE gold.dimLocation (
    LocationKey INT IDENTITY(1,1) PRIMARY KEY,
    "Country" NVARCHAR(255),
    "City" NVARCHAR(255),
    "State" NVARCHAR(255),
    "Postal Code" NVARCHAR(255),
    "Region" NVARCHAR(255)
);

GO
CREATE TABLE gold.FactSales (
    "Row ID" INT PRIMARY KEY,

    CustomerKey INT NOT NULL,
    DateKey INT NOT NULL,
    ProductKey INT NOT NULL,
    LocationKey INT NOT NULL,

    "Ship Mode" NVARCHAR(255),
    "Sales" DECIMAL(18,2),
    "Quantity" INT,
    "Discount" DECIMAL(5,2),
    "Profit" DECIMAL(18,2),

    CONSTRAINT FK_Fact_Customer
        FOREIGN KEY (CustomerKey)
        REFERENCES gold.dimCustomer(CustomerKey),

    CONSTRAINT FK_Fact_Date
        FOREIGN KEY (DateKey)
        REFERENCES gold.dimDate(DateKey),

    CONSTRAINT FK_Fact_Product
        FOREIGN KEY (ProductKey)
        REFERENCES gold.dimProduct(ProductKey),

    CONSTRAINT FK_Fact_Location
        FOREIGN KEY (LocationKey)
        REFERENCES gold.dimLocation(LocationKey)
);
GO


-- 1 DI CUSTOMER

INSERT INTO gold.dimCustomer
(
    "Customer ID",
    "Customer Name",
    "Segment"
)
SELECT DISTINCT
    "Customer ID",
    "Customer Name",
    "Segment"
FROM silver.encounters
WHERE has_invalid_value = 0
  AND "Customer ID" IS NOT NULL
  AND "Customer Name" IS NOT NULL
  AND NOT EXISTS
  (
      SELECT 1
      FROM gold.dimCustomer d
      WHERE d."Customer ID" = silver.encounters."Customer ID"
  );

GO

-- 2 DIMDATE

INSERT INTO gold.dimDate
(
    DateKey,
    FullDate,
    DayNumber,
    MonthNumber,
    MonthName,
    QuarterNumber,
    YearNumber,
    DayName,
    IsWeekend
)
SELECT DISTINCT
    CONVERT(INT, CONVERT(CHAR(8), CAST("Order Date" AS DATE), 112)) AS DateKey,

    CAST("Order Date" AS DATE) AS FullDate,

    DAY("Order Date") AS DayNumber,

    MONTH("Order Date") AS MonthNumber,

    DATENAME(MONTH, "Order Date") AS MonthName,

    DATEPART(QUARTER, "Order Date") AS QuarterNumber,

    YEAR("Order Date") AS YearNumber,

    DATENAME(WEEKDAY, "Order Date") AS DayName,

    CASE
        WHEN DATEPART(WEEKDAY, "Order Date") IN (1, 7)
        THEN 1
        ELSE 0
    END AS IsWeekend

FROM silver.encounters
WHERE has_invalid_value = 0
  AND "Order Date" IS NOT NULL
  AND NOT EXISTS
  (
      SELECT 1
      FROM gold.dimDate d
      WHERE d.DateKey =
            CONVERT(INT, CONVERT(CHAR(8), CAST(silver.encounters."Order Date" AS DATE), 112))
  );
GO

-- 3 DIM PROUCT

INSERT INTO gold.dimProduct
(
    "Product ID",
    "Category",
    "Sub Category",
    "Product Name"
)
SELECT
    "Product ID",
    "Category",
    "Sub Category",
    "Product Name"
FROM
(
    SELECT
        "Product ID",
        "Category",
        "Sub Category",
        "Product Name",

        ROW_NUMBER() OVER (
            PARTITION BY "Product ID"
            ORDER BY "Row ID"
        ) AS rn

    FROM silver.encounters
    WHERE has_invalid_value = 0
      AND "Product ID" IS NOT NULL
) AS Temp
WHERE rn = 1;
GO

-- 4 DIMLOCATION

INSERT INTO gold.dimLocation
(
    "Country",
    "City",
    "State",
    "Postal Code",
    "Region"
)
SELECT DISTINCT
    "Country",
    "City",
    "State",
    "Postal Code",
    "Region"
FROM silver.encounters
WHERE has_invalid_value = 0
  AND "Country" IS NOT NULL
  AND "City" IS NOT NULL
  AND "State" IS NOT NULL
  AND "Postal Code" IS NOT NULL
  AND "Region" IS NOT NULL
  AND NOT EXISTS
  (
      SELECT 1
      FROM gold.dimLocation d
      WHERE d."Country" = silver.encounters."Country"
        AND d."City" = silver.encounters."City"
        AND d."State" = silver.encounters."State"
        AND d."Postal Code" = silver.encounters."Postal Code"
        AND d."Region" = silver.encounters."Region"
  );
GO

-- 5 FACT SALES

INSERT INTO gold.FactSales
(
    "Row ID",
    CustomerKey,
    DateKey,
    ProductKey,
    LocationKey,
    "Ship Mode",
    "Sales",
    "Quantity",
    "Discount",
    "Profit"
)
SELECT
    s."Row ID",

    c.CustomerKey,

    CONVERT(
        INT,
        CONVERT(CHAR(8), CAST(s."Order Date" AS DATE), 112)
    ) AS DateKey,

    p.ProductKey,

    l.LocationKey,

    s."Ship Mode",

    s."Sales",

    s."Quantity",

    s."Discount",

    s."Profit"

FROM silver.encounters s

INNER JOIN gold.dimCustomer c
    ON c."Customer ID" = s."Customer ID"

INNER JOIN gold.dimProduct p
    ON p."Product ID" = s."Product ID"

INNER JOIN gold.dimDate d
    ON d.DateKey =
       CONVERT(
           INT,
           CONVERT(CHAR(8), CAST(s."Order Date" AS DATE), 112)
       )

INNER JOIN gold.dimLocation l
    ON l."Country" = s."Country"
   AND l."City" = s."City"
   AND l."State" = s."State"
   AND l."Postal Code" = s."Postal Code"
   AND l."Region" = s."Region"

WHERE s.has_invalid_value = 0
  AND s."Row ID" IS NOT NULL
  AND NOT EXISTS
  (
      SELECT 1
      FROM gold.FactSales f
      WHERE f."Row ID" = s."Row ID"
  );
GO
--============================================================================================
  SELECT *
  from gold.dimCustomer; --629 rows

    SELECT *
  from gold.dimDate; --720 rows

    SELECT *
  from gold.dimLocation ;--195 rows

    SELECT *
  from gold.dimProduct; --1,310 rows

    SELECT *
  from gold.FactSales; --2,323 rows



--===================================================================================
-- 1 Which Customer Segments have the highest average Sales per transaction?

SELECT 
    dc.Segment AS "Segment Name",
    AVG(fs.Sales) AS "Average Sales",
    SUM(fs.Quantity) AS "Total Quantity"
FROM gold.FactSales AS fs
LEFT JOIN gold.dimCustomer AS dc
ON  fs.CustomerKey=dc.CustomerKey
GROUP BY dc.Segment
ORDER BY "Average Sales" DESC;
GO

-- 2. Which Categories have the highest average Quantity?
SELECT 
    dp.Category AS "Category Name",
    AVG(fs.Quantity) AS "Average Quantity",
    SUM(fs.Quantity) AS "Total Quantity"
FROM gold.FactSales AS fs
LEFT JOIN gold.DimProduct AS dp
    ON fs.ProductKey = dp.ProductKey
GROUP BY dp.Category
ORDER BY AVG(fs.Quantity) DESC;
GO

-- 3. Which Products have the highest total Quantity sold?

SELECT dp."Product Name",SUM(fs.Quantity) AS "total Quantity"
FROM gold.FactSales AS fs
LEFT JOIN gold.DimProduct AS dp
    ON fs.ProductKey = dp.ProductKey
GROUP BY "Product Name"
ORDER BY "total Quantity" DESC;
GO


-- 4. Which States have generated Sales above 50,000
--    but Profit below 5,000?


SELECT dl.State,SUM(fs.Sales) AS "Total Sales",SUM(fs.Profit) AS "Total Profit"
FROM gold.FactSales AS fs
LEFT JOIN gold.dimLocation AS dl
ON fs.LocationKey=dl.LocationKey
GROUP BY dl.State
HAVING SUM(fs.Sales)>50000 AND SUM(fs.Profit)<5000
ORDER BY "Total Sales" DESC;
GO


-- 5 Which products have generated more total sales than the average total sales of all products?

SELECT dp.[Product Name],SUM(fs.Sales) AS [Total Sales]

FROM gold.FactSales AS fs
LEFT JOIN gold.DimProduct AS dp
    ON fs.ProductKey = dp.ProductKey
GROUP BY dp.[Product Name]

HAVING SUM(fs.Sales) > (
    SELECT AVG(TotalSales)
    FROM (
        SELECT SUM(fs2.Sales) AS TotalSales
        FROM gold.FactSales AS fs2
        LEFT JOIN gold.DimProduct AS dp2
            ON fs2.ProductKey = dp2.ProductKey
        GROUP BY dp2.[Product Name]
    ) AS ProductSales
)
ORDER BY [Total Sales] DESC;
GO

-- 6 Which categories have a total profit above the average total profit of all categories?

WITH CategoryProfit AS (
    SELECT dp.Category, SUM(fs.Profit) AS TotalProfit

    FROM gold.FactSales AS fs
    LEFT JOIN gold.DimProduct AS dp
        ON fs.ProductKey = dp.ProductKey
    GROUP BY dp.Category
)

SELECT Category,TotalProfit
FROM CategoryProfit
WHERE TotalProfit > (
    select AVG(TotalProfit)
    from CategoryProfit
)
ORDER BY TotalProfit DESC;
GO


-- 7 What are the top 3 products by total sales within each category?

WITH ProductSales AS (
    SELECT dp.Category , dp.[Product Name] , SUM(fs.Sales) AS TotalSales

    FROM gold.FactSales AS fs
    LEFT JOIN gold.DimProduct AS dp
        ON fs.ProductKey = dp.ProductKey
    GROUP BY  dp.Category,dp.[Product Name]
),

RankedProducts AS(
    SELECT Category,[Product Name],TotalSales,ROW_NUMBER() OVER (
            PARTITION BY Category
            ORDER BY TotalSales DESC
        ) AS ProductRank

    FROM ProductSales)

SELECT
    Category,
    [Product Name],
    TotalSales,
    ProductRank
FROM RankedProducts
WHERE ProductRank <= 3
ORDER BY Category, ProductRank;
GO

-- 8 For each state, what is the difference between its total sales and the previous state's total sales when states are ordered by total sales?


WITH StateSales AS (
    SELECT dl.[State] AS "State Name",SUM(fs.Sales) AS TotalSales

    FROM gold.FactSales AS fs
    LEFT JOIN gold.dimLocation AS dl
        ON fs.LocationKey = dl.LocationKey
    GROUP BY dl.[State]
),
RankedState AS(
    SELECT "State Name",TotalSales,LAG(TotalSales) Over (
        ORDER BY TotalSales DESC
    ) AS PreviousSales

    from StateSales
)
SELECT
    "State Name",
    TotalSales,
    PreviousSales,
    TotalSales - PreviousSales AS SalesDifference
FROM RankedState
ORDER BY TotalSales DESC;
GO


-- 9 Which products have the highest profit margin within each category?

WITH TOP_Product As(

SELECT dp.Category , dp.[Product Name],Sum(fs.Profit) AS "Total Profit",Sum(fs.Sales) as "Total Sales", Sum(fs.Profit)/Sum(fs.Sales)  AS[Profit Margin]
from gold.FactSales as fs
LEFT JOIN gold.dimProduct as dp
on fs.ProductKey=dp.ProductKey
GROUP BY dp.[Product Name],dp.Category
),

RANK AS(
    SELECT [Product Name],[Category],[Total Profit],[Total Sales],[Profit Margin],ROW_NUMBER() OVER (
    PARTITION BY Category
    ORDER BY [Profit Margin] DESC) AS ROWRANK
    FROM TOP_Product )

SELECT [Product Name],[Category],[Total Profit],[Total Sales],[Profit Margin]
    From RANK
    WHERE ROWRANK =1
    ORDER BY [Profit Margin] DESC;
GO

-- 10 Which customer segments have a higher total profit than the average total profit across all customer segments?


WITH  Customer_segments AS(
    SELECT dc.Segment,SUM(fs.Profit) As [Total Profit]
    FROM gold.FactSales as fs
    LEFT Join gold.dimCustomer as dc
    on fs.CustomerKey=dc.CustomerKey 
    GROUP BY dc.Segment)
,
Average_Profit AS(
    SELECT Segment,[Total Profit], AVG([Total Profit]) OVER () AS AvgProfit
    from Customer_segments

)
SELECT *
FROM Average_Profit
WHERE [Total Profit] > AvgProfit;
GO