-- Creating the customer_churn table to store customer demographics, service details, 
-- billing information, and churn status. This table forms the foundation for all 
-- further cleaning, exploration, and churn analysis.

CREATE TABLE customer_churn 
(
customerID numeric unique, 
gender varchar(20),
SeniorCitizen boolean,
Partner	boolean,
Dependents boolean,
tenure integer,
PhoneService boolean,
MultipleLines varchar(30),
InternetService varchar(30),
OnlineSecurity varchar(30),
OnlineBackup varchar(30),
DeviceProtection varchar(30),
TechSupport varchar(30),
Contract varchar(30),
PaperlessBilling boolean,
PaymentMethod varchar(40),
MonthlyCharges decimal,
TotalCharges decimal,
Churn boolean
)

select * from customer_churn limit 10;

---- Modify customerID to VARCHAR(15) to correctly store ID values as text instead of numeric.

alter table customer_churn 
alter column customerID type varchar(15)

--------------------------------
-- STEP 1 : DATA CLEANING
--------------------------------

-- Finding null values

select *
from customer_churn 
where (customerid, gender, seniorcitizen,partner, dependents, tenure, phoneservice, multiplelines, 
       internetservice, onlinesecurity, onlinebackup, deviceprotection, techsupport, contract,
	   paperlessbilling, paymentmethod, monthlycharges, totalcharges, churn)
is null

-- Finding duplicate values

select * 
from 
(
select *,
row_number () over(partition by customerid) as rn
from customer_churn
)
where rn > 1   --- no duplicates are found

--count of rows

select count(customerID) as total_rows
from customer_churn


--------------------------------
--- STEP 2 : DATA EXPLORATION
--------------------------------

--Q)Write a query to count how many customers are in the dataset.

select count(customerID) as total_rows
from customer_churn

--Q)Display all unique contract types.

SELECT contract
FROM customer_churn
GROUP BY contract;

--Q)Find the number of all unique contract types.

SELECT contract, 
count(contract) as contract_type_count
FROM customer_churn
GROUP BY contract

--Q)Find the number of customers who have churned vs. not churned.

SELECT 
COUNT(churn) FILTER (WHERE churn = true) as churned_customer_count,
COUNT(churn) FILTER (WHERE churn = false) as not_churned_customer_count
FROM customer_churn

--Q)Find the number of churned customers based on unique contract types.

SELECT contract, 
count(contract) as contract_type_count,
COUNT(churn) FILTER (WHERE churn = true) as churned_customer_count
FROM customer_churn
GROUP BY contract


--Q) Retrieve the list of customers who have monthly charges greater than 100.

SELECT customerid, monthlycharges
FROM customer_churn
WHERE monthlycharges > 100

--Q) Max monthly charge and total charge

SELECT 
max(monthlycharges) as maximum_monthly_charge,
max(totalcharges) as maximum_total_charge
FROM customer_churn

--Q) customers conut of senior citizens compared to non-senior citizens?

SELECT 
COUNT(seniorcitizen) FILTER( WHERE seniorcitizen = true) AS senior_citizen,
COUNT(seniorcitizen) FILTER( WHERE seniorcitizen = false) AS non_senior_citizen
FROM customer_churn


-----------------------------------------------
-- STEP 3: EXPLORATORY DATA ANALYSIS (EDA)
-- Objective: Identify customer behaviours and factors
-- that significantly contribute to churn.
-----------------------------------------------

--Q)Find the number of customers who have churned vs. not churned.

SELECT 
COUNT(churn) FILTER (WHERE churn = true) as churned_customer_count,
COUNT(churn) FILTER (WHERE churn = false) as not_churned_customer_count
FROM customer_churn

--Q) Count of partnered customers who left the company

SELECT 
COUNT(churn) as churned_customers_who_are_with_partner
FROM customer_churn
WHERE partner = true AND churn = true

--Q) Count of dependents customers who left the company

SELECT 
COUNT(churn) as churned_customers_who_are_with_dependents
FROM customer_churn
WHERE dependents = true AND churn = true

--Q) Total number of customers who churned when they are with partner or dependent

SELECT 
COUNT(churn) FILTER( WHERE partner = true AND churn = true) as churned_customers_who_are_with_partner,
COUNT(churn) FILTER( WHERE dependents = true AND churn = true) as churned_customers_who_are_with_dependents
FROM customer_churn

--Q)What is the average monthly charge?

SELECT 
ROUND(AVG(monthlycharges),2) AS avg_monthly_charge
FROM customer_churn


--Q)What is the total monthly revenue generated (sum of MonthlyCharges)

SELECT 
ROUND(SUM(monthlycharges),2) AS total_monthly_revenue
FROM customer_churn


--Q)What is the distribution of MonthlyCharges (min, max, avg)?

