--COVID-19 GLOBAL CASES PORTFOLIO PROJECT
--Dataset https://ourworldindata.org/covid-deaths (4/24/2022)
--By Md Ahmed Khan 
--////////////////////////////////////////////////////////////////--

--Checking if all the data was stored correctly
SELECT *
FROM   covidcasesproject.dbo.covid_deaths$
ORDER  BY 3,
          4 

SELECT *
FROM   covidcasesproject.dbo.covid_vaccines$
ORDER  BY 3,
          4 



--Selecting specific data we will work with
SELECT location,
       date,
       total_cases,
       new_cases,
       total_deaths,
       population
FROM   covidcasesproject.dbo.covid_deaths$
WHERE  continent IS NOT NULL
ORDER  BY 1,
          2 



--Total Cases vs Total Deaths to see the percentage of fatality for ones that are infected
SELECT location,
       date,
       total_cases,
       total_deaths,
       Round(( ( total_deaths / total_cases ) * 100 ), 4) AS Fatality_Percentage
FROM   covidcasesproject.dbo.covid_deaths$
ORDER  BY 1,
          2



--Total cases vs Population to determine the percentage of people infected
SELECT location,
	   date,
       population,
       total_cases,
       total_deaths,
       Round(( ( total_cases / population ) * 100 ), 4) AS Infected_Percentage
FROM   covidcasesproject.dbo.covid_deaths$
ORDER  BY 1,
          2 



--Countries with the most infected relative to population
SELECT location,
       population,
       Max(total_cases)                            AS Peak_Infection_Count,
       ( ( Max(total_cases) / population ) * 100 ) AS Infected_Percentage
FROM   covidcasesproject.dbo.covid_deaths$
GROUP  BY location,
          population
ORDER  BY infected_percentage DESC 



--Countires with the most deaths relative to population
SELECT location,
       population,
       Max(Cast(total_deaths AS BIGINT))                         AS Deaths,
       ((Max(Cast(total_deaths AS BIGINT)) / population) * 100 ) AS Death_Percentage
FROM   covidcasesproject.dbo.covid_deaths$
Where continent is not null
GROUP  BY location,
          population
ORDER  BY Deaths DESC 



--Continent deaths
SELECT location,
       Max(Cast(total_deaths AS BIGINT)) AS Deaths
FROM   covidcasesproject.dbo.covid_deaths$
WHERE  continent IS NULL
GROUP  BY location
ORDER  BY deaths DESC 



--Global numbers
SELECT date,
       Sum(new_cases)                                      AS Cases,
       Sum(Cast(new_deaths AS INT))                        AS Deaths,
       Sum(Cast(new_deaths AS INT)) / Sum(new_cases) * 100 AS Death_Percentage
FROM   covidcasesproject.dbo.covid_deaths$
WHERE  continent IS NOT NULL
GROUP  BY date
ORDER  BY date 


SELECT Sum(new_cases)                                      AS total_cases,
       Sum(Cast(new_deaths AS INT))                        AS total_deaths,
       Sum(Cast(new_deaths AS INT)) / Sum(new_cases) * 100 AS DeathPercentage
FROM   covidcasesproject.dbo.covid_deaths$
WHERE  continent IS NOT NULL
GROUP  BY date
ORDER  BY 1,
          2 



--Joining the two tables
SELECT vaccine.Continent,
       death.Location,
       death.Date,
       death.Population,
       death.New_cases,
       vaccine.New_vaccinations
FROM   covidcasesproject.dbo.covid_deaths$ death
       JOIN covidcasesproject.dbo.covid_vaccines$ vaccine
         ON death.Location = vaccine.Location
            AND death.Date = vaccine.Date
ORDER  BY 2,
          3 



-- Using CTE to perform Calculation on Partition By in previous query to 
-- find the vaccination percentage of each country
WITH popvsvac (Continent, Location, Date, Population, New_Vaccinations,
     Vaccination_Count)
     AS (SELECT death.continent,
                death.location,
                death.date,
                death.population,
                vaccine.new_vaccinations,
                Sum(CONVERT(BIGINT, vaccine.new_vaccinations))
                  OVER (
                    partition BY death.location
                    ORDER BY death.location, death.date) AS Vaccination_Count
         FROM   covidcasesproject.dbo.covid_deaths$ death
                JOIN covidcasesproject.dbo.covid_vaccines$ vaccine
                  ON death.location = vaccine.location
                     AND death.date = vaccine.date
         WHERE  death.continent IS NOT NULL
        )
SELECT *,
       ( vaccination_count / population ) * 100 AS Vaccination_Percentage
FROM   popvsvac 
ORDER BY 2,
		 3



-- Using Temp Table to perform Calculation on Partition By in previous query
DROP TABLE IF EXISTS #percentpopulationvaccinated
CREATE TABLE #percentpopulationvaccinated
             (
                          continent               nvarchar(255),
                          location                nvarchar(255),
                          date					  datetime,
                          population              numeric,
                          new_vaccinations        numeric,
                          rollingpeoplevaccinated numeric
             )INSERT INTO #percentpopulationvaccinated
SELECT   death.Continent,
         death.Location,
         death.Date,
         death.Population,
         vaccine.New_vaccinations ,
         Sum(CONVERT(BIGINT,vaccine.New_vaccinations)) 
		 OVER (partition BY Death.Location ORDER BY Death.Location, Death.Date) AS RollingPeopleVaccinated
FROM     covidcasesproject.dbo.covid_deaths$ death
JOIN     covidcasesproject.dbo.covid_vaccines$ vaccine
ON       death.Location = vaccine.Location
AND      death.Date = vaccine.Date
SELECT *,
       (Rollingpeoplevaccinated/Population)*100
FROM   #percentpopulationvaccinated



-- Creating View to store data for later visualizations
CREATE VIEW percentpopulationvaccinated
AS
  SELECT death.Continent,
         death.Location,
         death.Date,
         death.Population,
         vaccine.New_vaccinations,
         Sum(CONVERT(INT, vaccine.New_vaccinations))
           OVER (
             partition BY Death.location
             ORDER BY Death.location, Death.date) AS RollingPeopleVaccinated
  FROM   covidcasesproject.dbo.covid_deaths$ death
         JOIN covidcasesproject.dbo.covid_vaccines$ vaccine
           ON death.Location = vaccine.Location
              AND death.Date = vaccine.Date
  WHERE  death.Continent IS NOT NULL 