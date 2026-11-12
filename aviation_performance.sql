select top 10 *
from aviation_performance;
--------------------------------------------------------------------------------------
----- Checking the column names and data types of the aviation_performance table
select
    COLUMN_NAME,
    DATA_TYPE
from INFORMATION_SCHEMA.COLUMNS
where TABLE_NAME = 'aviation_performance'
order by ORDINAL_POSITION;
----- Data profiling for the aviation_performance table
select
    count(*) as Total_Rows,
    count(distinct Flight_ID) as Unique_Flights,
    sum(case when Takeoff_Location is null then 1 else 0 end) AS Missing_Takeoff,
    sum(case when Destination is null then 1 else 0 end) AS Missing_Destination,
    sum(case when Flight_Duration is null then 1 else 0 end) as Missing_Duration,
    sum(case when Altitude is null then 1 else 0 end) AS Missing_Altitude,
    sum(case when Longitude is null then 1 else 0 end) AS Missing_Longitude,
    sum(case when Latitude is null then 1 else 0 end) as Missing_Latitude,
    sum(case when Fuel_Consumption is null then 1 else 0 end) as Missing_Fuel,
    sum(case when Ticket_Price is null or Ticket_Price = '' then 1 else 0 end) as Missing_Ticket_Price,
    sum(case when Passenger_Count is null then 1 else 0 end) as Missing_Passengers
from aviation_performance;
-----
select distinct Ticket_Price
from aviation_performance
where Ticket_Price is not null
  and Ticket_Price <> ''
order by Ticket_Price;

select
    min(Flight_Duration) as Min_Duration,
    max(Flight_Duration) as Max_Duration,
    min(Altitude) as Min_Altitude,
    max(Altitude) as Max_Altitude,
    min(Fuel_Consumption) as Min_Fuel,
    max(Fuel_Consumption) as Max_Fuel,
    min(Passenger_Count) as Min_Passengers,
    max(Passenger_Count) as Max_Passengers
from aviation_performance;

select
    Takeoff_Location,
    Destination,
    count(*) as Flight_Count,
    sum(case when Flight_Duration is not null then 1 else 0 end) as Observed_Duration,
    sum(case when Fuel_Consumption is not null then 1 else 0 end) as Observed_Fuel,
    sum(case when Passenger_Count is not null then 1 else 0 end) as Observed_Passengers
from aviation_performance
group by
    Takeoff_Location,
    Destination
order by Flight_Count desc;

create or alter view vw_Aviation_Analytics as

with BaseData as
(
    select
        Flight_ID,
        Takeoff_Location,
        Destination,
        Flight_Duration,
        Altitude,
        Longitude,
        Latitude,
        Fuel_Consumption,
        try_convert(float, nullif(Ticket_Price, '')) as Ticket_Price,
        Passenger_Count
    from aviation_performance
),

RouteAverages AS
(
    select
        Takeoff_Location,
        Destination,

        avg(Flight_Duration) as Avg_Route_Duration,

        avg(Fuel_Consumption) as Avg_Route_Fuel,

        avg(Passenger_Count) as Avg_Route_Passengers

    from BaseData
    group by
        Takeoff_Location,
        Destination
),

DestinationTicketMedian as
(
   select distinct
        Destination,

        PERCENTILE_CONT(0.5)
        within group (order by Ticket_Price)
        over (partition by Destination) as Median_Destination_Ticket_Price

    from BaseData
    where Ticket_Price is not null
),

CleanedData as
(
    select
        b.Flight_ID,
        b.Takeoff_Location,
        b.Destination,

        concat(
            b.Takeoff_Location,
            ' → ',
            b.Destination
        ) as Route,

------------ Cleaned Flight Duration -----------------------------------------------------
        coalesce(
            b.Flight_Duration,
            r.Avg_Route_Duration
        ) as Flight_Duration,

------------ Cleaned Altitude ------------------------------------------------------------
        coalesce(
            b.Altitude,
            30000
        ) as Altitude,

        b.Longitude,
        b.Latitude,

------------ Cleaned Fuel Consumption -----------------------------------------------------
        coalesce(
            b.Fuel_Consumption,
            r.Avg_Route_Fuel
        ) as Fuel_Consumption,

------------   Cleaned Ticket Price ------------------------------------------------------
        coalesce(
            b.Ticket_Price,
            d.Median_Destination_Ticket_Price
        ) as Ticket_Price,

------------ Cleaned Passenger Count -----------------------------------------------------
        coalesce(
            b.Passenger_Count,
            r.Avg_Route_Passengers
        ) as Passenger_Count,

-------------  Imputation flags ----------------------------------------------------------

        case
            when b.Flight_Duration IS NULL then 1
            else 0
        end as Duration_Imputed,

        case
            when b.Altitude IS NULL then 1
            else 0
        end as Altitude_Imputed,

        case
            when b.Fuel_Consumption is null then 1
            else 0
        end as Fuel_Imputed,

        case
            when b.Ticket_Price is null then 1
            else 0
        end as Ticket_Price_Imputed,

        case
            when b.Passenger_Count is null then 1
             else 0
        end as Passenger_Imputed

    from BaseData b

    left join RouteAverages r
        on b.Takeoff_Location = r.Takeoff_Location
        and b.Destination = r.Destination

    left join DestinationTicketMedian d
        on b.Destination = d.Destination
)

