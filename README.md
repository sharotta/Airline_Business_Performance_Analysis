# Airline Business Performance & Route Economics Analysis
Provides a view of flight-level commercial and operational performance across revenue, passenger demand, and fuel efficiency. Using SQL and Power BI, the project identifies performance patterns and highlights routes that may require management attention or present opportunities for improvement.

## Table of Contents
- [Business Context](#business-context)
- [Business Question](#business-question)
- [Questions I Wanted to Answer](#questions-i-wanted-to-answer)
- [Data Preparation](#data-preparation)
  - [Data Preparation Challenges](#data-preparation)
  - [Excel Preparation](#excel-preparation)
  - [SQL Preparation](#sql-preparation)
- [Key Findings](#key-findings)
  - [Network Benchmarks](#network-benchmarks)
  - [Commercial Performance](#commercial-performance)
  - [Passenger Demand and Pricing](#passenger-demand-and-pricing)
  - [Fuel Efficiency](#fuel-efficiency)
  - [Route Performance Patterns](#route-performance-patterns)
  - [Management Opportunities](#management-opportunities)
- [Dashboard & Business Insights](#dashboard--business-insights)
- [Business Recommendations](#business-recommendations)
- [Tools & Technologies](#tools--technologies)
- [Data Source](#data-source)
- [What I Learned](#what-i-learned)
- [Limitations](#limitations)


## Business Context
Airline management needs to understand how different routes are performing commercially and operationally. Some routes may generate strong revenue and passenger demand but consume more fuel, while others may operate more efficiently but deliver weaker commercial returns.

A clear view of these differences can help management identify strong-performing routes, areas of concern, and opportunities for improvement.

This analysis examines flight-level data to evaluate route performance across revenue, passenger demand, and fuel efficiency, providing insights that can support better management decisions.

## Business Question
How can airline management identify which routes are performing well, which require attention, and where are there opportunities to improve commercial and operational performance?

## Questions I Wanted to Answer
* Which routes generate the highest gross ticket revenue?
* Where is passenger demand strongest across the network?
* How does ticket pricing vary across destinations, and what relationship does it have with passenger demand?
* Which routes have the highest fuel consumption per passenger?
* Which routes generate stronger revenue relative to fuel consumption?
* Which routes combine strong commercial performance with fuel efficiency concerns?
* Which routes appear efficient but may have opportunities for stronger commercial performance?
* Which routes require priority management attention?

## Analytical Approach
The analysis evaluates route performance through four key areas:
* **Route Economics:** How routes perform commercially based on revenue generated and passenger demand.
* **Fuel Performance:** How efficiently routes use fuel relative to passenger volume and revenue generated.
* **Destination Performance:** How ticket pricing and passenger demand vary across destinations.
* **Management Opportunities:** Which routes are performing well, which require attention, and where management may have opportunities to improve performance.

Routes were compared against network-level benchmarks for revenue per flight and fuel consumption per passenger to identify different performance patterns and group routes into management categories.

## Data Preparation
The dataset contains 1,000 flight records covering routes, destinations, flight duration, altitude, fuel consumption, ticket prices, and passenger counts.

### Data Preparation Challenges
![Before Cleaning](https://github.com/user-attachments/assets/ed21f7e8-392e-4bf0-8f16-ea2ea1005612)
The raw dataset contained several data quality issues that needed to be addressed before analysis:
- Missing values across flight duration, altitude, fuel consumption, ticket price, and passenger count.
- Ticket_Price required additional preparation before it could be reliably used in SQL calculations.
- Flight-level data needed to be transformed into route-level measures for meaningful performance comparison.
- Calculated revenue and efficiency metrics required consistent and validated input values.
  
### Excel Preparation
Excel was used for initial data preparation and validation. This included reviewing the raw dataset, checking field completeness and data types, and preparing the ticket price data for use in the SQL analysis.

### SQL Preparation  
SQL Server was then used to prepare the dataset for analysis by:
- Checking for duplicate flight records and validating the prepared data.
- Handling missing operational values using route-level averages.
- Handling missing ticket prices using destination-level median pricing.
- Creating calculated metrics including gross ticket revenue, revenue per flight, revenue per flight hour, fuel consumption per passenger, and revenue per unit of fuel.
- Aggregating flight-level data into route-level performance measures.
- Establishing network-level benchmarks for revenue per flight and fuel consumption per passenger.
- Classifying routes into management categories based on commercial performance and fuel efficiency.

The prepared SQL views were then connected to Power BI for analysis and visualization.

## Key Findings
### Network Benchmarks
The analysis uses the following network-level benchmarks as reference points for evaluating route performance:
| Metric                     | Benchmark |
| -------------------------- | --------: |
| Average Revenue per Flight |   $44,965 |
| Average Fuel per Passenger |     25.62 |

### Commercial Performance
* **New York → Dubai** generated the highest revenue per flight at approximately **$60,750**, while **Chicago → Tokyo** generated the highest total route revenue at approximately **$2.36M**.
* Several routes generated strong commercial returns while also showing higher-than-benchmark fuel consumption per passenger, indicating areas where commercial strength and operational efficiency need to be considered together.

### Passenger Demand and Pricing
* Passenger volumes varied considerably across destinations.
* **Sydney** recorded the highest passenger volume, while **Dubai** had the highest average ticket price.
* Within this dataset, destinations with higher average ticket prices generally recorded lower passenger volumes. This is an observed relationship, not evidence that higher prices caused lower demand.

### Fuel Efficiency
* **Miami → Sydney** recorded the highest fuel consumption per passenger at approximately **33.33**, making it a notable efficiency concern.
* **New York → Dubai** generated strong revenue while maintaining relatively low fuel consumption per passenger, demonstrating stronger commercial and efficiency performance.

### Route Performance Patterns
Routes were grouped into four management categories based on revenue per flight and fuel consumption per passenger:
* **Core Performer:** Strong commercial performance and better-than-benchmark fuel efficiency.
* **Commercial Value – Efficiency Concern:** Strong commercial performance but higher-than-benchmark fuel consumption.
* **Efficient – Commercial Opportunity:** Better fuel efficiency but weaker commercial performance.
* **Priority Review:** Below-benchmark commercial performance and higher-than-benchmark fuel consumption.

### Management Opportunities
The route classification highlights four types of management opportunity:
| Management Category                       | Management Focus                                                      |
| ----------------------------------------- | --------------------------------------------------------------------- |
| **Core Performer**                        | Maintain performance and consider opportunities for growth.           |
| **Commercial Value – Efficiency Concern** | Protect commercial performance while investigating fuel efficiency.   |
| **Efficient – Commercial Opportunity**    | Explore pricing, demand generation, or route frequency opportunities. |
| **Priority Review**                       | Review route economics, passenger demand, and operational efficiency. |

These classifications help management move from simply identifying route performance differences to determining where further investigation or action may be warranted.

## Dashboard & Business Insights
The dashboard shows route performance across commercial value, passenger demand, and operational efficiency, allowing comparison of routes and destinations to identify strong performance, areas of concern, and potential opportunities.
1. How is the network performing overall?
This provides a high-level view of revenue, passenger performance, route performance, and commercial value relative to fuel efficiency.

2. Route & Market Performance
Where is commercial value concentrated?
Compares routes and destinations by revenue, passenger demand, ticket pricing, and revenue per flight to highlight differences in market performance.

3. Fuel & Operational Efficiency
Where are efficiency concerns emerging?
Compares fuel consumption across routes and examines how fuel efficiency relates to commercial performance.

4. Management Opportunities
Where should management focus?
Groups routes into performance categories to highlight where management may need to protect performance, investigate concerns, improve efficiency, or pursue commercial opportunities.

Together, these views provide a clear path from network performance to route-level business opportunities.

## Business Recommendations
The route-level analysis suggests that management should differentiate its response rather than apply a single strategy across the network.

* **Protect high-value routes while investigating their efficiency profile.** Routes such as **New York → Dubai, Chicago → Tokyo, and Miami → Tokyo** generate strong revenue per flight, but their performance should be assessed alongside fuel consumption before decisions are made about expansion or additional capacity. Strong revenue alone does not necessarily indicate that a route is operating efficiently.

* **Investigate Miami → Sydney as a priority efficiency concern.** The route records the **highest fuel consumption per passenger (33.33)** while generating only about **$37.1K revenue per flight**, placing it in the Priority Review category. Management should investigate what is driving the fuel intensity and whether the route's commercial return justifies its operational profile.

* **Review the weakest commercial performers with efficiency concerns first.** Routes such as **Los Angeles → Paris, New York → London, Miami → Paris, and Chicago → London** combine below-benchmark revenue per flight with relatively high fuel consumption per passenger. These routes warrant deeper review of demand, pricing, route economics, and operating efficiency before additional resources are committed.

* **Investigate efficient routes for commercial upside.** Routes including **Chicago → Sydney, Houston → Sydney, Houston → London, and New York → Sydney** demonstrate better-than-benchmark fuel efficiency but weaker revenue per flight. This creates a different management question: whether stronger pricing, demand generation, or route frequency could improve their commercial contribution without undermining their efficiency advantage.

* **Use destination pricing and demand together when reviewing commercial strategy.** Sydney records the highest passenger volume but a lower average ticket price than Dubai and Tokyo, while Dubai has the highest average ticket price and lower passenger volume. This suggests that pricing decisions should be considered alongside demand patterns rather than evaluated in isolation.

* **Use route benchmarks as an ongoing management filter.** The four-category classification provides a practical starting point for prioritization: protect Core Performers, investigate Commercial Value routes with efficiency concerns, explore commercial opportunities on Efficient routes, and subject Priority Review routes to deeper investigation before strategic decisions are made.

## Tools & Technologies
- Excel - initial data preparation and validation
- SQL Server - data cleaning, transformation, metric creation, route-level aggregation, and business classification
- Power BI - interactive dashboard development and business insights
- DAX - analytical measures and KPI calculations

## Data Source
The dataset used in this analysis was synthetically generated using Python to simulate real-world aviation data challenges, including missing values, geographical data, and key business metrics.

## What I Learned
This project strengthened my understanding of how much analytical judgment happens before a dashboard is ever built.

Working from incomplete flight-level data required me to think carefully about how missing values should be handled and how those decisions could affect downstream metrics. It also reinforced the importance of validating calculated measures such as revenue per flight, fuel consumption per passenger, and revenue efficiency before using them to compare routes.

A key lesson was that **strong performance in one dimension does not necessarily mean strong overall performance**. A route can generate high revenue while consuming more fuel, while another can operate efficiently but have weaker commercial returns. Looking at these measures together provided a more useful basis for prioritizing management attention.

The project also reinforced the importance of **benchmarks and business context**. Rather than simply ranking routes, I used network-level benchmarks to classify performance and translate the analysis into different management opportunities.

Most importantly, I learned to be more deliberate about the difference between **what the data shows and what it allows me to conclude**. Observing a relationship between ticket prices and passenger demand, for example, does not establish that pricing caused the difference in demand. Good analysis requires knowing where the evidence ends and where further investigation is needed.

## Limitations
* Operating cost data is not available, so the analysis evaluates **revenue and operational efficiency rather than profitability**.
* Aircraft capacity is not provided, so passenger counts cannot be used to measure true capacity utilization.
* Flight dates are not available, limiting the analysis to route and destination comparisons rather than changes in performance over time.
* Missing values were imputed using route-level averages or destination-level median pricing, which may influence some calculated metrics.




																																																																																																																																																																																																																																																																	







