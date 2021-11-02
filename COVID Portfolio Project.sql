SELECT * FROM [Portfolio Projects]..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3,4

SELECT Location, date,total_cases, new_cases, total_deaths, population
FROM [Portfolio Projects]..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2

--Looking at Total Cases VS Total Deaths
SELECT Location, date,total_cases, total_deaths, (total_deaths/total_cases)*100 as PercentDeath
FROM [Portfolio Projects]..CovidDeaths
WHERE continent IS NOT NULL AND location like '%Nigeria%'
ORDER BY 1,2

--Looking at Total Cases VS Population in Nigeria
SELECT Location, date,total_cases, population, (total_cases/population)*100 as PercentPopInfected
FROM [Portfolio Projects]..CovidDeaths
WHERE continent IS NOT NULL AND location like '%Nigeria%'
ORDER BY 1,2

--Countries with highest infection rate compared to population
SELECT Location, population, MAX(total_cases) AS HighestInfectionCount, MAX(total_cases/population)*100 as PercentPopInfected
FROM [Portfolio Projects]..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY Location, population
ORDER BY PercentPopInfected DESC

--Countries with highest death count by population
SELECT Location, MAX(cast(total_deaths AS int)) AS HighestDeathCount
FROM [Portfolio Projects]..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY Location
ORDER BY HighestDeathCount DESC

--Continents with highest death counts by population
SELECT continent, MAX(cast(total_deaths AS int)) AS HighestDeathCount
FROM [Portfolio Projects]..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY HighestDeathCount DESC

--Global Cases and Deaths as at October 27th 2021
SELECT SUM(new_cases) AS Total_cases,SUM(cast(new_deaths AS int)) AS total_deaths, (SUM(cast(new_deaths AS int))/SUM(new_cases))*100 as Death_percentage
FROM [Portfolio Projects]..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2

--Global Cases and Deaths per day
SELECT date,SUM(new_cases) AS Total_cases,SUM(cast(new_deaths AS int)) AS total_deaths, (SUM(cast(new_deaths AS int))/SUM(new_cases))*100 as Death_percentage
FROM [Portfolio Projects]..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2

--Number of people who have been vaccinated by location

--Using CTE

WITH PopVac (Continent, Location, Date, Population, New_vaccinations, PeopleVaccinated)
AS
(
SELECT D.continent, D.location, D.date, D.population, V.new_vaccinations, SUM(cast(V.new_vaccinations AS int)) OVER (PARTITION BY D.location 
ORDER BY D.location, D.date) AS PeopleVaccinated 
FROM [Portfolio Projects]..CovidDeaths D
JOIN [Portfolio Projects]..CovidVaccinations V
	ON D.location = V.location
	AND D.date = V.date
WHERE D.continent IS NOT NULL
)
SELECT *, (PeopleVaccinated/population)*100
FROM PopVac


--Using a Temp Table

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
PeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT D.continent, D.location, D.date, D.population, V.new_vaccinations, SUM(cast(V.new_vaccinations AS int)) OVER (PARTITION BY D.location 
ORDER BY D.location, D.date) AS PeopleVaccinated 
FROM [Portfolio Projects]..CovidDeaths D
JOIN [Portfolio Projects]..CovidVaccinations V
	ON D.location = V.location
	AND D.date = V.date
--WHERE D.continent IS NOT NULL

SELECT *, (PeopleVaccinated/population)*100
FROM #PercentPopulationVaccinated

--Creating a view to store data for vizualisation
CREATE VIEW PercentPopulationVaccinated AS
SELECT D.continent, D.location, D.date, D.population, V.new_vaccinations, SUM(cast(V.new_vaccinations AS int)) OVER (PARTITION BY D.location 
ORDER BY D.location, D.date) AS PeopleVaccinated 
FROM [Portfolio Projects]..CovidDeaths D
JOIN [Portfolio Projects]..CovidVaccinations V
	ON D.location = V.location
	AND D.date = V.date
WHERE D.continent IS NOT NULL

select * from PercentPopulationVaccinated