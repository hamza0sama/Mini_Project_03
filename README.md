# From Sales to Profit: An Interactive Tableau Dashboard Story

An interactive Tableau workbook of seven linked dashboards that follows one question: **why does strong sales volume produce such thin profit?** It moves from the big picture, to likely causes, to category, time and geographic detail, then closes with the latest year and the customer base.

> **Live dashboard:** [Tableau Public link]
> **Presentation:** [link to slide deck]

---

## Headline Results

| Metric | Value |
|---|---|
| Total sales | **$501.2K** |
| Total profit | **$39.7K** (profit margin of about 8%) |
| Top profit shipping mode | Standard Class ($25.4K profit on $318.5K sales) |
| Weakest shipping mode | Same Day ($1.5K profit on $20.4K sales) |
| 2016 sales vs. 2015 | $147K (-0.2%) |
| 2016 quantity vs. 2015 | 2,880 units (+22.1%) |
| 2016 profit vs. 2015 | $8K (**-62.1%**) |
| 2016 customers | 325 (+24.5%), with sales per customer down 19.9% to $453 |

---

## Dashboard Tour

| # | Dashboard | Question it answers | Key insight |
|---|---|---|---|
| 1 | **Overview** | How are we doing overall? | Sales are high but profit is thin. Standard Class drives revenue, while First Class turned into losses in 2015 and 2016. |
| 2 | **Discount Impact** | What may be eroding profit? | Several top-selling products carry discounts. Canon imageCLASS leads profit at 8,400. |
| 3 | **Categories** | Where do the units concentrate? | Binders (1,473) and Paper (1,225) lead. Copiers (49) and Machines (66) sell the least. |
| 4 | **Quantity** | How does demand move over time? | Demand is seasonal, with a low of 162 units in February and a peak of 1,110 in November. |
| 5 | **Regions** | Where do we sell? | Houston is the top city by sales (about $64.5K), followed by Chicago and Detroit. |
| 6 | **2016 Performance** | How did the latest year compare with 2015? | Sales were flat and quantity grew, yet profit fell 62.1%. |
| 7 | **Customers** | Who is behind the numbers? | The customer base grew, but each customer spent less. Profit is concentrated in a few top customers. |

---

## Interactive Features

- **Navigation bar** to move between all dashboards.
- **Filters** for year, ship mode, category, quarter and discount level.
- **Parameters** for a profit threshold, a quantity threshold, Top N and a choice of measure.
- **Conditional coloring** that separates values above and below thresholds, and profit from loss.
- **Prior-year comparisons** with highest-month and lowest-month markers on the KPI sparklines.
- **Geographic map** of sales with a top-cities ranking.

---

## Recommendations

1. **Review discount policy** on high-sales, low-profit products.
2. **Re-evaluate First Class** pricing or terms to stop the losses.
3. **Focus on the most profitable products and categories**, not volume alone.
4. **Prepare inventory and promotions** for the November and December peak.
5. **Grow basket value per customer** and retain the top customers.
6. **Strengthen presence in the leading cities** and investigate why others lag.

---

## Caveats and Next Steps

- The link between discounts and lower profit is a **hypothesis based on the charts**. It should be validated by comparing profit margin at each discount level.
- The map reports **123 locations as unknown**. Cleaning the location data would improve the regional view.
- The 2016 dashboards are filtered to a single year, so their totals are lower than the all-years totals above.

---

## Screenshots

| Overview | Discount Impact |
|---|---|
| ![Overview](images/01-overview.png) | ![Discount Impact](images/02-discount-impact.png) |

| Categories | Quantity |
|---|---|
| ![Categories](images/03-categories.png) | ![Quantity](images/04-quantity.png) |

| Regions | 2016 Performance |
|---|---|
| ![Regions](images/05-regions.png) | ![2016 Performance](images/06-2016-performance.png) |

| Customers |
|---|
| ![Customers](images/07-customers.png) |

---

## Tools

- **Tableau** (Desktop or Public) for the dashboards, parameters and interactive filters.
- **Data source:** [dataset name and link]

## Repository Structure

```
.
├── README.md
├── workbook/        # Tableau workbook (.twbx)
├── images/          # Dashboard screenshots
└── presentation/    # Slide deck
```

## Author

**Hamza**
GitHub: [github.com/hamza0sama](https://github.com/hamza0sama)
**Mohamed Ahmed Rashed Atia**
GitHub: [github.com/hamza0sama](https://github.com/hamza0sama)
