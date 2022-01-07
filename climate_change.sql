--1)Let’s start by looking at how the average temperature changes over time in each state.
---Write a query that returns the state, year, tempf or tempc, and running_avg_temp (in either Celsius or Fahrenheit) for each state.
SELECT state,
  year,
  ROUND(tempc, 2) AS tempc,
  ROUND(AVG(tempc) OVER (
    PARTITION BY state
    ORDER BY year), 2) AS 'running_avg_temp'
FROM state_climate;

--2)Now let’s explore the lowest temperatures for each state.
---Write a query that returns state, year, tempf or tempc, and the lowest temperature (lowest_temp) for each state. 
---Are the lowest recorded temps for each state more recent or more historic? HISTORIC
SELECT state,
  year,
  ROUND(MIN(tempc), 2) AS 'lowest_temp'
FROM state_climate
GROUP BY state
ORDER BY state;

--3)Like before, write a query that returns state, year, tempf or tempc, except now we will also return the highest temperature (highest_temp) for each state.
---Are the highest recorded temps for each state more recent or more historic? RECENT
SELECT state,
  year,
  ROUND(MAX(tempc), 2) AS 'highest_temp'
FROM state_climate
GROUP BY state
ORDER BY year;

--4)Let’s see how temperature has changed each year in each state.
--Write a query to select the same columns but now you should write a window function that returns the change_in_temp from the previous year (no null values should be returned).
--Which states and years saw the largest changes in temperature? MINNESOTA IN 2013
--Is there a particular part of the United States that saw the largest yearly changes in temperature? THE NORTHER MIDDLE STATES
SELECT state,
  year,
  ROUND(tempc, 2) AS 'tempc',
  ROUND(tempc - LAG(tempc, 1, 0) OVER (
    PARTITION BY state
    ORDER BY year
  ), 2) AS 'change_in temp'
FROM state_climate
ORDER BY 4;

--5)Write a query to return a rank of the coldest temperatures on record (coldest_rank) along with year, state, and tempf or tempc.
--Are the coldest ranked years recent or historic? HISTORIC.
SELECT RANK() OVER (
    ORDER BY tempc) AS 'coldest_rank',
    state,
    year,
    ROUND(tempc, 2) AS 'tempc'
FROM state_climate;

--6)Modify your coldest_rank query to now instead return the warmest_rank for each state, meaning your query should return the warmest temp/year for each state.
---Again, are the warmest temperatures more recent or historic for each state? RECENT
SELECT RANK() OVER (
    PARTITION BY state
    ORDER BY tempc DESC) AS 'warmest_rank',
    state,
    year,
    ROUND(tempc, 2) AS 'tempc'
FROM state_climate;

--7)Let’s now write a query that will return the average yearly temperatures in quartiles instead of in rankings for each state.
---Your query should return quartile, year, state and tempf or tempc. The top quartile should be the coldest years. Are the coldest years more recent or historic? HISTORIC
SELECT NTILE(4) OVER (
    PARTITION BY state
    ORDER BY tempc) AS 'coldest_quartile',
    state,
    year,
    ROUND(tempc, 2) AS 'tempc'
FROM state_climate;

--8)Lastly, we will write a query that will return the average yearly temperatures in quintiles (5).
---Your query should return quintile, year, state and tempf or tempc. The top quintile should be the coldest years overall, not by state.
---What is different about the coldest quintile now? AT THE TOP WE CAN FIND THE COLDEST YEARS WITHOUT TAKING INTO ACCOUNT THE STATE
SELECT NTILE(5) OVER (
    ORDER BY tempc) AS 'coldest_quintile',
    state,
    year,
    ROUND(tempc, 2) AS 'tempc'
FROM state_climate;