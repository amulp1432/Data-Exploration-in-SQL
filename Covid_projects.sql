create database portfolioproject


Select *
From portfolioproject..Covid_deaths$
order by 3,4

--Select *
--from portfolioproject..Covid_vacinations$
--order by 3,4

--Select data that we are going to use
Select Location,date,total_cases,new_cases,total_deaths,population
from portfolioproject..Covid_deaths$
order by 1,2
--Looking at total_cases vs total_deaths
--Shows likelihood of dying if you are looking for covid in your country.
Select Location,date,total_cases,total_deaths,(total_deaths / total_cases)*100 as death_percentage
from portfolioproject..Covid_deaths$
where location like '%India%'
order by 1,2

--Looking at total_cases vs Population
--It will show us that what percentage of people has been affected by the covid
Select location, date,population,total_cases,(total_cases/population)*100 as Affected_rate_by_the_population
from portfolioproject..Covid_deaths$
order by 1,2
--Looking   at the country with highest affected rate by covids
Select location,population,max(total_cases) as Highest_infection_count,max(total_cases/population)*100 as Affected_rate_by_the_population
from portfolioproject..Covid_deaths$
Group BY location,population
order by  Affected_rate_by_the_population desc

--Showing countries with Highest death count per population
select location,max(total_deaths) as maximum_death_count
from portfolioproject..Covid_deaths$
--where location like '%india%'
Group by location
order by maximum_death_count desc
--this has a problem in datatype so we need to change the datatype
select location,max(cast(total_deaths as int) ) as maximum_death_count
from portfolioproject..Covid_deaths$
--where location like '%india%'
Group by location
order by maximum_death_count desc


--Let's do the above query with continent
select continent, max(cast(total_deaths as int)) as maximum_death_count
from portfolioproject..Covid_deaths$
where continent is not null
group by continent
order by maximum_death_count desc

select date,total_deaths,total_cases,(total_deaths/total_cases)*100 as death_percentage
from portfolioproject..Covid_deaths$
where continent is not null
Group by date
order by 1,2

-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine


Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,sum(cast(vac.new_vaccinations as int )) over (partition by dea.location order by dea.location)

From PortfolioProject..Covid_deaths$ dea
Join PortfolioProject..Covid_vacinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3

-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..Covid_deaths$ dea
Join PortfolioProject..Covid_vacinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac



-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..Covid_deaths$ dea
Join PortfolioProject..Covid_vacinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated






