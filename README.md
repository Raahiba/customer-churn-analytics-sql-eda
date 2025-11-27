# Customer Churn Analysis Using SQL
This project analyzes customer churn in the telecom domain using SQL to understand why customers discontinue their service. It includes data cleaning, exploration, and EDA to uncover patterns in telecom customer behavior. CTEs, window functions, and conditional aggregations are used to simplify calculations and compare different customer segments. This analysis also measures churn rates, revenue impact, and how contract types and services influence churn. Overall, this project provides clear insights into key factors driving churn in telecom customers.

## Project stratergy
The main steps that I have done in this analysis are: 
* **Data cleaning** - Handled missing/null values, and checked for any duplicate records to ensure the dataset was clean and reliable.
* **Basic Data Exploration** - Used SQL queries to understand customer distribution, churn counts, contract types, and service categories.
* **Exploratory Data Analysis (EDA)** - Applied CTEs, CASE statements, and conditional aggregations to explore churn patterns across tenure, demographics, service usage, and monthly charges.
* **Churn Rate Calculations** - Computed churn percentages across gender, contract type, billing method, service features, and security options.

## Insights
* Among 5880 customers, 49.29% of customers have churned, and 50.71% have not churned, indicating a very high churn rate of nearly 50%.
* The company experienced a revenue lost of approximately ~ 7.5 million due to customer churn. 
* Around 17% of the total revenue lost came from customers on month-to-month contracts.
* The key factors contributing to churn include customers with no internet service (34.78%), paper-based billing (50.83%), no technical support (33.33%), no phone service (50.90%), and those on a one-year contract (34.02%).
* Churn is consistently high across all tenure groups, showing that both new and long-term customers are leaving at similar rates.
  
## Customer Retention Strategies
* Enhance multiple-line services by providing advanced call features and improving customer experience.
* Provide dedicated and effective technical support.
* Encourage customers to use internet services with discounts or incentives.
* Promote phone services to deliver a better overall customer experience.
* Reward customers on long-term contracts by providing special offers or discounts.
