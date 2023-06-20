select * from portfolio..[covid data 1]
WHERE continent IS NOT NULL
order by 3,4

--select * from portfolio..[covid vac]
--order by 3,4

select location,date,total_deaths,total_cases_per_million,new_cases
from portfolio..[covid data 1]
WHERE continent IS NOT NULL
order by 1,2



-- looking at total cases vs total death
SELECT
  Location,
  date,
  MAX(population_density) AS population_density,
  MAX(total_cases_per_million) AS total_cases_per_million,
  CASE
    WHEN MAX(total_cases_per_million) = '0' OR MAX(total_cases_per_million) = '0.0' THEN 0
    ELSE (CONVERT(FLOAT, MAX(total_cases_per_million)) / NULLIF(CONVERT(FLOAT, MAX(population_density)), 0)) * 100
  END AS Percentagepopulationinf
FROM portfolio..[covid data 1]
--WHERE location LIKE '%india%'
GROUP BY Location, date
ORDER BY population_density ASC;


--- showing countries with highest death count per population
SELECT
  Location, MAX(CAST(total_deaths AS INT)) AS TOTALDEATHSCOUNT
FROM portfolio..[covid data 1]
WHERE continent IS NOT NULL AND location LIKE '%STATES%'
GROUP BY Location
ORDER BY TOTALDEATHSCOUNT DESC;


--- showing CONTINENT with highest death count per population
SELECT
  continent, MAX(CAST(total_deaths AS INT)) AS TOTALDEATHSCOUNT
FROM portfolio..[covid data 1]
WHERE continent IS NOT NULL 
GROUP BY continent
ORDER BY TOTALDEATHSCOUNT DESC;

--- GLOBAL NUMBERS

SELECT date,
       SUM(CAST(new_cases AS INT)) AS totalcases,
       SUM(CAST(new_deaths AS INT)) AS totaldeaths,
       CASE
           WHEN SUM(CAST(new_cases AS INT)) = 0 THEN 0
           ELSE (SUM(CAST(new_deaths AS INT)) / SUM(CAST(new_cases AS INT))) * 100
       END AS deathpercentages
FROM portfolio..[covid data 1]
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY date;

--total population vs vaccinated
with popvsvac (continents, location, date, population, new_vaccinations, rollingpopulationvac)
as (
SELECT dea.continent,
       dea.location,
       dea.date,
       dea.population,
       dea.new_vaccinations,
       SUM(CONVERT(BIGINT, dea.new_vaccinations)) OVER (PARTITION BY vac.location) as rollingpopulationvac
FROM portfolio..[covid vac] dea
JOIN portfolio..[covid data 1] vac
    ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY dea.location, dea.date
)
--with cte
select * from popvsvac;


