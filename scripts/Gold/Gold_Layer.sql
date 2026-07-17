/* =====================================================================
   PROJECT   : Data Warehouse - Gold Layer Build
   PURPOSE   : Integrate customer, product, and sales data from the
               Silver layer into business-ready Gold layer views
               (Star Schema: dim_customers, dim_product, fact_sales)
   ===================================================================== */


/* ---------------------------------------------------------------------
   SECTION 1: Source Data Exploration
   Quick look at the raw customer info table in the Silver layer
   before any transformation is applied.
   --------------------------------------------------------------------- */
SELECT * FROM silver.crm_cust_info;


/* ---------------------------------------------------------------------
   SECTION 2: Join Customer Info with Related ERP Tables
   Combines CRM customer master data with ERP demographic (birthdate,
   gender) and location (country) data using the customer key (cst_key)
   as the common join column.
   --------------------------------------------------------------------- */
SELECT 
    ci.cst_id,
    ci.cst_key,
    ci.cst_firstname,
    ci.cst_lastname,
    ci.cst_material_status,
    ci.cst_gndr,
    ca.bdate,
    ca.gen,
    c1.cntry
FROM silver.crm_cust_info AS ci
LEFT JOIN silver.erp_cust_az12 AS ca
    ON ci.cst_key = ca.cid
LEFT JOIN silver.erp_loc_a101 AS c1
    ON ci.cst_key = c1.cid;


/* ---------------------------------------------------------------------
   SECTION 3: Data Quality Check - Duplicate Validation
   Verifies that the join above does not introduce duplicate rows per
   customer (cst_id). A count greater than 1 indicates a fan-out caused
   by multiple matching records in one of the joined tables.
   --------------------------------------------------------------------- */
SELECT cst_id, COUNT(*) 
FROM (
    SELECT 
        ci.cst_id,
        ci.cst_key,
        ci.cst_firstname,
        ci.cst_lastname,
        ci.cst_material_status,
        ca.bdate,
        ca.gen,
        c1.cntry
    FROM silver.crm_cust_info AS ci
    LEFT JOIN silver.erp_cust_az12 AS ca
        ON ci.cst_key = ca.cid
    LEFT JOIN silver.erp_loc_a101 AS c1
        ON ci.cst_key = c1.cid
) t 
GROUP BY cst_id
HAVING COUNT(*) > 1;

-- Reference lookup: raw location table used in the join above
SELECT * FROM silver.erp_loc_a101;


/* ---------------------------------------------------------------------
   SECTION 4: Data Integration - Resolve Gender Conflicts & N/A Values
   The CRM system is treated as the primary (trusted) source for gender.
   If CRM gender is missing/unknown ('N/A'), the ERP gender value is
   used as a fallback; if both are missing, the value defaults to 'N/A'.
   Column names are also standardized to business-friendly aliases.
   --------------------------------------------------------------------- */
SELECT 
    ci.cst_id             AS customer_id,
    ci.cst_key             AS customer_number,
    ci.cst_firstname        AS first_name,
    ci.cst_lastname          AS last_name,
    c1.cntry                  AS country,
    ci.cst_material_status     AS marital_status,
    CASE 
        WHEN ci.cst_gndr != 'N/A' THEN ci.cst_gndr   -- Trust CRM gender first
        ELSE COALESCE(ca.gen, 'N/A')                  -- Fallback to ERP, else 'N/A'
    END AS gender,
    ca.bdate                  AS birthdate,
    ci.cst_create_date         AS create_date
FROM silver.crm_cust_info AS ci
LEFT JOIN silver.erp_cust_az12 AS ca
    ON ci.cst_key = ca.cid
LEFT JOIN silver.erp_loc_a101 AS c1
    ON ci.cst_key = c1.cid;


/* ---------------------------------------------------------------------
   SECTION 5: Generate Surrogate Key
   Adds a system-generated surrogate key (customer_key) using
   ROW_NUMBER(), ordered by customer_id. This decouples the Gold layer
   from source-system keys and is required for dimensional modeling.
   --------------------------------------------------------------------- */
SELECT 
    ROW_NUMBER() OVER (ORDER BY cst_id) AS customer_key,
    ci.cst_key             AS customer_number,
    ci.cst_firstname        AS first_name,
    ci.cst_lastname          AS last_name,
    c1.cntry                  AS country,
    ci.cst_material_status     AS marital_status,
    CASE 
        WHEN ci.cst_gndr != 'N/A' THEN ci.cst_gndr
        ELSE COALESCE(ca.gen, 'N/A')
    END AS gender,
    ca.bdate                  AS birthdate,
    ci.cst_create_date         AS create_date
FROM silver.crm_cust_info AS ci
LEFT JOIN silver.erp_cust_az12 AS ca
    ON ci.cst_key = ca.cid
LEFT JOIN silver.erp_loc_a101 AS c1
    ON ci.cst_key = c1.cid;


/* ---------------------------------------------------------------------
   SECTION 6: Create Gold Layer View - dim_customers
   Persists the finalized, cleaned, and enriched customer dataset as a
   reusable dimension view for downstream reporting and analytics.
   --------------------------------------------------------------------- */
