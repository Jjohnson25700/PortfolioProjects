SELECT *
FROM PortfolioPoject..CovidDeaths$
where continent is not null
ORDER BY 3,4

--SELECT *
--FROM PortfolioPoject..CovidVaccinations$
--ORDER BY 3,4

--Select data that is needed for the project

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioPoject..CovidDeaths$
where continent is not null
ORDER BY 1,2

--Looking at Total cases vs Total Deaths

SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioPoject..CovidDeaths$
WHERE location LIKE '%Nigeria%'
and continent is not null
ORDER BY 1,2

--Looking at the total case vs Population
--Show what percentage of population got covid

SELECT Location, date, total_cases, population, (total_cases/population)*100 as PercentPopulationInfected
FROM PortfolioPoject..CovidDeaths$
WHERE location LIKE '%Nigeria%'
ORDER BY 1,2

--Looking at contries with highest infection rate compair to Population

SELECT Location, population, MAX(total_cases) as HighestInfectionCount, MAX(total_cases/population)*100 as PercentPopulationInfected
FROM PortfolioPoject..CovidDeaths$
--WHERE location LIKE '%Nigeria%'
GROUP BY location,population
ORDER BY PercentPopulationInfected desc


--Showing countries with the highest death count 

SELECT Location, MAX(CAST(total_deaths as int)) as TotalDeathCount
FROM PortfolioPoject..CovidDeaths$
--WHERE location LIKE '%Nigeria%'
where continent is not null
GROUP BY location
ORDER BY TotalDeathCount desc

--Where continent is not null

SELECT location, MAX(CAST(total_deaths as int)) as TotalDeathCount
FROM PortfolioPoject..CovidDeaths$
--WHERE location LIKE '%Nigeria%'
where continent is not null
GROUP BY location
ORDER BY TotalDeathCount desc

--Breaking things down by continent

SELECT continent, MAX(CAST(total_deaths as int)) as TotalDeathCount
FROM PortfolioPoject..CovidDeaths$
--WHERE location LIKE '%Nigeria%'
where continent is null
GROUP BY continent
ORDER BY TotalDeathCount desc

--Breaking things down by Location

SELECT location, MAX(CAST(total_deaths as int)) as TotalDeathCount
FROM PortfolioPoject..CovidDeaths$
--WHERE location LIKE '%Nigeria%'
where continent is null
GROUP BY location
ORDER BY TotalDeathCount desc

--Showiing the continent withnthe highest death rate

SELECT continent, MAX(CAST(total_deaths as int)) as TotalDeathCount
FROM PortfolioPoject..CovidDeaths$
--WHERE location LIKE '%Nigeria%'
where continent is null
GROUP BY continent
ORDER BY TotalDeathCount desc

--Global Number

SELECT date, SUM(new_cases) as total_cases, SUM(CAST(new_deaths as int)) as total_deaths, SUM(CAST(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM PortfolioPoject..CovidDeaths$
--WHERE location LIKE '%Nigeria%'
where continent is not null
GROUP BY DATE
ORDER BY 1,2

--Total cases

SELECT SUM(new_cases) as total_cases, SUM(CAST(new_deaths as int)) as total_deaths, SUM(CAST(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM PortfolioPoject..CovidDeaths$
--WHERE location LIKE '%Nigeria%'
where continent is not null
ORDER BY 1,2

--Looking at total Population and Vaccinations

SELECT *
FROM PortfolioPoject..CovidDeaths$ dea
JOIN PortfolioPoject..CovidVaccinations$ vac
ON dea.location = vac.location
and dea.date = vac.date

--Use a CTE

With PopvsVac (continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated) 
as 
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(new_vaccinations as int)) OVER (Partition by dea.Location ORDER BY dea.Location, dea.date) as RollingPeopleVaccinated
FROM PortfolioPoject..CovidDeaths$ dea
JOIN PortfolioPoject..CovidVaccinations$ vac
  ON dea.location = vac.location
  and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/Population)*10
FROM PopvsVac

--Temp Table

Drop Table if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(new_vaccinations as int)) OVER (Partition by dea.Location ORDER BY dea.Location, dea.date) as RollingPeopleVaccinated
FROM PortfolioPoject..CovidDeaths$ dea
JOIN PortfolioPoject..CovidVaccinations$ vac
  ON dea.location = vac.location
  and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/Population)*10
FROM #PercentPopulationVaccinated


--Creating views to store data for latter visualizations

Create  view PercentPopulationvaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(new_vaccinations as int)) OVER (Partition by dea.Location ORDER BY dea.Location, dea.date) as RollingPeopleVaccinated
FROM PortfolioPoject..CovidDeaths$ dea
JOIN PortfolioPoject..CovidVaccinations$ vac
  ON dea.location = vac.location
  and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3

SELECT *
FROM PercentPopulationvaccinated