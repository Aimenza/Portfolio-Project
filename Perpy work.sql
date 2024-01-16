select *
from [Porfolio Project]..['COVID-19 DEATHS$']
where continent is not Null
order by 3,4

--select data that we are going to be using

select Location, date, total_cases, new_cases, total_deaths, population
from [Porfolio Project]..['COVID-19 DEATHS$']
where continent is not Null
order by 1,2

--Looking at Total cases vs Total Deaths

select Location, date, total_cases,total_deaths, (cast(total_deaths as float)/cast(total_cases as float))*100 as DeathPercentage
from [Porfolio Project]..['COVID-19 DEATHS$']
--where location like '%states%'
where continent is not Null
order by 1,2

--Looking at total case vs population
--Shows what percentage of populations got Covid

select Location, date,population, total_cases, (total_cases/population)*100 as PercentagePopulation
from [Porfolio Project]..['COVID-19 DEATHS$']
--where location like '%states%'
where continent is not Null
order by 1,2

--looking at countrie with highest infection rate compared to population

select Location,population, max(total_cases) as highestInfectionCount, max((total_cases/population))*100 as PercentagePopulationInfected
from [Porfolio Project]..['COVID-19 DEATHS$']
--where location like '%states%'
group by Location,population
order by PercentagePopulationInfected desc

--showing countries with highest death count per population

select Location,max(cast(total_deaths as int)) as TotalDeathCount
from [Porfolio Project]..['COVID-19 DEATHS$']
--where location like '%states%'
where continent is not Null
group by Location
order by TotalDeathCount desc

--Lets break things down by continent

select location,max(cast(total_deaths as int)) as TotalDeathCount
from [Porfolio Project]..['COVID-19 DEATHS$']
--where location like '%states%'
where continent is Null
group by location
order by TotalDeathCount desc

--Showing continent with the highest Death counth per population

select continent,max(cast(total_deaths as int)) as TotalDeathCount
from [Porfolio Project]..['COVID-19 DEATHS$']
--where location like '%states%'
where continent is not Null
group by continent
order by TotalDeathCount desc


--Global Numbers

select date, sum(new_cases) as TotalCases, sum(cast(new_deaths as int))as TotalDeath, sum(new_deaths)/ sum(new_cases)*100 as DeathPercentage
from [Porfolio Project]..['COVID-19 DEATHS$']
--where location like '%states%'
where continent is not Null
group by date
order by 1,2


select sum(new_cases) as TotalCases, sum(cast(new_deaths as int))as TotalDeath, sum(cast(new_deaths as int))/ sum(new_cases)*100 as DeathPercentage
from [Porfolio Project]..['COVID-19 DEATHS$']
--where location like '%states%'
where continent is not Null
--group by date
order by 1,2


--Looking at Total Population vs Vaccinations

select Dea.continent, Dea.location, Dea.date, Dea.population, Vac.new_vaccinations
from [Porfolio Project]..['COVID-19 DEATHS$'] Dea
Join [Porfolio Project]..['COVID-19 VACCINATIONS$'] Vac
    on Dea.location = Vac.location
	and Dea.date = Vac.date
where Dea.continent is not Null
order by 2,3

select Dea.continent, Dea.location, Dea.date, Dea.population, Vac.new_vaccinations
, sum(convert(int, Vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinationated
from [Porfolio Project]..['COVID-19 DEATHS$'] Dea
Join [Porfolio Project]..['COVID-19 VACCINATIONS$'] Vac
    on Dea.location = Vac.location
	and Dea.date = Vac.date
where Dea.continent is not Null
order by 2,3

--Use CTE
With popvsvac (continent, location, date, population, New_Vaccinations, RollingPeopleVaccinated)
as
(
select Dea.continent, Dea.location, Dea.date, Dea.population, Vac.new_vaccinations
, sum(convert(int, Vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from [Porfolio Project]..['COVID-19 DEATHS$'] Dea
Join [Porfolio Project]..['COVID-19 VACCINATIONS$'] Vac
    on Dea.location = Vac.location
	and Dea.date = Vac.date
where Dea.continent is not Null
--order by 2,3
)
Select*, (RollingPeopleVaccinated/population)*100
from
popvsvac


--Temp Table

Drop table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
insert into #PercentPopulationVaccinated
select Dea.continent, Dea.location, Dea.date, Dea.population, Vac.new_vaccinations
, sum(convert(int, Vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from [Porfolio Project]..['COVID-19 DEATHS$'] Dea
Join [Porfolio Project]..['COVID-19 VACCINATIONS$'] Vac
   on Dea.location = Vac.location
	and Dea.date = Vac.date
--where Dea.continent is not Null
--order by 2,3

Select *, (RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated

--Creating view to store Data for later Visualisation
Create view Percentpopulationvaccinated1 as 
select Dea.continent, Dea.location, Dea.date, Dea.population, Vac.new_vaccinations
, sum(convert(int, Vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from [Porfolio Project]..['COVID-19 DEATHS$'] Dea
Join [Porfolio Project]..['COVID-19 VACCINATIONS$'] Vac
    on Dea.location = Vac.location
	and Dea.date = Vac.date
where Dea.continent is not Null
--order by 2,3