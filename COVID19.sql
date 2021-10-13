Select *
From PortfolioProject..CovidDeath$
WHERE continent is not null
order by 3,4


--Select *
--From PortfolioProject..CovidVaccinations$
--order by 3,4


-- Select Data that we are going to be using


select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeath$
order by 1,2

 -- Looking at Total Cases vs. Total Deaths
 -- Shows likelihood of dying if you contract covid in your country
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeath$
order by 1,2

--Looking at Total Caes vs. Population
--Shows what percentage of population got covid
Select Location, date, Population, total_cases, (total_cases/Population)*100 as InfectionRate
From PortfolioProject..CovidDeath$
--Where location like '%china%'
order by 1,2

--Looking at countries with highest infection rate compared to population
Select Location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/Population)*100) as InfectionRate
From PortfolioProject..CovidDeath$
--Where location like '%china%'
Group by Location, Population
order by InfectionRate desc



--showing countries with the highest death count per population
Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeath$
WHERE continent is not null
--Where location like '%china%'
Group by Location
order by TotalDeathCount desc


-- break things down by continent
Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeath$
WHERE continent is not null
--Where location like '%china%'
Group by continent
order by TotalDeathCount desc


--showing continents with the highest death count
Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeath$
WHERE continent is not null
--Where location like '%china%'
Group by continent
order by TotalDeathCount desc


--global numbers
Select date, SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 AS DeathPercentage
From PortfolioProject..CovidDeath$
WHERE continent is not null
Group by date
order by 1,2



--looking at total population vs. vaccination

--using CTE

With PopvsVac (Continent, Location, Date, Population, NewVaccination, RollingPeopleVaccinated)
as 
(
Select d.continent, d.location, d.date, d.population, v.new_vaccinations, 
SUM(CONVERT(INT, v.new_vaccinations)) OVER(Partition by d.location order by d.location, d.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeath$ d
join PortfolioProject..CovidVaccinations$ v
	ON d.location = v.location
	AND d.date = v.date
WHERE d.continent is not null
--order by 2,3
)
select *, (RollingPeopleVaccinated/Population)*100 as RollingVaccinationRate
From  PopvsVac


--temp table
drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select d.continent, d.location, d.date, d.population, v.new_vaccinations, 
SUM(CAST(v.new_vaccinations AS bigINT)) OVER(Partition by d.location order by d.location, d.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeath$ d
join PortfolioProject..CovidVaccinations$ v
	ON d.location = v.location
	AND d.date = v.date
-- WHERE d.continent is not null
--order by 2,3

select *, (RollingPeopleVaccinated/Population)*100 as RollingVaccinationRate
From  #PercentPopulationVaccinated


-- creating view to store date for future visualizations
Create View PercentPopulationVaccinated as
Select d.continent, d.location, d.date, d.population, v.new_vaccinations, 
SUM(CONVERT(INT, v.new_vaccinations)) OVER(Partition by d.location order by d.location, d.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeath$ d
join PortfolioProject..CovidVaccinations$ v
	ON d.location = v.location
	AND d.date = v.date
WHERE d.continent is not null
--order by 2,3


Select * 
From PercentPopulationVaccinated