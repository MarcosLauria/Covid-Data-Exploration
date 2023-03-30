-- Total Cases x Total Deaths (How many people with Covid died)

Create View DeathPercentage as
SELECT Location, date, total_deaths, total_cases, (total_deaths/total_cases*100) as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
ORDER BY 1,2

-- Total Cases x Population (Percentage of population that has Covid)

Create View InfectedPercentage as
SELECT Location, date, total_cases, population, (total_cases/population*100) as InfectedPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
--ORDER BY 1,2

-- Countries with highest infection rates compared to Population

Create View HighestInfectedCountries as
SELECT Location, Population, MAX(total_cases) HighestInfectionCount, MAX(total_cases/population*100) as InfectedPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY Location, Population
--ORDER BY 4 desc

-- Countries with highest death count per Population

Create View HighestDeathCountries as
SELECT Location, MAX(CAST(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY Location
--ORDER BY 2 desc

-- Continents with the highest death count

Create View HighestInfectedContinents as
SELECT Continent, MAX(CAST(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY Continent
--ORDER BY 2 desc

-- Total Population x Vaccinations

Create View RollingPeopleVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CAST(vac.new_vaccinations as bigint)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3

-- CTE

CREATE VIEW VaccinatedPercentage as
With PopulationvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CAST(vac.new_vaccinations as bigint)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/Population*100) as VaccinatedPercentage
FROM PopulationvsVac


-- Temp Table

DROP Table if exists #PercentPopulationVaccinated
CREATE Table #PercentPopulationVaccinated
(
Continent nvarchar(255), 
location nvarchar(255), 
date datetime, 
population numeric, 
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CAST(vac.new_vaccinations as bigint)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/Population*100) as VaccinatedPercentage
FROM PercentPopulationVaccinated