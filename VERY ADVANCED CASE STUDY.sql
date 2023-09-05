select * from Customer
select * from prod_cat_info
select * from Transactions

--1. What is the total number of rows in each of the 3 tables in the database?

select count (Customer.customer_Id) from Customer
union all
select count (prod_cat_code) from prod_cat_info
union all
select COUNT (Transactions.transaction_id) from Transactions

--2. What is the total number of transactions that have a return?

select count(total_amt) as [Transactions Returned] from Transactions
where total_amt < 0 

--3. As you would have noticed, the dates provided across the datasets are not in a correct format.
--As first steps, pls convert the date variables into valid date formats before proceeding ahead.

select cast (Customer.DOB as varchar) as DOB from Customer
SELECT CAST(Customer.DOB AS date) AS [DATE OF BIRTH] FROM Customer


--4. What is the time range of the transaction data available for analysis?
--Show the output in number of days, months and years simultaneously in different columns.

SELECT MIN ( Transactions.tran_date) AS MIN_DATE FROM Transactions
SELECT MAX( Transactions.tran_date) AS MAX_DATE FROM Transactions

SELECT DATEDIFF (YEAR,  MIN ( Transactions.tran_date),MAX( Transactions.tran_date) ) AS [YEAR DIFFERENCE],

	  DATEDIFF (MONTH,  MIN ( Transactions.tran_date),MAX( Transactions.tran_date) ) AS [MONTH DIFFERENCE],
	  
	  DATEDIFF (DAY,  MIN ( Transactions.tran_date),MAX( Transactions.tran_date) ) AS [ DIFFERENCE IN DAYS]
	  
	  FROM Transactions

	  Store_type = 'TELESHOP'
--  5. Which product category does the sub-category “DIY” belong to?

SELECT prod_cat FROM prod_cat_info
WHERE prod_subcat = 'DIY'

								-- DATA ANALYSIS

--1. Which channel is most frequently used for transactions?

SELECT  MAX( Transactions.Store_type) AS [MOST USED CHANNEL],COUNT (Transactions.Store_type) AS [NO. OF TIMES CHANNEL USED] FROM Transactions
WHERE Store_type IN (  SELECT MAX( Transactions.Store_type) FROM Transactions)  

--2. What is the count of Male and Female customers in the database?

SELECT Customer.Gender,  COUNT(Customer.Gender) AS TOTAL_PEOPLE FROM Customer WHERE Gender IN ('M','F') GROUP BY Gender

--3. From which city do we have the maximum number of customers and how many?

select top 1  city_code ,  COUNT( Customer.customer_Id)as [max. no. of customers]  from Customer
 group by city_code

 
 --4. How many sub-categories are there under the Books category?

 select COUNT(prod_subcat) as [total subcategories] from prod_cat_info
 where prod_cat = 'books' 

 --5. What is the maximum quantity of products ever ordered?

 select top 1 prod_cat_code  , sum (qty) as [max qty] from Transactions
 group by prod_cat_code
 order by [max qty]desc


 --6. What is the net total revenue generated in categories Electronics and Books?

 select prod_cat_info.prod_cat ,SUM( Transactions.total_amt) [Net Total Revenue] from Transactions
 join prod_cat_info on Transactions.prod_cat_code = prod_cat_info.prod_cat_code
 where prod_cat in ('electronics','books')
 group by prod_cat


 --7. How many customers have >10 transactions with us, excluding returns?

 select  Transactions.cust_id ,COUNT( Transactions.cust_id) as total_customers from Transactions
 group by cust_id
 having COUNT( transaction_id)>10 
 order by COUNT( transaction_id) desc 

 
 select  COUNT( Transactions.transaction_id) as total_customers from Transactions
 having COUNT( transaction_id)>10 
 order by COUNT( transaction_id) desc 


 select COUNT(Transactions.cust_id) from Transactions 
 where cust_id = 269449

 --8. What is the combined revenue earned from the “Electronics” & “Clothing” categories, from “Flagship stores”?

 select prod_cat_info.prod_cat , SUM(Transactions.total_amt) as total_revenue from Transactions
 join prod_cat_info on Transactions.prod_cat_code = prod_cat_info.prod_cat_code
 where prod_cat_info.prod_cat in ('electronics','clothing') and Transactions.Store_type = 'Flagship store'
 group by prod_cat_info.prod_cat


 --9. What is the total revenue generated from “Male” customers in “Electronics” category? Output should display total revenue by prod sub-cat

 select prod_cat_info.prod_subcat , SUM ( Transactions.total_amt) as [total revenue generated] from prod_cat_info
 join Transactions on prod_cat_info.prod_cat_code = Transactions.prod_cat_code
  join Customer on Transactions.cust_id = Customer.customer_Id
 where prod_cat_info.prod_cat = 'electronics' and Customer.Gender = 'M'
 group by prod_cat_info.prod_subcat


