# olist-ecommerce-sql-analysis
# 🛒 Olist E-Commerce SQL Analysis

## 📌 Project Overview

This project presents an end-to-end **SQL analysis of the Brazilian Olist E-Commerce dataset**, focusing on order performance, delivery operations, customer purchasing behavior, and business performance.

The main objective was not only to write SQL queries, but to approach the dataset from a **Data Analyst perspective**:

> **Business Question → Metric → SQL Analysis → Result → Insight → Business Interpretation**

The analysis was performed using **MySQL**, with SQL techniques ranging from basic data exploration to more advanced analytical concepts such as **CTEs, subqueries, conditional aggregation, and window functions**.

---

## 🎯 Business Problem

An e-commerce business generates a large amount of operational and customer data.

The business needs to understand:

* How many orders are being placed?
* What is the distribution of order statuses?
* How efficiently are orders being delivered?
* How often are orders delivered late?
* Where are the biggest delays occurring in the delivery journey?
* How many customers are returning customers?
* How frequently do customers place orders?
* What operational patterns can be identified from the data?

This analysis uses SQL to answer these questions and transform raw transactional data into meaningful business insights.

---

# 📊 Dataset

The project uses the **Brazilian Olist E-Commerce Dataset**, which contains information about orders, customers, products, sellers, payments, reviews, and geographical information.

### Main tables used in the project

| Table                  | Description                               |
| ---------------------- | ----------------------------------------- |
| `orders`               | Order information and delivery timestamps |
| `customers`            | Customer information                      |
| `order_items`          | Products included in each order           |
| `order_payments`       | Payment information                       |
| `order_reviews`        | Customer review information               |
| `products`             | Product information                       |
| `sellers`              | Seller information                        |
| `geolocation`          | Brazilian geographical information        |
| `category_translation` | Product category translations             |

The main analysis initially focuses on the **`orders` table**, before extending the analysis to other tables where necessary.

---

# 🧠 Business Questions

The analysis was structured around several business questions.

## 1. Order Overview

### Q1. How many orders were placed?

**Metric:** Total number of orders.

**Result:**

* Total Orders: **[VALUE]**

**Business Insight:**

This provides the overall scale of the dataset and establishes the baseline for the remaining analysis.

---

### Q2. How are orders distributed by status?

**Metric:** Number of orders by `order_status`.

```sql
SELECT
    order_status,
    COUNT(*) AS total_orders
FROM orders
GROUP BY order_status
ORDER BY total_orders DESC;
```

**Result:**

| Order Status | Total Orders |
| ------------ | -----------: |
| Delivered    |      [VALUE] |
| Shipped      |      [VALUE] |
| Canceled     |      [VALUE] |
| Unavailable  |      [VALUE] |
| Other        |      [VALUE] |

**Business Insight:**

The majority of orders are concentrated in the **[STATUS]** category, while **[STATUS]** represents a smaller portion of total orders.

This helps provide an initial view of overall order fulfillment performance.

📸 *See the corresponding result screenshot in the project.*

---

# 🚚 2. Delivery Performance

## Q3. How long does it take to deliver an order to the customer?

**Metric:** Number of days between purchase and customer delivery.

```sql
SELECT
    order_id,
    DATEDIFF(
        order_delivered_customer_date,
        order_purchase_timestamp
    ) AS delivery_days
FROM orders
WHERE order_delivered_customer_date IS NOT NULL;
```

**Result:**

* Average Delivery Time: **[VALUE] days**

**Business Insight:**

The analysis provides a baseline for understanding the typical customer delivery experience.

Delivery duration can later be compared across sellers, product categories, regions, and time periods to identify operational differences.

---

## Q4. What percentage of delivered orders were late?

An order was classified as **Late** when:

`Actual Delivery Date > Estimated Delivery Date`

```sql
SELECT
    COUNT(*) AS total_delivered_orders,

    SUM(
        CASE
            WHEN order_delivered_customer_date > order_estimated_delivery_date
            THEN 1
            ELSE 0
        END
    ) AS late_orders,

    SUM(
        CASE
            WHEN order_delivered_customer_date > order_estimated_delivery_date
            THEN 1
            ELSE 0
        END
    ) * 100.0 / COUNT(*) AS late_percentage,

    SUM(
        CASE
            WHEN order_delivered_customer_date <= order_estimated_delivery_date
            THEN 1
            ELSE 0
        END
    ) * 100.0 / COUNT(*) AS on_time_percentage

FROM orders
WHERE order_delivered_customer_date IS NOT NULL;
```

