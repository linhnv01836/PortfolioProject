--Select Data that we are going to use
SELECT location, date, total_cases, new_cases, total_deaths, population 
FROM PortfolioProject.dbo.CovidDeaths cd 
order by 1, 2

--Looking at Total Cases vs Total Deaths
--Shows the likelihood of dying if you contract covid in your country
SELECT location, date, total_cases, total_deaths, total_deaths / total_cases * 100 as DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths cd 
WHERE location like '%states%'
order by 1, 2 

--Looking at Total Cases vs Population
--Show what percentage of population got Covid
SELECT location, date, population, total_cases, total_cases / population  * 100 as InfectionPercentage
FROM PortfolioProject.dbo.CovidDeaths cd 
--WHERE location like '%states%'
order by 1, 2 

--Looking at Countries with Highest Infection Rate compared to Population
SELECT location, population, MAX(total_cases) as HighestInfectionCount, max(total_cases) / population  * 100 as MaxInfectionPercentage
FROM PortfolioProject.dbo.CovidDeaths cd 
group by location, population  
ORDER BY MaxInfectionPercentage desc

--Showing Countries with Highest Death Count per Population
SELECT location, MAX(total_deaths) as HighestDeathCount
FROM PortfolioProject.dbo.CovidDeaths cd 
--Excluding continents
WHERE continent is not NULL 
group by location
ORDER BY HighestDeathCount DESC 

--Showing Continent with Highest Death Count per Population
SELECT location, MAX(total_deaths) as HighestDeathCount
FROM PortfolioProject.dbo.CovidDeaths cd 
WHERE continent is NULL and location != 'World'
group by location 
ORDER BY HighestDeathCount DESC

--Global numbers
SELECT sum(new_cases) as total_cases, sum(new_deaths) as total_deaths, sum(new_deaths) / sum(new_cases) * 100 as DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths cd 
WHERE continent is not NULL 
--GROUP BY date
order by 1, 2

--Use CTE
WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS
--Looking at Total Population vs Vaccinations
(SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(vac.new_vaccinations) over (PARTITION by dea.location 
		order by dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject.dbo.CovidDeaths dea 
join PortfolioProject.dbo.CovidVaccinations vac 
	on dea.location = vac.location 
	and dea.date = vac.date
WHERE dea.continent is not NULL
--order by 2, 3
)
SELECT *,
	RollingPeopleVaccinated / Population * 100 as RPVPercentage
FROM PopvsVac


--Use Temp Table
drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(vac.new_vaccinations) over (PARTITION by dea.location 
		order by dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject.dbo.CovidDeaths dea 
join PortfolioProject.dbo.CovidVaccinations vac 
	on dea.location = vac.location 
	and dea.date = vac.date
WHERE dea.continent is not NULL

SELECT *,
	RollingPeopleVaccinated / Population * 100 as RPVPercentage
FROM #PercentPopulationVaccinated


--Creating View to store data for later visualizations
create view PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(vac.new_vaccinations) over (PARTITION by dea.location 
		order by dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject.dbo.CovidDeaths dea 
join PortfolioProject.dbo.CovidVaccinations vac 
	on dea.location = vac.location 
	and dea.date = vac.date
WHERE dea.continent is not NULL

SELECT *
FROM PercentPopulationVaccinated