SELECT 
ROUND(MIN(monthlycharges),2) AS min_monthly_charge,
ROUND(MAX(monthlycharges),2) AS max_monthly_charge,
ROUND(AVG(monthlycharges),2) AS avg_monthly_charge
FROM customer_churn

--Q) In which type of contract the customers are leaving more 

SELECT contract, 
COUNT(churn) FILTER( WHERE churn = true) AS total_churned_customers
FROM customer_churn
GROUP BY contract
ORDER BY total_churned_customers DESC;


--- Churn rate = (lost customer / total customers) * 100
----Churn rate = 49.29%

select 
round(((count(churn) filter (where churn=true)) :: decimal /count(churn) :: decimal)*100,2)
from customer_churn


--Q) What is the average tenure of customers?
-- Therfore, on average, the customer stays for 36 months before continuing or leaving

SELECT 
ROUND(AVG(tenure),2) AS avg_tenure
FROM customer_churn 

-- Q) What is the churn rate among males vs females?

select 
gender,
round
((count(*) filter(where churn = true) :: decimal/ 
  count(*) :: decimal) * 100
  ,2)
from customer_churn
group by gender


-- 3.1) Analysis to determine the key factors responsible for customer churn

-------------------------------------------------------------------------------------------------------
-- NOTE : Here I am comparing each category only among customers who churned, not the whole dataset. 
-- This helps identify which customer segments contribute the most to churn.
--------------------------------------------------------------------------------------------------------


-- Q) Computes churn percentages for each tenure category by grouping, counting, and normalizing churned customers.

--Tenure: Number of months the customer has stayed with the company
--Using CTEs to first classify customers into defined groups and then computing churn analysis based on those groups.

select avg(tenure)
from customer_churn

select min(tenure)
from customer_churn

with cte as
(
select tenure,churn,
case 
  when tenure <= 12 then 'within_one_year'
  when tenure <= 24 and tenure > 12 then 'within_two_years'
  when tenure <= 36 and tenure > 24 then 'within_three_years'
  when tenure <= 48 and tenure > 36 then 'within_four_years'
  when tenure <= 60 and tenure > 48 then 'within_five_years'
  else 'more than five years'
end as tenure_period
from customer_churn
),
cte2 as 
(
select 
tenure_period,
count(*) filter (where churn = true) as churned_customers
from cte
group by tenure_period
)
select 
tenure_period,
round((churned_customers :: decimal/
 (select sum(churned_customers) from cte2)) *100
 ,2) as percentage_of_customers_churned_by_tenure
from cte2


-- Q) What is the churn percentage among males vs females?

select 
ROUND((((count(churn) filter(where gender = 'Female' AND churn = true)) :: decimal/ 
             (count(churn) filter(where churn = true))) * 100),2) as female_percent_of_churn,
ROUND((((count(churn) filter(where gender = 'Male' AND churn = true)) :: decimal/ 
             (count(churn) filter(where churn = true))) * 100),2) as male_percent_of_churn
from customer_churn

--Q) Does having a partner reduce churn percentage?

select 
ROUND((((count(churn) filter(where partner = true AND churn = true)) :: decimal/ 
            (count(churn) filter(where churn = true))) * 100),2) as partner_percent_of_churn,
ROUND((((count(churn) filter(where partner = false AND churn = true)) :: decimal/
            (count(churn) filter(where churn = true))) * 100),2) as nopartner_percent_of_churn
from customer_churn


--Q) Do senior citizens churn more than non-senior citizens?

select 
count(seniorcitizen) filter (where seniorcitizen = true and churn = true) 
                          as senior_citizen_churn,
count(seniorcitizen) filter (where seniorcitizen = false and churn = true) 
                          as non_senior_citizen_churn
from customer_churn


--Q) Does having dependents reduce churn percentage?

select 
ROUND((((count(churn) filter(where dependents = true AND churn = true)) :: decimal/ 
               (count(churn) filter(where churn = true))) * 100),2) as dependent_percent_of_churn,
ROUND((((count(churn) filter(where dependents = false AND churn = true)) :: decimal/ 
               (count(churn) filter(where churn = true))) * 100),2) as nodependent_percent_of_churn
from customer_churn


-- Q) Which InternetService type has the highest churn percentage?


select internetservice
from customer_churn
group by internetservice

select 
internetservice,
round((count(*) filter (where churn = true) :: decimal / 
          (select count(churn) from customer_churn where churn = 'true') :: decimal) * 100,2)
from customer_churn
group by internetservice


--Q) What is the churn percenatage for customers without online security?

select * from customer_churn limit 10

select 
round(((count(churn) filter (where onlinesecurity = 'No' and churn = true) :: decimal) /
               count(*) :: decimal)*100,2) AS churn_percent_with_no_onlinesecurity
from customer_churn

select 
onlinesecurity,
round((count(*) filter (where churn = true) :: decimal / 
          (select count(churn) from customer_churn where churn = true) :: decimal) * 100,2)