**Result:**

* Total Delivered Orders: **[VALUE]**
* Late Orders: **[VALUE]**
* Late Delivery Rate: **[VALUE]%**
* On-Time Delivery Rate: **[VALUE]%**

**Business Insight:**

The late-delivery rate provides an important operational KPI because delivery performance directly affects the customer experience.

---

# ⏰ 3. Late Delivery Analysis

## Q5. When an order is late, how many days late is it on average?

```sql
SELECT
    AVG(
        CASE
            WHEN order_delivered_customer_date > order_estimated_delivery_date
            THEN DATEDIFF(
                order_delivered_customer_date,
                order_estimated_delivery_date
            )
        END
    ) AS avg_late_days
FROM orders
WHERE order_delivered_customer_date IS NOT NULL;
```

**Result:**

* Average Late Delivery: **[VALUE] days**

**Business Insight:**

This metric goes beyond simply measuring how many orders are late.

A company may have a relatively low late-order percentage but still experience significant delays when late deliveries occur.

Therefore, both metrics are useful:

* **How often are orders late?**
* **How late are they when they are late?**

---

# 🚛 4. Delivery Journey Analysis

The delivery process was divided into several operational stages:

```text
Purchase
   ↓
Approval
   ↓
Carrier
   ↓
Customer
```

This makes it possible to identify where the most time is spent during the fulfillment process.

---

## Q6. How long does the purchase-to-approval stage take?

**Metric:**

`Approval Timestamp - Purchase Timestamp`

**Result:**

* Average Purchase → Approval: **[VALUE] days**

---

## Q7. How long does it take from approval to carrier?

**Metric:**

`Carrier Date - Approval Timestamp`

```sql
SELECT
    AVG(
        DATEDIFF(
            order_delivered_carrier_date,
            order_approved_at
        )
    ) AS avg_approved_to_carrier_days
FROM orders
WHERE order_approved_at IS NOT NULL
  AND order_delivered_carrier_date IS NOT NULL;
```

**Result:**

* Average Approval → Carrier: **[VALUE] days**

---

## Q8. How long does the carrier-to-customer stage take?

**Metric:**

`Customer Delivery Date - Carrier Date`

**Result:**

* Average Carrier → Customer: **[VALUE] days**

---

## Q9. How long does the complete delivery journey take?

**Metric:**

`Customer Delivery Date - Purchase Timestamp`

**Result:**

* Average Purchase → Customer: **[VALUE] days**

---

## 📦 Delivery Stage Summary

| Delivery Stage      | Average Duration |
| ------------------- | ---------------: |
| Purchase → Approval |     [VALUE] days |
| Approval → Carrier  |     [VALUE] days |
| Carrier → Customer  |     [VALUE] days |
| Purchase → Customer |     [VALUE] days |

### Business Interpretation

Breaking delivery into stages makes it possible to distinguish between:

* **Administrative/approval delays**
* **Seller or fulfillment delays**
* **Transportation delays**
* **Overall customer delivery time**

The stage with the largest average duration represents an important area for further investigation.

> **The goal is not simply to know that delivery is slow, but to understand where the time is being spent.**

---

# 👥 5. Customer Purchasing Behavior

## Q10. How many orders does each customer place?

```sql
SELECT
    customer_id,
    COUNT(order_id) AS total_orders
FROM orders
GROUP BY customer_id
ORDER BY total_orders DESC;
```

This analysis measures the number of orders associated with each customer.

**Result:**

The distribution shows that most customers placed **[VALUE]** order(s), while a smaller group placed multiple orders.

---

## Q11. Who are the customers with the highest number of orders?

The analysis was used to identify customers with the highest order frequency.

### Top Customers

| Customer   |  Orders |
| ---------- | ------: |
| [CUSTOMER] | [VALUE] |
| [CUSTOMER] | [VALUE] |
| [CUSTOMER] | [VALUE] |
| [CUSTOMER] | [VALUE] |
| [CUSTOMER] | [VALUE] |