--10.What is percentage of sales and returns by product sub category; display only top 5 sub categories in terms of sales?


  select top 5
     P.prod_subcat as Subcategory ,
      Round(SUM(cast( case when T.Qty > 0 then T.Qty else 0 end as float)),2)[Sales]  , 
     Round(SUM(cast( case when T.Qty < 0 then T.Qty   else 0 end as float)),2) [Returns] ,
    Round(SUM(cast( case when T.Qty > 0 then T.Qty else 0 end as float)),2)
                 - Round(SUM(cast( case when T.Qty < 0 then T.Qty   else 0 end as float)),2)[Total_Qty],
    ((Round(SUM(cast( case when T.Qty < 0 then T.Qty  else 0 end as float)),2))/
                  (Round(SUM(cast( case when T.Qty > 0 then T.Qty else 0 end as float)),2)
                 - Round(SUM(cast( case when T.Qty < 0 then T.Qty   else 0 end as float)),2)))*100 as [Return_%],
    ((Round(SUM(cast( case when T.Qty > 0 then T.Qty  else 0 end as float)),2))/
                  (Round(SUM(cast( case when T.Qty > 0 then T.Qty else 0 end as float)),2)
                 - Round(SUM(cast( case when T.Qty < 0 then T.Qty   else 0 end as float)),2)))*100 as [Sales_%]
    from Transactions as T
    INNER JOIN prod_cat_info as P ON T.prod_subcat_code = P.prod_sub_cat_code
    group by P.prod_subcat
    order by [Sales_%] desc

	

--11.	For all customers aged between 25 to 35 years find what is the net total revenue generated by these consumers in last 30 days of transactions from max transaction date available in the data?

select Customer_Id ,SUM(total_amt) as Total_Revenue
from
(select *,DATEDIFF(year,a.DOB,GETDATE()) as Age from Customer a
inner join 
Transactions b
on a.customer_Id = b.cust_id) as X
where Age between 25 and 35 and tran_date > (select dateadd(DAY,-30, MAX(tran_date))from Transactions)
group by Customer_Id

--12.	Which product category has seen the max value of returns in the last 3 months of transactions?

select top 1 p.Prod_Cat , COUNT(qty) as Number_Of_Returns
From transactions as t 
inner join prod_cat_info as p 
on t.prod_subcat_code=p.prod_sub_cat_code and t.prod_cat_code = p.prod_cat_code
where total_amt < 0 and tran_date > (select dateadd(month,-3, MAX(tran_date))from Transactions)
--and tran_date < (select MAX(tran_date) from Transactions)
group by p.prod_cat
order by NUMBER_OF_RETURNS desc

--13.	Which store-type sells the maximum products; by value of sales amount and by quantity sold?

select top 1 Store_Type, round(SUM(total_amt),2)as Total_Sales , SUM(qty) as Quantity_Sold from Transactions
group by Store_type
order by 
SUM(total_amt) desc, SUM(qty) desc

--14.	What are the categories for which average revenue is above the overall average.

select a.prod_cat as Product_Category , AVG(total_amt) as Average_Revenue
from prod_cat_info a
inner join Transactions b
on a.prod_cat_code=b.prod_cat_code
and a.prod_sub_cat_code = b.prod_subcat_code
group by a.prod_cat
having  AVG(total_amt) > (select avg(total_amt) from Transactions)

--15.	Find the average and total revenue by each subcategory for the categories which are among top 5 categories in terms of quantity sold.


select c.prod_cat as Product_Catrgory,c.prod_subcat as Product_Subcategory,avg(d.total_Amt) as Average_Amount ,sum(d.total_amt) as Total_Amount
from prod_cat_info  c
inner join Transactions d 
on c.prod_cat_code=d.prod_cat_code
and c.prod_sub_cat_code = d.prod_subcat_code
where c.prod_cat in ( select top 5 a.prod_cat -- This subquery is written to find the top 5 CATEGORIES IN TERMS OF QTY SOLD 
from prod_cat_info a
inner join Transactions b
on a.prod_cat_code=b.prod_cat_code
and a.prod_sub_cat_code = b.prod_subcat_code
group by a.prod_cat
order by sum(b.QTY) desc )
group by c.prod_subcat,c.prod_cat