select
    *,
 -------------------------  COMMERCIAL METRICS-------------------------

    Ticket_Price * Passenger_Count
        as Gross_Revenue,

    (Ticket_Price * Passenger_Count)
        as Revenue_Per_Flight,

    (Ticket_Price * Passenger_Count)
        / nullif(Flight_Duration, 0)
        as Revenue_Per_Flight_Hour,

------------------------- Operational metrics  -------------------------

    Fuel_Consumption
        / nullif(Passenger_Count, 0)
        as Fuel_Per_Passenger,

    Fuel_Consumption
        / nullif(Flight_Duration, 0)
        as Fuel_Per_Flight_Hour,

------------------------- Commercial efficiency ------------------------- 

    (Ticket_Price * Passenger_Count)
        / nullif(Fuel_Consumption, 0)
        as Revenue_Per_Unit_Fuel

from CleanedData;

select top 10 *
from vw_Aviation_Analytics

---------------  Validate the analytical view ------------------------------------------
select
    count(*) as Total_Rows,
    count(distinct Flight_ID) as Unique_Flights,

    sum(case when Flight_Duration is null then 1 else 0 end) as Missing_Duration,
    sum(case when Altitude is null then 1 else 0 end) as Missing_Altitude,
    sum(case when Fuel_Consumption is null then 1 else 0 end) as Missing_Fuel,
    sum(case when Ticket_Price is null then 1 else 0 end) as Missing_Ticket_Price,
    sum(case when Passenger_Count is null then 1 else 0 end) as Missing_Passengers,

    sum(Duration_Imputed) as Duration_Imputed,
    sum(Altitude_Imputed) as Altitude_Imputed,
    sum(Fuel_Imputed) as Fuel_Imputed,
    sum(Ticket_Price_Imputed) as Ticket_Price_Imputed,
    sum(Passenger_Imputed) as Passenger_Imputed,

    min(Gross_Revenue) as Min_Revenue,
    max(Gross_Revenue) as Max_Revenue,

    min(Fuel_Per_Passenger) as Best_Fuel_Per_Passenger,
    max(Fuel_Per_Passenger) as Worst_Fuel_Per_Passenger
from vw_Aviation_Analytics;


select
    Flight_ID,
    count(*) as Row_Count
from vw_Aviation_Analytics
group by Flight_ID
having count(*) > 1;

---------------- Building the Route Performance Layer ------------------------------
create view vw_Aviation_Route_Performance as

select
    Route,
    Takeoff_Location,
    Destination,

    count(*) as Flight_Count,

    avg(Flight_Duration) as Avg_Flight_Duration,
    avg(Altitude) as Avg_Altitude,

    avg(Passenger_Count) as Avg_Passengers,
    sum(Passenger_Count) as Total_Passengers,

    avg(Ticket_Price) as Avg_Ticket_Price,
    sum(Gross_Revenue) as Total_Gross_Revenue,

    avg(Fuel_Consumption) as Avg_Fuel_Consumption,

    avg(Fuel_Per_Passenger) as Avg_Fuel_Per_Passenger,
    avg(Fuel_Per_Flight_Hour) as Avg_Fuel_Per_Flight_Hour,
    avg(Revenue_Per_Flight_Hour) as Avg_Revenue_Per_Flight_Hour,
    avg(Revenue_Per_Unit_Fuel) as Avg_Revenue_Per_Unit_Fuel

from vw_Aviation_Analytics

group by
    Route,
    Takeoff_Location,
    Destination;

select *
from vw_Aviation_Route_Performance
order by Total_Gross_Revenue desc;-- Which routes generate commercial value efficiently, and which ones deserve management attention?

-------------- Route Performance Analysis with opportunity categorization based on revenue and fuel efficiency
with RouteStats as (
    select
        *,
        PERCENTILE_CONT(0.5) within group
            (order by Total_Gross_Revenue)
            over () as Revenue_Median,

        PERCENTILE_CONT(0.5) within group
            (order by Avg_Fuel_Per_Passenger)
            over () as Fuel_Efficiency_Median
    from vw_Aviation_Route_Performance
)

select distinct
    Route,
    Flight_Count,
    Total_Passengers,
    Total_Gross_Revenue,
    Avg_Fuel_Per_Passenger,
    Avg_Revenue_Per_Unit_Fuel,

    case
        when Total_Gross_Revenue >= Revenue_Median
             and Avg_Fuel_Per_Passenger <= Fuel_Efficiency_Median
            then 'High Commercial / High Efficiency'

        when Total_Gross_Revenue >= Revenue_Median
             and Avg_Fuel_Per_Passenger > Fuel_Efficiency_Median
            then 'High Commercial / Low Efficiency'

        when Total_Gross_Revenue < Revenue_Median
             and Avg_Fuel_Per_Passenger <= Fuel_Efficiency_Median
            then 'Low Commercial / High Efficiency'

        else 'Low Commercial / Low Efficiency'
    end as Opportunity_Category

