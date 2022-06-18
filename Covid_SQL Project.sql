select *
from PortfolioProject..CovidDeaths
order by 3,4

--select *
--from PortfolioProject..CovidVaccinations
--order by 3,4

select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
order by location, date


--Total Cases vs Total Deaths

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where location like '%germany%'
order by 1,2


--Total Cases vs Population

select location, date, population, total_cases, (total_cases/population)*100 as PercenPopulationInfected
from PortfolioProject..CovidDeaths
--where location like '%germany%'
order by location, date


--Countries with highest Infection Rate compared to Population

select location, population, max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as PercenPopulationInfected
from PortfolioProject..CovidDeaths
--where location like '%germany%'
group by location, population
order by PercenPopulationInfected desc


--Countries with Highest Death Count per Population

select location, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent<>''
group by location
order by TotalDeathCount desc


--Global Numbers

select date, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where continent<>''
group by date
order by 1,2


--Total Population vs Vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
, sum(cast(vac.new_vaccinations as float)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent<>'' --and vac.new_vaccinations<>''
order by 2,3


--CTE

with PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
, sum(cast(vac.new_vaccinations as float)) over (partition by dea.location order by dea.location, +
	dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent<>'' --and vac.new_vaccinations<>''
--order by 2,3
)
select *, (RollingPeopleVaccinated/Population)*100
from PopvsVac


--TEMP TABLE

drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
Continent nvarchar(255), 
Location nvarchar(255), 
Date datetime, 
Population numeric, 
New_Vaccinations float, 
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
, sum(cast(vac.new_vaccinations as float)) over (partition by dea.location order by dea.location, +
	dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent<>'' --and vac.new_vaccinations<>''
--order by 2,3
select *, (RollingPeopleVaccinated/Population)*100
from #PercentPopulationVaccinated


--Creating View to store data for later visualizations

Create View PercentPopulationVaccinated01 as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
, sum(cast(vac.new_vaccinations as float)) over (partition by dea.location order by dea.location, +
	dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent<>'' --and vac.new_vaccinations<>''
--order by 2,3


select *
from PercentPopulationVaccinated01