### Business Insight

Identifying customers with repeated purchases can help the business understand its most active customer segments.

However, order frequency alone does not measure customer value. Revenue, profit, product mix, and purchase frequency over time would provide a deeper customer-value analysis.

---

# 🔁 6. Repeat Customer Analysis

## Q12. How many customers placed more than one order?

A customer was classified as a **repeat customer** when:

```text
Total Orders > 1
```

The analysis groups orders by customer and filters customers with more than one order.

**Result:**

* Total Customers: **[VALUE]**
* Repeat Customers: **[VALUE]**
* Repeat Customer Percentage: **[VALUE]%**

---

## Q13. What percentage of customers are repeat customers?

```sql
SELECT
    COUNT(*) AS total_customers,

    SUM(
        CASE
            WHEN total_orders > 1
            THEN 1
            ELSE 0
        END
    ) AS repeat_customers,

    SUM(
        CASE
            WHEN total_orders > 1
            THEN 1
            ELSE 0
        END
    ) * 100.0 / COUNT(*) AS repeat_customer_percentage

FROM (
    SELECT
        customer_id,
        COUNT(order_id) AS total_orders
    FROM orders
    GROUP BY customer_id
) AS customer_orders;
```

**Result:**

* Repeat Customer Rate: **[VALUE]%**

### Business Insight

Repeat customer rate provides an initial indication of how frequently customers return to the platform.

A deeper retention analysis would require a time-based definition, such as:

* First purchase date
* Second purchase date
* 30/60/90-day retention
* Cohort analysis

Therefore, this project treats **repeat customers** and **customer retention** as related but different concepts.

---

# 📈 7. Analytical Thinking

One of the main objectives of this project was to move beyond simply writing SQL queries.

The analysis followed a structured analytical process:

```text
Business Question
       ↓
Define the Metric
       ↓
Understand the Data Grain
       ↓
Write SQL
       ↓
Validate the Result
       ↓
Identify the Insight
       ↓
Interpret the Business Meaning
```

For example:

### Business Question

> How well is the company performing in terms of delivery?

### Metrics

* Average delivery time
* Late delivery rate
* Average late days
* On-time delivery rate

### Analysis

SQL aggregation, `CASE`, `DATEDIFF()`, and conditional aggregation were used to calculate these metrics.

### Business Interpretation

The results can help identify whether delivery performance is primarily affected by frequency of delays, severity of delays, or specific stages in the delivery journey.

---

# 🛠️ SQL Techniques Used

This project applies a wide range of SQL concepts:

### Basic SQL

* `SELECT`
* `FROM`
* `WHERE`
* `DISTINCT`
* Column aliases
* Table aliases
* `ORDER BY`
* `LIMIT`

### Filtering

* Comparison operators
* `AND`
* `OR`
* `BETWEEN`
* `IN`
* `LIKE`
* `IS NULL`
* `IS NOT NULL`

### Aggregation

* `COUNT()`
* `COUNT(DISTINCT)`
* `SUM()`
* `AVG()`
* `MIN()`
* `MAX()`
* `ROUND()`

### Grouping

* `GROUP BY`
* `HAVING`

### Conditional Logic

* `CASE`
* Conditional aggregation

### Joins

* `INNER JOIN`
* `LEFT JOIN`
* Multiple-table joins
* Join conditions
* Join cardinality and grain awareness

### Advanced SQL

* Subqueries
* Correlated subqueries
* Nested subqueries
* Common Table Expressions (`CTEs`)
* `UNION`
* `UNION ALL`
* `INTERSECT`
* `EXCEPT`
* Window Functions

### Date Analysis

* `DATEDIFF()`
* Date-based delivery metrics
* Delivery-stage calculations

---

# 🔍 Data Grain & Metric Validation

A major focus of the analysis was understanding the **grain of the data** before performing aggregations.

For example:

> One row in the `orders` table represents one order.

This matters because joining the orders table with tables such as `order_items` can change the number of rows per order.

If the grain is not understood correctly, metrics such as:

* `COUNT()`
* `SUM()`
* `AVG()`

can become misleading because of duplicated rows.

Therefore, the analysis considers both:

**SQL correctness + analytical correctness**

rather than focusing only on whether a query executes successfully.

---

# 📌 Key Findings