CREATE VIEW gold.dim_customers AS
SELECT 
    ROW_NUMBER() OVER (ORDER BY cst_id) AS customer_key,
    ci.cst_key             AS customer_number,
    ci.cst_firstname        AS first_name,
    ci.cst_lastname          AS last_name,
    c1.cntry                  AS country,
    ci.cst_material_status     AS marital_status,
    CASE 
        WHEN ci.cst_gndr != 'N/A' THEN ci.cst_gndr
        ELSE COALESCE(ca.gen, 'N/A')
    END AS gender,
    ca.bdate                  AS birthdate,
    ci.cst_create_date         AS create_date
FROM silver.crm_cust_info AS ci
LEFT JOIN silver.erp_cust_az12 AS ca
    ON ci.cst_key = ca.cid
LEFT JOIN silver.erp_loc_a101 AS c1
    ON ci.cst_key = c1.cid;


/* ---------------------------------------------------------------------
   SECTION 7: Validate the dim_customers View
   Sanity checks to confirm the view was created successfully and that
   the gender field only contains expected/clean values.
   --------------------------------------------------------------------- */
SELECT * FROM gold.dim_customers;

SELECT DISTINCT gender FROM gold.dim_customers;


/* ---------------------------------------------------------------------
   SECTION 8: Create Gold Layer View - dim_product
   Builds the product dimension by joining CRM product master data with
   the ERP product category table. Only currently active products are
   included (prd_end_dt IS NULL excludes historical/expired records).
   A surrogate key (product_key) is generated for consistency with the
   customer dimension.
   --------------------------------------------------------------------- */
CREATE VIEW gold.dim_product AS 
SELECT 
    ROW_NUMBER() OVER (ORDER BY pn.prd_start_dt, pn.prd_key) AS product_key,
    pn.prd_id      AS Product_id,
    pn.cat_id      AS category_id,
    pn.prd_key     AS Product_number,
    pn.prd_nm      AS product_name,
    pn.prd_cost    AS product_cost,
    pn.prd_line    AS product_line,
    pn.prd_start_dt AS start_date
FROM silver.crm_prd_info AS pn
LEFT JOIN silver.erp_px_cat_g1v2 AS eg
    ON pn.cat_id = eg.id
WHERE prd_end_dt IS NULL;  -- Filter to active (non-historical) products only


/* ---------------------------------------------------------------------
   SECTION 9: Create Gold Layer View - fact_sales
   Builds the central fact table by joining sales transaction details
   with the dim_product and dim_customers dimension views, providing
   a fully denormalized, analysis-ready sales dataset.
   --------------------------------------------------------------------- */
CREATE VIEW gold.fact_sales AS
SELECT 
    sd.sls_ord_num    AS order_number,
    sd.sls_prd_key,
    sd.sls_cust_id,
    sd.sls_order_dt   AS order_date,
    sd.sls_ship_dt    AS ship_date,
    sd.sls_due_dt     AS due_date,
    sd.sls_sales_dt   AS sales_amount,
    sd.sls_quantity   AS quantity,
    sd.sls_price      AS price
FROM silver.crm_sales_details AS sd
LEFT JOIN gold.dim_product AS pr
    ON sd.sls_prd_key = pr.Product_number
LEFT JOIN gold.dim_customers AS ds
    ON sd.sls_cust_id = ds.customer_key;


/* ---------------------------------------------------------------------
   SECTION 10: Validate Source and Gold Layer Outputs
   Basic checks comparing raw source data against the final Gold views
   to confirm the transformation pipeline produced expected results.
   --------------------------------------------------------------------- */
SELECT * FROM silver.crm_sales_details;

SELECT * FROM gold.dim_customers;

SELECT * FROM gold.fact_sales;


/* ---------------------------------------------------------------------
   SECTION 11: Date Function Exploration (Bronze Layer)
   Demonstrates various date functions (YEAR, MONTH, DAY, DATENAME,
   DATETRUNC) applied to the raw customer creation date in the Bronze
   layer. Useful for understanding date granularity options before
   deciding how dates should be handled downstream.
   --------------------------------------------------------------------- */
SELECT 
    YEAR(cst_create_date),
    MONTH(cst_create_date),
    DAY(cst_create_date),
    DATENAME(MONTH, cst_create_date),
    DATETRUNC(MONTH, cst_create_date)  
FROM bronze.crm_cust_info;


/* ---------------------------------------------------------------------
   SECTION 12: Ad-hoc Sales Analysis
   Exploratory queries against the Silver sales details table:
   - Full table preview
   - Count of sales records per product for the month of February
   - Extraction of order month for further trend analysis
   --------------------------------------------------------------------- */
SELECT * FROM silver.crm_sales_details;

-- Count of orders per product key, filtered to February order dates
SELECT  
    sls_prd_key, 
    COUNT(*) 
FROM silver.crm_sales_details
WHERE MONTH(sls_order_dt) = 2
GROUP BY sls_prd_key;

-- Extract order month for all sales records
SELECT MONTH(sls_order_dt) 
FROM silver.crm_sales_details;
