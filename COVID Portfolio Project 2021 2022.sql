
Select *
From PortfolioProject..CovidDeaths
where continent is not null
order by 3,4

--Select *
--From PortfolioProject..CovidVaccinations
--order by 3,5

-- Selecting Data that we are going to use
Select Location,date,total_cases,new_cases,total_deaths, population
From PortfolioProject..CovidDeaths
where continent is not null
order by 1,2;

-- Knowing the Total Deaths vs Total Cases from 2021 to 2022 
-- Rough Estimation of Death Percentage in Indonesia from 2021 to 2022
Select Location,date,total_cases,total_deaths, population, (total_deaths/total_cases)*100 as Death_Percentage
From PortfolioProject..CovidDeaths
where location like '%indonesia'
order by 1,2;


-- Knowing the Total Cases vs Populations from 2021 to 2022 
-- Estimation of percentage of people got covid from 2021 to 2022 
Select Location,date,total_cases, population, (total_cases/population)*100 as Infected_Percentage
From PortfolioProject..CovidDeaths
--where location like '%indonesia'
order by 1,2;


-- Knowing of countries with Highest Infection Date compared to Population
Select Location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as Infected_Percentage
From PortfolioProject..CovidDeaths
group by Location, Population
order by Infected_Percentage desc;


-- Knowing Countries with Highest Death Count per Population
Select Location, MAX(total_deaths) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where NOT continent =''
group by Location
order by TotalDeathCount desc;

-- Knowing Continents with Highest Death Count per Population
Select continent, MAX(total_deaths) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where NOT continent =''
group by continent
order by TotalDeathCount desc;


-- Global Number Calculations
-- Aggregate Function total cases, total deaths & death percentage
Select SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, (SUM(new_deaths)/SUM(new_cases))*100 as Death_Percentage
From PortfolioProject..CovidDeaths
--where location like '%indonesia'
Where NOT continent =''
--group by date
order by 1,2;


--Vaccination Parts
Select *
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date;

-- CTE 
with PopvsVac (Continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
-- Knowing Total Populations that has been Vaccinated 
Select dea.continent, dea.location, dea.date, dea.population, cast(vac.new_vaccinations as float) as new_vaccinations,
-- Calculate Total Vaccinated people in Countries per day
SUM(CONVERT(float,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, 
dea.date) as RollingPeopleVaccinated 
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where NOT dea.continent =''
--order by 2,3
)

-- Showing percentage of vaccinated people by population in total per days
Select * , (RollingPeopleVaccinated/Population)*100 as Vaccinated_Percentage
from PopvsVac


-- Temporary Table 

DROP table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated (
	Continent nvarchar(255),
	Location nvarchar(255),
	Date datetime,
	Population numeric,
	New_Vaccinations numeric,
	RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
-- Knowing Total Populations that has been Vaccinated 
Select dea.continent, dea.location, dea.date, dea.population, cast(vac.new_vaccinations as float) as new_vaccinations,
-- Calculate Total Vaccinated people in Countries per day
SUM(CONVERT(float,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, 
dea.date) as RollingPeopleVaccinated 
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where NOT dea.continent =''
--order by 2,3

-- Showing percentage of vaccinated people by population in total per days
Select * , (RollingPeopleVaccinated/Population)*100 as Vaccinated_Percentage
from #PercentPopulationVaccinated


-- Creating View to Store data for Viz

Create View PercentPopulationVaccinated as
-- Knowing Total Populations that has been Vaccinated 
Select dea.continent, dea.location, dea.date, dea.population, cast(vac.new_vaccinations as float) as new_vaccinations,
-- Calculate Total Vaccinated people in Countries per day
SUM(CONVERT(float,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, 
dea.date) as RollingPeopleVaccinated 
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where NOT dea.continent =''
--order by 2,3

Select * From PercentPopulationVaccinated