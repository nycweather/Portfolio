--$SPY S&P Fortune 500 etf stock analysis
--By Md Ahmed Khan
--5/15/22
--DATASET: https://finance.yahoo.com/quote/SPY/history/
--------------------------------------------------------------------
/*
Abstract
I will try to see if I can find some corrolation between weekdays, volume, and overall yearly performance has any corrolation with each other when it comes to price and volitility.
Imagine I am coming in as a complete newbie invester, mostly looking for long term investment for retirement.
Some questions I have are, if there is a specific time spy usually is at its weekly, monthly, yearly lowest so I can invest during those time periods in order to buy the stocks for cheaper than its average price.
Since we are not really trading the stock we want to see if there are corolations in price and time.
Over time we expect the stock to have a modest positive return overall. 
We can also look at the volitility of the stock incase we want to trade options.
Options such as spreads, covered calls or cash secured puts where we can expect the safest returns according to historical data.
We can also use this information to do further regression analysis inorder to better understand market trends and more recent historical data.

**This analysis ignores market trend, technical analysis or any positical/geograpical influences**
**This model can be used by someone who frequentyly invests, maybe through an automatic ROTH IRA**


*/
--Checking if the data loaded properly
SELECT *
FROM   spy.dbo.spy$

-- Adding dayname to the table
SELECT Format(date, 'dddd') AS Dayname,
       *
FROM   spy.dbo.spy$

--comparing highs and lows of the day to find the volitility
SELECT Format(date, 'dddd')           AS Dayname,
       *,
       ( ( high / low * 100 ) - 100 ) AS interday_volitility
FROM   spy.dbo.spy$

--most volitile day in the market
SELECT Format(date, 'dddd')           AS Dayname,
       *,
       ( ( high / low * 100 ) - 100 ) AS interday_volitility
FROM   spy.dbo.spy$
ORDER  BY interday_volitility DESC

--most volitile day in the market
SELECT Format(date, 'dddd')                AS Dayname,
       Avg(( ( high / low * 100 ) - 100 )) AS interday_volitility
FROM   spy.dbo.spy$
GROUP  BY Format(date, 'dddd')
ORDER  BY interday_volitility DESC

--most active day 
--interesting even though fridays are one of the most traded days of the week yet it remains one of relativly less volatile
SELECT Format(date, 'dddd') AS Dayname,
       Avg(volume)          AS avg_volume
FROM   spy.dbo.spy$
GROUP  BY Format(date, 'dddd')
ORDER  BY avg_volume DESC

--typically the worst day (or best day to buy) in the weekly low
--best to buy on fridays
SELECT Format(date, 'dddd') AS Dayname,
       Avg(low)             AS avg_price
FROM   spy.dbo.spy$
GROUP  BY Format(date, 'dddd')
ORDER  BY avg_price 


--typically the worst day (or best day to buy) in the weekly low
--best to buy on modays you save about 7 cents
SELECT Format(date, 'dddd') AS Dayname,
       Avg(open1-close1)          AS avg_discount
FROM   spy.dbo.spy$
GROUP  BY Format(date, 'dddd')
ORDER  BY avg_discount DESC

--Best time to buy using average
SELECT Format(date, 'dddd') AS Dayname,
       Avg(low)-(Avg(low)-Avg(open1-close1)*-1)          AS avg_discount
FROM   spy.dbo.spy$
GROUP  BY Format(date, 'dddd')
ORDER  BY avg_discount DESC
