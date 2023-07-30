SELECT *
FROM PortfolioProject..CovidDeaths
Where continent is not NULL
ORDER BY 3,4

--SELECT *
--FROM PortfolioProject..CovidVaccination
--ORDER BY 3,4

--Select Data that we are going to be using

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
Where continent is not NULL
ORDER BY 1,2


-- Looking at Total Cases vs Total Deaths
-- Show the likelihood of dying if you contract covid inyour country

SELECT location, date, total_cases, total_deaths, (cast(total_deaths as float)/cast(total_cases as float))*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
-- WHERE location like '%state%'
Where continent is not NULL
ORDER BY 1,2

-- Looking at the total cases vs the population
-- Show what percentage of population got Covid
SELECT location, date, total_cases, population, (cast(total_cases as float)/cast(population as float))*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
-- WHERE location like '%state%'
Where continent is not NULL
ORDER BY 1,2 



-- Looking at Countries with the highest infection rate compared to population

SELECT location, population, MAX(total_cases) as HighestInfectionCountry, MAX(cast(total_cases as float)/cast(population as float))*100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
-- WHERE location like '%state%'
Where continent is not NULL
GROUP BY Location, Population
ORDER BY PercentPopulationInfected DESC


-- Showing Countries with Highhest Death Count per population

SELECT Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
-- WHERE location like '%state%'
Where continent is not NULL
GROUP BY Location 
ORDER BY TotalDeathCount DESC



-- LET'S BREAK THINGS DOWN BY CONTINENT


-- Showing continents with the highest death count per population
	
SELECT continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
-- WHERE location like '%state%'
Where continent is not NULL
GROUP BY continent 
ORDER BY TotalDeathCount DESC




-- GLOBAL NUMBERS


SELECT SUM(cast(new_cases as int)) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, 
CASE WHEN SUM(cast(new_cases as int)) = 0 THEN 0
ELSE SUM(cast(new_deaths as float))/SUM(cast(new_cases as float))*100 END as DeathPercentageas
FROM PortfolioProject..CovidDeaths
-- WHERE location like '%state%'
WHERE continent is not NULL
-- GROUP BY date
ORDER BY 1,2


-- Looking at Total Poppulation Vs Vaccinations

-- USE CTE

With PopVsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS 
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(float,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100 as 
From PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccination vac
ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3
)

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopVsVac

-- TEMP TABLE

DROP Table if exists #PercentPopulationVaccinated

Create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date Datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)


Insert into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(float,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100 as 
From PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccination vac
ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated


-- Creating view to store data for later visualization

Create View PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(float,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100 as 
From PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccination vac
ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3


Select * 
From PercentPopulationVaccinated