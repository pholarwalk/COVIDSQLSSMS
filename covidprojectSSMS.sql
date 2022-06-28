SELECT *
FROM covidPORTFOLIO..CovidDeaths$

-- selecting data to be used

select location, date, total_cases, new_cases, total_deaths, population
from covidPORTFOLIO..CovidDeaths$
order by 1, 2

--- total cases vs total deaths in united states

select location, date, total_cases, total_deaths, (total_deaths/total_cases)* 100 as death_percentage
from covidPORTFOLIO..CovidDeaths$
where location like '%states%'
order by 1, 2

--- total cases vs population in nigeria
select location, date, total_cases, population, (total_cases/population)* 100 as population_percentage
from covidPORTFOLIO..CovidDeaths$
where location = 'nigeria'
order by 1, 2

---countries with highest infection rate compared to population
select location, population, max(total_cases) as highestcases,
max((total_cases/population))* 100 as infected_percentage
from covidPORTFOLIO..CovidDeaths$
--where location != 'world'
where continent is null
group by location, population
order by infected_percentage desc

---continents with the highest death count
select continent, max(cast(total_deaths as int)) as highestdeath
from covidPORTFOLIO..CovidDeaths$
--where location != 'world'
where continent is not null
group by continent

---GLOBAL NUMBERS total percentage in the world per day/date
select date, SUM(new_cases) as Totalcases, SUM(CAST(new_deaths AS int)) as totalDeath,
SUM(CAST(new_deaths AS int))/SUM(new_cases)* 100 as deathperc
-- (total_deaths/total_cases)* 100 as death_percentage
from covidPORTFOLIO..CovidDeaths$
where continent is not null
group by date
order by 1, 2

--total percentage in the world
select SUM(new_cases) as Totalcases, SUM(CAST(new_deaths AS int)) as totalDeath,
SUM(CAST(new_deaths AS int))/SUM(new_cases)* 100 as deathperc
-- (total_deaths/total_cases)* 100 as death_percentage
from covidPORTFOLIO..CovidDeaths$
where continent is not null
--group by date
 

--- JOINS FOR THE TWO TABLE
SELECT *
FROM covidPORTFOLIO..CovidDeaths$ dea
	join covidPORTFOLIO..CovidVaccinations$ vac
	on dea.location =vac.location
	and dea.date = vac.date

--total population that has been vaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
FROM covidPORTFOLIO..CovidDeaths$ dea
	join covidPORTFOLIO..CovidVaccinations$ vac
	on dea.location =vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2, 3

---CREATING A TEMP TABLE
drop table if exists #percpopvac
create table #percpopvac
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccination numeric,
rollingpeepvac numeric,
)   

insert into #percpopvac 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations))
over (partition by dea.location order by dea.location, dea.date)as rollingpeepvac
FROM covidPORTFOLIO..CovidDeaths$ dea
	join covidPORTFOLIO..CovidVaccinations$ vac
	on dea.location =vac.location
	and dea.date = vac.date
--where dea.continent is not null 

select * , (rollingpeepvac/population)* 100 as percentage
from #percpopvac


---creating view to store data for visualization
create view percpopvac as 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations))
over (partition by dea.location order by dea.location, dea.date)as rollingpeepvac
FROM covidPORTFOLIO..CovidDeaths$ dea
	join covidPORTFOLIO..CovidVaccinations$ vac
	on dea.location =vac.location
	and dea.date = vac.date
--where dea.continent is not null 


create view highestcasesperc as
select location, population, max(total_cases) as highestcases,
max((total_cases/population))* 100 as infected_percentage
from covidPORTFOLIO..CovidDeaths$
--where location != 'world'
where continent is null
group by location, population
--order by infected_percentage desc