SELECT *
FROM PortfolioProject..CovidDeaths
order by 3, 4

--SELECT *
--FROM PortfolioProject..CovidVaccinations
--order by 3, 4

--Select Data that we are going to be using
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2

-- Looking at the Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%france%' and continent <> ''
ORDER BY 1, 2

-- Observation: For "France", missing or "incoherent" values at the beginning (2020-03-01)
-- "Incoherent" since total deaths superior to total cases
-- Could be due to the lack of data and detection of cases at the beginning of the epidemy



-- Looking at the Total Cases vs Population
-- Shows what percentage of population got Covid
SELECT location, date, population, total_cases,  (total_cases/population)*100 AS PercentPoluationInfected
FROM PortfolioProject..CovidDeaths
--WHERE location like '%france%' and continent <> ''
ORDER BY 1, 2


-- Looking at Countries with Highest Infection Rate compared to Population
SELECT location, population, MAX(total_cases) AS HighestInfectionCount,  MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
WHERE continent <> ''
GROUP BY location, population
ORDER BY 4 desc

-- Looking at Countries with the Highest Death Count per Population
SELECT location, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent <> ''
GROUP BY location
ORDER BY TotalDeathCount desc

--  BREAK THINGS DOWN BY CONTINENT

-- Showing continents with the highest death count per population

SELECT continent, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent <> ''
GROUP BY continent
ORDER BY TotalDeathCount desc

-- GLOBAL NUMBERS

SELECT SUM(new_cases) AS Total_cases, SUM(cast (new_deaths as int)) AS Total_deaths, SUM(cast (new_deaths as int))/(NULLIF(SUM(new_cases),0))*100 AS WorldDeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent <> '' 
-- GROUP BY date
ORDER BY 1, 2

-- Looking at Total Population vs Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100 --not possible to use a created column without using a CTE or temp table
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent <> '' 
ORDER BY 2, 3

-- Use CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent <> '' 
-- ORDER BY 2, 3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac


-- Use Temp Table

Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations nvarchar(255),
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent <> '' 

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

-- Creating View to store data for later visualization (Tableau, ...)

Create View PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent <> '' 
-- ORDER BY 2, 3

-- View are permanent, contrary to temp table, and can be accessed any time

Select *
From PercentPopulationVaccinated