from customer_churn
group by onlinesecurity


--Q) Compare churn rates between monthly, one-year, and two-year contracts.
-- formula : (Churned customers in that contract type) / (Total customers in that contract type)

select contract
from customer_churn
group by contract

select contract,
count(contract)
from customer_churn
where churn = true
group by contract

--Which contract type contributes most to overall churn?

select contract,
round(((count(*) filter(where churn = true) :: decimal)/ 
         (select count(*) from customer_churn where churn = true) :: decimal) * 100 ,2)
from customer_churn
group by contract

--Which contract type has the highest churn rate?

select contract,
round((count(churn) filter(where churn = 'true') :: decimal / count(*) :: decimal) * 100,2)
from customer_churn
group by contract


--Q) Do customers with paperless billing churn more?
-- Among all the customers who churned, how many had paperless billing vs. did not?

SELECT * FROM customer_churn limit 10

select 
round((count(churn) filter (where churn = true and paperlessbilling = true) :: decimal / 
            (count(churn) filter(where churn = true)):: decimal)* 100,2 ) as churn_with_paperless,
round((count(churn) filter (where churn = true and paperlessbilling = false) :: decimal / 
          (count(churn) filter(where churn = true)) :: decimal) * 100,2 )  as churn_wo_paperless
from customer_churn


--Q) Which payment method has the highest churn rate?

select paymentmethod
from customer_churn
group by paymentmethod


SELECT 
    paymentmethod,
    ROUND(
        COUNT(*) FILTER (WHERE churn = true)::decimal
        / (SELECT COUNT(*) FROM customer_churn WHERE churn = true)::decimal
        * 100, 
        2
    ) AS percent_of_total_churn
FROM customer_churn
GROUP BY paymentmethod
ORDER BY percent_of_total_churn DESC;


--Q) Does tech support have any effect on churn?


SELECT 
    techsupport,
    ROUND(
        COUNT(*) FILTER (WHERE churn = true)::decimal
        / (SELECT COUNT(*) FROM customer_churn WHERE churn = true)::decimal
        * 100, 
        2
    ) AS percent_of_total_churn
FROM customer_churn
GROUP BY techsupport
ORDER BY percent_of_total_churn DESC;


--Q) Are customers with high monthly charges more likely to churn?--yes
-- CTE used to categorize customers by monthly charge level
select max(monthlycharges), min(monthlycharges), avg(monthlycharges)
from customer_churn

-- Let's assume that monthlycharges > 70 is high monthly charge

with cte as
(
select monthlycharges, churn,
case
when monthlycharges > 70 then 'high_monthly_charge'
else 'low_monthly_charge'
end as monthly_distribution
from customer_churn
)

select monthly_distribution,
   ROUND(
        COUNT(*) FILTER (WHERE churn = true)::decimal
        / (SELECT COUNT(*) FROM customer_churn WHERE churn = true)::decimal
        * 100, 
        2
    ) as churn_rate
from cte 
group by monthly_distribution


--Q) How having multipleline effect the churn rate?

select 
multiplelines,
round(
   (count(*) filter(where churn = true) :: decimal / 
   (select count(churn) from customer_churn where churn = true) :: decimal) 
   * 100,
   2
   )
from customer_churn
group by multiplelines


--Q) How having device protection effect the churn rate?

select 
deviceprotection,
round(
   (count(*) filter(where churn = true) :: decimal / 
   (select count(churn) from customer_churn where churn = true) :: decimal) 
   * 100,
   2
   )
from customer_churn
group by deviceprotection


-- 3.2) Financial analysis

--Q) Find the average monthly charges of churned vs not churned customers.

select churn,
round(avg(monthlycharges),2) as avg_of_monthlycharge
from customer_churn
group by churn

--Q) Find the max monthly charges of churned customers.

select churn,
max(monthlycharges) as avg_of_monthlycharge
from customer_churn
where churn = true
group by churn

--Q) Identify the top 10 customersid with highest MonthlyCharges who churned.

select customerid, monthlycharges, churn
from customer_churn
where churn = true
order by monthlycharges desc
limit 10

---Q) How much revenue was lost to churned customers?

select * from customer_churn limit 10

select 
sum(totalcharges)  as lost_revenue
from customer_churn
where churn = true


--Q) Out of all the lost revenue, how much came from each contract type?

select contract,
round((
  sum(totalcharges) filter (where churn = true)/ 
           (select sum(totalcharges) filter (where churn = true) from customer_churn)
)*100,2)
from customer_churn
group by contract


--Q) Out of all the money the company earned, how much revenue was lost because of churn for each contract type?
--Out of all the total revenue earned, how much was lost due to churn for each contract type?

select contract,
round((
  sum(totalcharges) filter(where churn = true) / 
           (select sum(totalcharges) from customer_churn)
)*100,2)
from customer_churn
group by contract
