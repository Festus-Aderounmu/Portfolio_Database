 SELECT * FROM Covid_Deaths ORDER BY 3, 4

 --SELECT * FROM Covid_Vaccinations ORDER BY 3, 4

 -- Select data that we are going to using 

 SELECT location, date, total_cases, new_cases, total_deaths, population FROM Covid_Deaths ORDER BY 1, 2

 -- Looking at total_cases Vs total_deaths
 -- showing likelihood of dying if contract covid-19 in United States

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 death_percentage FROM Covid_Deaths WHERE location LIKE '%states%' ORDER BY 1, 2

-- Looking at the total cases VS population
-- showing the percentage of population contracted(infected) with COVID-19

SELECT location, date, population, total_cases, (total_cases/population)* 100 cases_percentage 
FROM Covid_Deaths 
-- WHERE location LIKE '%states%' 
ORDER BY 1, 2

-- looking at countries with highest infection rate compared with population
-- showing counties with highest infection percentage rate

SELECT location, population, MAX(total_cases) highest_infection, MAX((total_cases/population))* 100 infection_percentage
FROM Covid_Deaths 
-- WHERE location LIKE '%states%' 
GROUP BY location, population
ORDER BY 4 DESC

-- Showing Countries with highest death count per population

SELECT location, MAX(CAST(total_deaths AS INT)) highest_death FROM Covid_Deaths
-- WHERE location LIKE '%states%' 
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY highest_death DESC

-- Insight into the continent

SELECT * FROM Covid_Deaths WHERE continent is NOT NULL

-- Showing Continent with higest death case

SELECT continent, MAX(CAST(total_deaths AS INT)) highest_death FROM Covid_Deaths
-- WHERE location LIKE '%states%' 
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY highest_death DESC

-- showing location with higher fatality rate

SELECT location, MAX(CAST(total_deaths AS INT)) highest_death FROM Covid_Deaths
-- WHERE location LIKE '%states%' 
WHERE continent IS  NULL
GROUP BY location
ORDER BY highest_death DESC

-- Global numbers

SELECT date, SUM(new_cases) summation_cases, SUM(CAST(new_deaths AS INT)) total_deaths, SUM(CAST(new_deaths AS INT))/SUM(new_cases) * 100 AS death_percentage 
FROM Covid_Deaths 
-- WHERE location LIKE '%states%'
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1


SELECT SUM(new_cases) summation_cases, SUM(CAST(new_deaths AS INT)) summation_deaths, SUM(CAST(new_deaths AS INT))/SUM(new_cases) * 100 AS death_percentage 
FROM Covid_Deaths 
-- WHERE location LIKE '%states%'
WHERE continent IS NOT NULL
-- GROUP BY date
ORDER BY 1, 2

-- Joining covid-deaths VS covid-vaccinations

SELECT * FROM Covid_Deaths D JOIN Covid_Vaccinations V ON D.location = V.location AND D.date = V.date

-- Looking at the Total Population VS Vaccinations

SELECT D.continent, D.location, D.date, D.population, V.new_vaccinations, 
SUM(CAST(V.new_vaccinations AS INT)) OVER(PARTITION BY D.location ORDER BY D.location, D.date) AS Rolling_vaccinations 
FROM Covid_Deaths D 
JOIN Covid_Vaccinations V 
ON D.location = V.location 
AND D.date = V.date
WHERE D.continent IS NOT NULL
ORDER BY 2, 3

--OR

SELECT D.continent, D.location, D.date, D.population, V.new_vaccinations, 
SUM(CONVERT(INT,V.new_vaccinations)) OVER(PARTITION BY D.location ORDER BY D.location, D.date)  AS rolling_vaccinations
FROM Covid_Deaths D 
JOIN Covid_Vaccinations V 
ON D.location = V.location 
AND D.date = V.date
WHERE D.continent IS NOT NULL
ORDER BY 2, 3


-- Use CTE

WITH PopVsVac (continent, location, date, population, new_vaccinations, rolling_vaccinations)
AS
(
SELECT D.continent, D.location, D.date, D.population, V.new_vaccinations, 
SUM(CONVERT(INT,V.new_vaccinations)) OVER(PARTITION BY D.location ORDER BY D.location, D.date)  AS rolling_vaccinations
FROM Covid_Deaths D 
JOIN Covid_Vaccinations V 
ON D.location = V.location 
AND D.date = V.date
WHERE D.continent IS NOT NULL
-- ORDER BY 2, 3
)
SELECT *, (rolling_vaccinations/population) * 100 
FROM PopVsVac

-- TEMP TABLE

CREATE Table #percentpopulationvaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime, 
population numeric,
new_vaccinations numeric,
rolling_vaccination numeric 
)

INSERT INTO #percentpopulationvaccinated
SELECT D.continent, D.location, D.date, D.population, V.new_vaccinations, 
SUM(CONVERT(INT,V.new_vaccinations)) OVER(PARTITION BY D.location ORDER BY D.location, D.date)  AS rolling_vaccinations
FROM Covid_Deaths D 
JOIN Covid_Vaccinations V 
ON D.location = V.location 
AND D.date = V.date
WHERE D.continent IS NOT NULL
-- ORDER BY 2, 3

SELECT*, (rolling_vaccination/population) * 100 FROM #percentpopulationvaccinated

--DROP IF EXIST 

DROP TABLE IF EXISTS #summation_deaths
CREATE Table #summation_deaths
(
date datetime, 
summations_cases numeric,
total_deaths numeric,
deaths_percentage numeric 
)
INSERT INTO #summation_deaths
SELECT date, SUM(new_cases) summation_cases, SUM(CAST(new_deaths AS INT)) total_deaths, SUM(CAST(new_deaths AS INT))/SUM(new_cases) * 100 AS death_percentage 
FROM Covid_Deaths 
-- WHERE location LIKE '%states%'
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1

SELECT * FROM #summation_deaths

SELECT *, (total_deaths/summations_cases) * 100 FROM #summation_deaths

CREATE VIEW PercentPopulationVaccinated AS
SELECT D.continent, D.location, D.date, D.population, V.new_vaccinations, 
SUM(CONVERT(INT,V.new_vaccinations)) OVER(PARTITION BY D.location ORDER BY D.location, D.date)  AS rolling_vaccinations
FROM Covid_Deaths D 
JOIN Covid_Vaccinations V 
ON D.location = V.location 
AND D.date = V.date
WHERE D.continent IS NOT NULL
-- ORDER BY 2, 3

SELECT * FROM PercentPopulationVaccinated