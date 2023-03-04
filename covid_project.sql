use CovidProject

select *
from [dbo].[CovidDeathData]
order by 3, 4

select *
from [dbo].[CovidVaccinationData]
order by 3, 4


--1) Total Deaths per Cases
select location
	, date
	, total_cases
	, total_deaths
	, (total_deaths/total_cases)*100 as Death_Percentage
	from [dbo].[CovidDeathData]
	where continent is not null
	order by 1, 2
-- shows likelihood of people dying from covid
--1.1) How about in the cases of Nigeria?
select location
	, date
	, total_cases
	, total_deaths
	, (total_deaths/total_cases)*100 as Death_Percentage
from [dbo].[CovidDeathData]
where location like '%nigeria%'
order by 1, 2

--2) How did Total Cases affect the Population in respective countries?(Total Cases vs Population)
-- shows percentage of population who contacted covid
select location
	, date
	, population
	, total_cases
	, (total_cases/population)*100 as percent_population_infected
from [dbo].[CovidDeathData]
where continent is not null
order by 1, 2

--3) Countries with Highest Infection Rate compared to Population
select location
	, population
	, max(total_cases) as highest_infections_recorded
	, max((total_cases/population)*100) as percent_population_infected
from [dbo].[CovidDeathData]
where continent is not null
group by location, population
order by 3 desc

--4) Total Death Count of Different Countries
select location
, max(cast(total_deaths as int)) as total_death_Recorded
from [dbo].[CovidDeathData]
where continent is not null
and location not in ('world', 'european union', 'international', 'high income', 
'upper middle income', 'lower middle income','low income')
group by location
order by 2 desc

--5) Continents with Highest Death Count per Population
select continent
, sum(cast(new_deaths as int)) as total_death_recorded
from [dbo].[CovidDeathData]
where continent is not null
group by continent
order by 2 desc

--6) Global Numbers
select sum(new_cases) as total_cases_recorded
	, sum(cast(new_deaths as int)) as total_death_recorded
	, sum(cast(new_deaths as int))/sum(new_cases) * 100 as death_percentage
from [dbo].[CovidDeathData]
where continent is not null

--6.1) Global Numbers by Date
select date
	, sum(new_cases) as total_cases_recorded
	, sum(cast(new_deaths as int)) as total_death_recorded
	, sum(cast(new_deaths as int))/sum(new_cases) * 100 as death_percentage
from [dbo].[CovidDeathData]
where continent is not null
group by date
order by 1, 2

--6.2) Global Numbers by Country
select location
	, sum(new_cases) as total_cases_recorded
	, sum(cast(new_deaths as int)) as total_death_recorded
	, sum(cast(new_deaths as int))/sum(new_cases) * 100 as death_percentage
from [dbo].[CovidDeathData]
where continent is not null
group by location
order by 1

--7) Total Number of People Vaccinated
select cd.continent
	, cd.location
	, cd.date
	, cd.population
	, cv.new_vaccinations
	, sum(cast(cv.new_vaccinations as bigint)) over (partition by cd.location order by cd.location, cd.date) as rolling_people_vaccinated
from [dbo].[CovidDeathData] cd
join [dbo].[CovidVaccinationData] cv
on cd.location = cv.location
and cd.date = cv.date
where cd.continent is not null
order by 2, 3

--8) Percentage Population of People Vaccinated(using CTE)
with ppv as 
(
	select cd.continent
	, cd.location
	, cd.date
	, cd.population
	, cv.new_vaccinations
	, sum(cast(cv.new_vaccinations as bigint)) over (partition by cd.location order by cd.location, cd.date) as rolling_people_vaccinated
	from [dbo].[CovidDeathData] cd
	join [dbo].[CovidVaccinationData] cv
	on cd.location = cv.location
	and cd.date = cv.date
	where cd.continent is not null
)
select *
, (rolling_people_vaccinated/population) * 100 as rolling_percentage_vaccinated
from ppv
order by 2,3

--9) Percentage Population of People Vaccinated(using temp table)
drop table if exists #ppv
create table #ppv (
	continent varchar(255)
	, location varchar(255)
	, date datetime
	, population numeric
	, new_vaccinations numeric
	, rolling_people_vaccinated numeric
)
insert into #ppv
select cd.continent
	, cd.location
	, cd.date
	, cd.population
	, cv.new_vaccinations
	, sum(cast(cv.new_vaccinations as bigint)) over (partition by cd.location order by cd.location, cd.date) as rolling_people_vaccinated
from [dbo].[CovidDeathData] cd
join [dbo].[CovidVaccinationData] cv
on cd.location = cv.location
and cd.date = cv.date
where cd.continent is not null

select *
,(rolling_people_vaccinated/population) * 100 as rolling_percentage_vaccinated
from #ppv
order by 2, 3

