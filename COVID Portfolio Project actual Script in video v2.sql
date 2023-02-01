SELECT * 
FROM PortfolioProject..CovidDeaths$
order by 3,4

--SELECT * 
--FROM PortfolioProject..CovidVaccinations$
--order by 3,4

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths$
Order by 1,2

-- Looking at total cases vc total deaths
-- shows the likelihood of dying if you contract covid in India 
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths$
Where location like '%india%'
Order by 1,2

-- Looing at the total cases vs population
-- shows what % of population get covid

SELECT Location, date, total_cases, population, (total_cases/population)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths$
--Where location like '%states%'
Order by 1,2


--Looking at countries with highest infection rate compared to population

SELECT Location, MAX(total_cases) as HighestInfectionCount, population, MAX(total_cases/population)*100 as PercentOfPopulationInfected
FROM PortfolioProject..CovidDeaths$
--Where location like '%india%'
Group by Location, Population
Order by PercentOfPopulationInfected desc

-- Showing countries with highest death count

SELECT Location, MAX(CAST(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths$
Where continent is not null
Group by Location
Order by TotalDeathCount desc

-- Lets break things down by continent


-- Showing continent with highest death count per population

SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths$
--Where location like '%india%'
Where continent is not null
Group by continent
Order by TotalDeathCount desc


-- Global Numbers

SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases) * 100 as DeathPercentage
FROM PortfolioProject..CovidDeaths$
--Where location like '%states%'
Where continent is not null
--Group By date
Order By 1,2

-- Global number by date

SELECT date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases) * 100 as DeathPercentage
FROM PortfolioProject..CovidDeaths$
--Where location like '%states%'
Where continent is not null
Group By date
Order By 1,2

-- Looking at total population vs vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as int)) OVER (Partition by dea.Location Order by dea.location,
	dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
 	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null 
order by 2,3

-- USE CTW

With PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
 (
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as int)) OVER (Partition by dea.Location Order by dea.location,
	dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
 	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/population)*100
From PopvsVac


-- Temp Table

Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Contonent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric, 
new_vaccination numeric,
RollingPeopleVaccination numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as int)) OVER (Partition by dea.Location Order by dea.location,
	dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
 	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccination/population)*100
From #PercentPopulationVaccinated


-- Creating view to store data for later Visulations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as int)) OVER (Partition by dea.Location Order by dea.location,
	dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
 	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3

Select *
From PercentPopulationVaccinated