from RouteStats

order by Total_Gross_Revenue desc;

------------------- Identify routes with high commercial value but low fuel efficiency for management attention
select
    Route,
    Flight_Count,
    Total_Passengers,
    Total_Gross_Revenue,

    Total_Gross_Revenue / nullif(Flight_Count, 0)
        as Revenue_Per_Flight,

    Total_Passengers / nullif(Flight_Count, 0)
        as Passengers_Per_Flight,

    Avg_Fuel_Per_Passenger,
    Avg_Revenue_Per_Unit_Fuel

from vw_Aviation_Route_Performance

order by Revenue_Per_Flight desc;

------------------ Checking the overall averages for route performance metrics
select
    avg(Total_Gross_Revenue) as Avg_Route_Revenue,
    avg(Total_Gross_Revenue / nullif(Flight_Count, 0)) as Avg_Revenue_Per_Flight,
    avg(Total_Passengers / nullif(Flight_Count, 0)) as Avg_Passengers_Per_Flight,
    avg(Avg_Fuel_Per_Passenger) as Avg_Fuel_Per_Passenger,
    avg(Avg_Revenue_Per_Unit_Fuel) as Avg_Revenue_Per_Unit_Fuel
from vw_Aviation_Route_Performance;

------------------ Building the Management Opportunity View -------------------------
create or alter view vw_Aviation_Management_Opportunities as

with Benchmarks as (
        select
        avg(Total_Gross_Revenue / nullif (Flight_Count, 0))
            as Benchmark_Revenue_Per_Flight,

        avg(Avg_Fuel_Per_Passenger)
            as Benchmark_Fuel_Per_Passenger,

        avg(Avg_Revenue_Per_Unit_Fuel)
            as Benchmark_Revenue_Per_Unit_Fuel

    from vw_Aviation_Route_Performance
),

RouteMetrics as (
    select
        r.Route,
        r.Takeoff_Location,
        r.Destination,
        r.Flight_Count,
        r.Total_Passengers,
        r.Total_Gross_Revenue,

        r.Total_Gross_Revenue / nullif(r.Flight_Count, 0)
            as Revenue_Per_Flight,

        r.Total_Passengers / nullif(r.Flight_Count, 0)
            as Passengers_Per_Flight,

        r.Avg_Fuel_Per_Passenger
            as Route_Fuel_Per_Passenger,

        r.Avg_Revenue_Per_Unit_Fuel
           as Route_Revenue_Per_Unit_Fuel,

        b.Benchmark_Revenue_Per_Flight,
        b.Benchmark_Fuel_Per_Passenger,
        b.Benchmark_Revenue_Per_Unit_Fuel

    from vw_Aviation_Route_Performance r
   cross join Benchmarks b
)

select
    Route,
    Takeoff_Location,
    Destination,
    Flight_Count,
    Total_Passengers,
    Total_Gross_Revenue,
    Revenue_Per_Flight,
    Passengers_Per_Flight,
    Route_Fuel_Per_Passenger as Avg_Fuel_Per_Passenger,
    Route_Revenue_Per_Unit_Fuel as Avg_Revenue_Per_Unit_Fuel,

    case
       when Revenue_Per_Flight >= Benchmark_Revenue_Per_Flight
            and Route_Fuel_Per_Passenger <= Benchmark_Fuel_Per_Passenger
            then 'Core Performer'

        when Revenue_Per_Flight >= Benchmark_Revenue_Per_Flight
            and Route_Fuel_Per_Passenger > Benchmark_Fuel_Per_Passenger
            then 'Commercial Value - Efficiency Concern'

        when Revenue_Per_Flight < Benchmark_Revenue_Per_Flight
             and Route_Fuel_Per_Passenger <= Benchmark_Fuel_Per_Passenger
            then 'Efficient - Commercial Opportunity'

        else 'Priority Review'
    end as Management_Category,

   case
        when Revenue_Per_Flight >= Benchmark_Revenue_Per_Flight
            and Route_Fuel_Per_Passenger > Benchmark_Fuel_Per_Passenger
            then 'Investigate fuel efficiency while protecting commercial demand'

        when Revenue_Per_Flight < Benchmark_Revenue_Per_Flight
             and Route_Fuel_Per_Passenger <= Benchmark_Fuel_Per_Passenger
            then 'Review pricing, demand generation, or route frequency'

        when Revenue_Per_Flight < Benchmark_Revenue_Per_Flight
             and Route_Fuel_Per_Passenger > Benchmark_Fuel_Per_Passenger
           then 'Review route economics, demand and operating efficiency'

        else 'Maintain performance and evaluate opportunities for growth'
    end as Management_Action

from RouteMetrics;
select *
from vw_Aviation_Management_Opportunities
order by
    case Management_Category
        when 'Commercial Value - Efficiency Concern' then 1
        when 'Priority Review' then 2
        when 'Efficient - Commercial Opportunity' then 3
        when 'Core Performer' then 4
    end,
    Revenue_Per_Flight desc;