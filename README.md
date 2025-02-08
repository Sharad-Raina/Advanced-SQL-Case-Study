# Retail Database Analysis - SQL Queries

## Overview
This project involves analyzing a retail database using SQL queries. The dataset consists of three tables: `Customer`, `prod_cat_info`, and `Transactions`. The SQL queries cover various aspects of data analysis, including data cleaning, summarization, and in-depth insights into customer behavior, product performance, and sales trends.

<img width="537" alt="Screenshot 2025-02-07 at 7 29 17 PM" src="https://github.com/user-attachments/assets/9c93622d-6442-4805-b93d-0b42eaad1cc9" />


## Data Tables
- **Customer**: Contains customer details such as `customer_Id`, `DOB`, `Gender`, and `city_code`.
- **prod_cat_info**: Contains product category and sub-category information.
- **Transactions**: Contains transaction details including `transaction_id`, `cust_id`, `tran_date`, `Store_type`, `total_amt`, and `qty`.

## Key Data Analysis Queries

### 1. Data Summary
#### Total number of rows in each table:
```sql
SELECT COUNT(customer_Id) FROM Customer
UNION ALL
SELECT COUNT(prod_cat_code) FROM prod_cat_info
UNION ALL
SELECT COUNT(transaction_id) FROM Transactions;
```

#### Transactions that have a return:
```sql
SELECT COUNT(total_amt) AS [Transactions Returned] FROM Transactions
WHERE total_amt < 0;
```

#### Date format correction:
```sql
SELECT CAST(Customer.DOB AS date) AS [DATE OF BIRTH] FROM Customer;
```

### 2. Transaction Date Range
```sql
SELECT MIN(tran_date) AS MIN_DATE, MAX(tran_date) AS MAX_DATE FROM Transactions;
```
```sql
SELECT DATEDIFF(YEAR, MIN(tran_date), MAX(tran_date)) AS [YEAR DIFFERENCE],
       DATEDIFF(MONTH, MIN(tran_date), MAX(tran_date)) AS [MONTH DIFFERENCE],
       DATEDIFF(DAY, MIN(tran_date), MAX(tran_date)) AS [DIFFERENCE IN DAYS]
FROM Transactions;
```

### 3. Product and Sales Analysis
#### Most frequently used transaction channel:
```sql
SELECT Store_type, COUNT(Store_type) AS [NO. OF TIMES USED]
FROM Transactions
GROUP BY Store_type
ORDER BY COUNT(Store_type) DESC;
```

#### Count of Male and Female customers:
```sql
SELECT Gender, COUNT(Gender) AS TOTAL_PEOPLE
FROM Customer
WHERE Gender IN ('M','F')
GROUP BY Gender;
```

#### City with the maximum number of customers:
```sql
SELECT TOP 1 city_code, COUNT(customer_Id) AS [MAX CUSTOMERS]  
FROM Customer
GROUP BY city_code
ORDER BY COUNT(customer_Id) DESC;
```

#### Maximum quantity of products ever ordered:
```sql
SELECT TOP 1 prod_cat_code, SUM(qty) AS [MAX QTY]
FROM Transactions
GROUP BY prod_cat_code
ORDER BY [MAX QTY] DESC;
```

### 4. Revenue Analysis
#### Net total revenue for Electronics and Books:
```sql
SELECT prod_cat_info.prod_cat, SUM(Transactions.total_amt) AS [Net Total Revenue]
FROM Transactions
JOIN prod_cat_info ON Transactions.prod_cat_code = prod_cat_info.prod_cat_code
WHERE prod_cat IN ('electronics','books')
GROUP BY prod_cat_info.prod_cat;
```

#### Revenue from Electronics and Clothing in Flagship Stores:
```sql
SELECT prod_cat_info.prod_cat, SUM(Transactions.total_amt) AS total_revenue
FROM Transactions
JOIN prod_cat_info ON Transactions.prod_cat_code = prod_cat_info.prod_cat_code
WHERE prod_cat_info.prod_cat IN ('electronics','clothing') AND Transactions.Store_type = 'Flagship store'
GROUP BY prod_cat_info.prod_cat;
```

#### Revenue from Male customers in Electronics category:
```sql
SELECT prod_cat_info.prod_subcat, SUM(Transactions.total_amt) AS [Total Revenue]
FROM prod_cat_info
JOIN Transactions ON prod_cat_info.prod_cat_code = Transactions.prod_cat_code
JOIN Customer ON Transactions.cust_id = Customer.customer_Id
WHERE prod_cat_info.prod_cat = 'electronics' AND Customer.Gender = 'M'
GROUP BY prod_cat_info.prod_subcat;
```

### 5. Customer and Sales Insights
#### Customers aged 25-35 contributing to revenue in the last 30 days:
```sql
SELECT Customer_Id, SUM(total_amt) AS Total_Revenue
FROM (
    SELECT *, DATEDIFF(YEAR, a.DOB, GETDATE()) AS Age
    FROM Customer a
    INNER JOIN Transactions b ON a.customer_Id = b.cust_id
) AS X
WHERE Age BETWEEN 25 AND 35 AND tran_date > (SELECT DATEADD(DAY,-30, MAX(tran_date)) FROM Transactions)
GROUP BY Customer_Id;
```

#### Store-type selling maximum products:
```sql
SELECT TOP 1 Store_Type, ROUND(SUM(total_amt),2) AS Total_Sales, SUM(qty) AS Quantity_Sold
FROM Transactions
GROUP BY Store_type
ORDER BY SUM(total_amt) DESC, SUM(qty) DESC;
```

#### Product categories with average revenue above overall average:
```sql
SELECT a.prod_cat AS Product_Category, AVG(total_amt) AS Average_Revenue
FROM prod_cat_info a
JOIN Transactions b ON a.prod_cat_code = b.prod_cat_code
GROUP BY a.prod_cat
HAVING AVG(total_amt) > (SELECT AVG(total_amt) FROM Transactions);
```

## Skills Demonstrated
- **SQL Query Optimization**: Use of `JOIN`, `GROUP BY`, `HAVING`, `ORDER BY`, and `UNION` for efficient data retrieval.
- **Data Cleaning and Formatting**: Converting date formats and filtering records.
- **Descriptive and Inferential Analysis**: Finding trends in customer behavior, product sales, and revenue generation.
- **Aggregations and Window Functions**: Summarizing data using `SUM()`, `AVG()`, `COUNT()`, and `DATEDIFF()`.
- **Business Insights**: Understanding customer purchase patterns, revenue distribution, and returns analysis.

## Conclusion
This SQL analysis provides key insights into sales performance, customer demographics, and product trends. It demonstrates the power of SQL in handling real-world data and making data-driven business decisions. The results can be used to optimize marketing strategies, improve product offerings, and enhance customer engagement.

---


