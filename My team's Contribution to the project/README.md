# Mini Project 03 – Central Superstore Tableau Dashboards

This is my part of our team's Tableau project on the Central Superstore data. I'm **Mohamed Ahmed Rashed Atia** ([@bshni](https://github.com/bshni)), and I worked on it with **Ahmed Mahmoud** ([@amx-20](https://github.com/amx-20)). My part was **sales in relation to the customer dimension**.

The full project (the final merged workbook and everyone else's work) lives in our team leader's repo, so if you want the complete picture go here:
👉 https://github.com/hamza0sama/Mini_Project_03

This repo only covers what I built.

---

## What's in here

```
My team's Contribution to the project/
├── Mohamed Rashed and Ahmed Mahmoud.twb     # my workbook
├── Mohamed Rashed and Ahmed Mahmoud.twbx    # packaged version (data included)
└── Mohamed Rashed and Ahmed Mahmoud .md     # my notes while building it

screenshots/
├── sales_dashboard.png
└── customer_dashboard.png

Findings.md                                  # the 10 questions I picked, answered from the dashboards
```

The written answers to the questions behind the dashboards are in [Findings.md](Findings.md).

The rest of the folders (`database/`, `dataset/`, `icons/`) come from the shared project. I didn't build the database, that was the team leader's work, I only connect to it.

## Data source

The workbook connects to a SQL Server database called `Mini_Project_02`, which our leader designed (staging → bronze → silver → gold). I'm using the gold layer:

- `FactSales`
- `dimCustomer`
- `dimDate`
- `dimLocation`
- `dimProduct`

I had built a similar data warehouse myself before this ([sql_data_warehouse_business_analytics](https://github.com/bshni/sql_data_warehouse_business_analytics)), but we agreed as a team to use our leader's database so everyone's work stays unified.

Our leader made the date a separate dimension instead of keeping it inside the fact table, so I used `dimDate` for all the time-based analysis.

I also had to join the `silver.encounters` table to get the Order ID, since it wasn't available anywhere in the gold layer and I needed it to count orders per customer.

## What I built

Two dashboards with the same layout, so they feel like one report. Both compare the selected year with the previous year (the default view is 2016 vs 2015), and the dots on the trend lines mark the highest month (teal) and the lowest month (orange).

At the top of each one there's a **Show Filters** button and two buttons to jump between the dashboards.

### Sales Dashboard

![Sales Dashboard](screenshots/sales_dashboard.png)

- **KPIs:** Total Sales, Total Profit and Total Quantity, each with a Jan–Dec trend line against the previous year and the % difference vs PY.
- **Sales & Profit by Segment:** the black bar is this year's sales and the grey bar behind it is last year's, so you see the change per segment at a glance. Next to it, the profit is teal when it's a profit and orange when it's a loss. A small orange dot next to a segment name flags that this year's sales were lower than last year's. Clicking a segment filters the rest of the dashboard.
- **Sales & Profit Trends over time:** weekly sales and profit with a dashed average line. Teal means the week is above average and orange means below.

### Customer Dashboard

![Customer Dashboard](screenshots/customer_dashboard.png)

- **KPIs:** Total Customers, Total Sales per Customer and Total Quantity per Customer, same style as the sales ones (trend line vs previous year + % difference).
- **Customer Distribution by Nr. of Orders:** how many customers placed 1 order, 2 orders, and so on.
- **Top 10 Customers by Profit:** rank, customer, last order date, profit, sales and number of orders for the year.

Both dashboards have **Category** and **Sub-Category** filters, and I made custom filter and clear-filter buttons (the icons are in the `icons/` folder).

## Design choices

- Maximum of **4 colors** across everything: orange, teal, dark grey and light grey. This comes from Eng. Baraa's advice ("Data with Baraa" on YouTube). It was my first Tableau project, so I followed his tutorial and only applied the parts relevant to my section.
- Teal always means good (highest month, profit, above average) and orange means bad (lowest month, loss, below average), so you can read the dashboards without a legend lookup.
- KPI titles and numbers react to the filters, they're not static.

## Things I ran into

- **Slow loading workbook:** Taqey and Saif's workbook took about a minute to open because the SQL Server name was typed wrong in the connection. I fixed it.
- **Wrong data type:** Tableau picked the wrong type for the `Region` column in `dimLocation`. This exists in the other workbooks too, so I told the team.
- **KPIs not reacting to filters:** my first fix was wrapping the calculations in `WINDOW_SUM`, which got the KPIs reacting but didn't work for distinct aggregations and the difference number still didn't update. I ended up using a separate sheet for the title/difference values instead, which solved it properly. The tutorial doesn't cover this, so I had to figure it out on my own.
- **Wrong numbers in the Customer Distribution chart:** the gold layer has no Order ID, and the database design wasn't mine, so I had to find my own solution and joined `silver.encounters` to get it. That join is on Customer ID only, so the year came from the sales side while the Order ID came from the encounters side. Every 2016 sale got paired with all of that customer's orders from every year, and the order counts in the histogram and in the Top 10 table were inflated. I fixed it by taking the order date from the same table as the Order ID (`encounters`), counting distinct orders with `COUNTD`, and excluding the nulls that came from the other years. Now the bars add up to the 325 customers of the year.

## How to open it

1. Download this repo.
2. Open the `.twbx` file in Tableau, since it has the data packaged inside and works without a database connection.
3. If you use the `.twb` instead, you'll need SQL Server running with the `Mini_Project_02` database (script is in the team repo linked above) and you'll have to update the server name in the connection to match yours.

## Credits

The team behind the full project:

- **Hamza** (team leader) – designed the database and merged the dashboards from all the sub-teams into one story: [@hamza0sama](https://github.com/hamza0sama)
- **Mohamed Ahmed Rashed Atia** (me) – sales by customer dashboards: [@bshni](https://github.com/bshni)
- **Ahmed Mahmoud** – worked with me on this part: [@amx-20](https://github.com/amx-20)
- **Saif elden khaled**: [@Saifeldenkhaled](https://github.com/Saifeldenkhaled)
- **Taqey**: [@Taqey](https://github.com/Taqey)
- **Mohamed abdalqader**: [@mo3abdalqader](https://github.com/mo3abdalqader)

Tutorial followed: **Data with Baraa** (Tableau project tutorial).