Based on the analysis, the main findings are:

### 1. Order Performance

The majority of orders are classified as **[STATUS]**, representing approximately **[VALUE]%** of the dataset.

### 2. Delivery Performance

Average delivery time was approximately **[VALUE] days**.

### 3. Late Deliveries

Approximately **[VALUE]%** of delivered orders were late.

### 4. Severity of Delays

When an order was late, the average delay was approximately **[VALUE] days**.

### 5. Delivery Bottleneck

The longest delivery stage was:

**[STAGE] → [STAGE]**

with an average duration of approximately **[VALUE] days**.

### 6. Customer Behavior

Approximately **[VALUE]%** of customers were repeat customers.

### 7. Customer Frequency

Most customers placed **[VALUE] order(s)**, while a smaller group placed multiple orders.

---

# 💡 Business Recommendations for Further Analysis

The current analysis identifies several areas that could be investigated further.

### Delivery Operations

Investigate why the longest delivery stage takes the most time.

Potential factors include:

* Seller location
* Customer location
* Product category
* Seller performance
* Shipping distance
* Order volume

### Customer Behavior

Analyze repeat customers by:

* Purchase frequency
* Total spending
* Product categories
* Review scores
* Geographic location

### Product Analysis

Investigate whether certain product categories have:

* Higher late-delivery rates
* Longer delivery times
* Higher order volumes
* Better or worse review scores

### Seller Performance

Compare sellers based on:

* Average delivery time
* Late delivery rate
* Number of orders
* Customer review scores

### Customer Experience

Investigate whether delivery delays are associated with lower review scores.

This would connect:

```text
Delivery Performance
        ↓
Customer Experience
        ↓
Review Score
```

---

# 🚀 Future Improvements

This project currently focuses primarily on **SQL-based analysis**.

Future versions can extend the project by adding:

### Power BI Dashboard

Create an interactive dashboard containing:

* Total Orders
* Delivery KPIs
* Late Delivery Rate
* Average Delivery Time
* Order Trends
* Customer Metrics
* Seller Performance
* Product Category Analysis

### Advanced Customer Analytics

* Customer segmentation
* Cohort analysis
* Retention analysis
* RFM analysis

### Advanced Operations Analysis

* Seller performance ranking
* Geographic delivery analysis
* Delivery-time trends
* Seasonal analysis

### Python

Python can later be used for:

* Exploratory Data Analysis
* Data Cleaning
* Statistical Analysis
* Visualization
* Automated reporting

---

# 📂 Project Structure

```text
olist-ecommerce-sql-analysis/
│
├── README.md
│
├── sql/
│   └── olist_analysis.sql
│
├── screenshots/
│   ├── order_status.png
│   ├── delivery_time.png
│   ├── late_delivery.png
│   ├── delivery_stages.png
│   └── customer_analysis.png
│
└── data/
    └── README.md
```

---

# 🧰 Tools & Technologies

* **MySQL**
* **SQL**
* **GitHub**
* **Olist E-Commerce Dataset**

---

# 🎓 Learning Outcomes

Through this project, I practiced not only SQL syntax but also the analytical thinking required to work with real-world business data.

The project helped me develop skills in:

* Translating business questions into measurable metrics
* Writing analytical SQL queries
* Working with dates and timestamps
* Performing conditional aggregation
* Building multi-step analysis using CTEs
* Using subqueries and window functions
* Understanding data grain
* Validating metrics
* Interpreting SQL results from a business perspective
* Communicating analytical findings clearly

---

# 📎 Project Files

The complete SQL analysis is available in:

`sql/olist_analysis.sql`

The repository also contains screenshots of the query results to make the analysis and findings easier to review.

---

# 👨‍💻 About This Project

This project was created as part of my journey toward becoming a **Data Analyst**, with a focus on developing both technical SQL skills and business-oriented analytical thinking.

Rather than treating SQL as only a programming language, the project focuses on using SQL to answer real business questions and turn raw data into actionable insights.

---

## ⭐ Final Takeaway

The main lesson from this project is that good data analysis is not simply about writing complex SQL.

It is about asking the **right question**, defining the **right metric**, understanding the **data**, validating the **result**, and finally explaining **what that result means for the business**.

> **SQL is the tool. The analysis is the thinking behind it.**
