USE PortfolioProject

-- Lets see first our CovidDeaths table

select * 
from CovidDeaths
order by 1,2

-- looking at total_cases vs total-deaths to obtain a DeatthPercentage from table covidDeaths
--- 1

select location, total_cases, total_deaths, (CAST(total_deaths as float)/total_cases)*100 as DeathPercentage
from CovidDeaths
where location = 'Asia'
Order by DeathPercentage Desc

-- Looking at total cases vs population to obtain a colunm total percentage of population infected
---2

select location, date, population, total_cases, (CAST(total_deaths as float)/population)*100 as PercentagePopulationInfected
from CovidDeaths
where location = 'Asia'

-- Looking at the countries with highest infection rate compared to population
---3

select location, population, MAX(total_cases) as HighestInfectionCount, MAx(total_cases/population)*100 as PercentedPopulationInfected
from CovidDeaths
where continent is not null
group by location, population
order by PercentedPopulationInfected Desc

-- Looking countries with highest death count per population
---4

Select Location, Population,date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
Group by Location, Population, date
order by PercentPopulationInfected desc

-- Looking continent with highest death count per population
--5

select continent, MAX(total_deaths) as totaodeathCountPerContinent
from CovidDeaths
where continent is not null
group by continent
order by totaodeathCountPerContinent

-- Looking at totao_cases and total_deaths and finding out what is the Death percentage of the world
--6

select SUM(new_cases) as Total_Cases, SUM(total_deaths) as Total_deaths, (SUM(new_cases)/SUM(total_deaths))*100 as DeathPercentage
from CovidDeaths
where continent is not null

-- Let's also check out the CovidVaccinations table

select *
from CovidVaccinations

-- Joining both the tables with the location and date

select *
from CovidDeaths as dea
join CovidVaccinations as vac
	on dea.location = vac.location
	and dea.date = vac.date

-- Looking at total people got vaccinated by location and date


select dea.continent, dea.date, dea.population, dea.location, vac.new_vaccinations, SUM(vac.new_vaccinations) Over ( Partition by dea.location order by dea.location, dea.date) as RollingPopulationVaccinated
from CovidDeaths as dea
join CovidVaccinations as vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

-- Now with the helh of "WITH" statement we are ceating a tempery table name PopvsVac for analysis of population vs vaccination
--7

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPopulationVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
)
Select *, (CONVERT( float ,RollingPopulationVaccinated)/Population)*100 as PercentPeopleVaccinated
From PopvsVac

-- Creating a table called Percentage population infected and inserting the tempert table PopvsVac into it
--8

Drop table if exists PercentagePopulationVaccinated

Create table PercentagePopulationVaccinated
( continent nvarchar(255),
Location nvarchar (255),
Date datetime,
Population bigint,
New_vaccination int,
RollingPopulationVaccinated int,
)

INSERT INTO PercentagePopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 

Select *, (CONVERT( float ,RollingPopulationVaccinated)/Population)*100 as PercentPeopleVaccinated
From PercentagePopulationVaccinated


-- Creating a view to store data for later visulization

CREATE View RollingPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 

Select *
from RollingPopulationVaccinated
