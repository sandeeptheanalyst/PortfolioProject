Select *
From PortfolioProject..CovidDeaths
where continent is not null
Order by 3,4

--Select *
--From PortfolioProject..CovidVaccinations
--Order by 3,4

-- Select Data that we are going to be using

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
where continent is not null
Order by 1,2

--Looking at Total Cases vs Total Deaths

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where location like '%states%' and continent is not null
Order by 1,2

--Loking at Total cases vs Population
--Shows what % of population got Covid

Select Location, date, population, total_cases,  (total_cases/population)*100 as PercentagepopInfected
From PortfolioProject..CovidDeaths
--where location like '%states%'
Order by 1,2

--Looking at Countries with Highest Infection Rate comparison to Population

Select Location, population, max(total_cases) as HighestinfectionCount,  max((total_cases/population))*100 as PercentagepopInfected
From PortfolioProject..CovidDeaths
--where location like '%states%'
Group by location, population
Order by PercentagepopInfected desc

--Looiking at India

Select Location, date, population, total_cases,  (total_cases/population)*100 as PercentagepopInfected
From PortfolioProject..CovidDeaths
where location='india'
Order by 1,2

--Showing Countries with Highest Death Count per Population

Select Location, max(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--where location like '%states%'
where continent is not null
Group by location, population
Order by TotalDeathCount desc

--Let's Break Things down by Continent

Select location, max(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--where location like '%states%'
where continent is null
Group by location
Order by TotalDeathCount desc


Select continent, max(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--where location like '%states%'
where continent is not null
Group by continent
Order by TotalDeathCount desc

--Global Numbers

Select date, sum(new_cases) as Total_Cases, sum(cast(new_deaths as int)) as Total_Deaths, (sum(cast(new_deaths as int))/sum(new_cases))*100 as DeathPercentageGlobaly
From PortfolioProject..CovidDeaths
--where location like '%states%' and
Where continent is not null
Group by date
Order by 1,2


--Looking at Total Population vs Vaccination
--"Dea" is aliasing for coviddeath table and "Vac" for covidvaccination
--or "cast" function to change the data type:-sum(convert(int, vac.new_vaccinations))

Select Dea.continent, Dea.location, Dea.date, Dea.population, Vac.new_vaccinations
, sum(convert(int, vac.new_vaccinations)) Over (partition by Dea.location order by Dea.location
, Dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100

From PortfolioProject..CovidDeaths Dea
Join PortfolioProject..CovidVaccinations Vac
	On Dea.location = Vac.location
	And Dea.date = Vac.date
Where dea.continent is not null
Order by 2,3




--use CTE

With PopvsVac (Continent, location, Date, Population, new_vaccinations,RollingPeopleVaccinated)
as
(
Select Dea.continent, Dea.location, Dea.date, Dea.population, Vac.new_vaccinations
, sum(convert(int, vac.new_vaccinations)) Over (partition by Dea.location order by Dea.location
, Dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100

From PortfolioProject..CovidDeaths Dea
Join PortfolioProject..CovidVaccinations Vac
	On Dea.location = Vac.location
	And Dea.date = Vac.date
Where dea.continent is not null
--Order by 2,3
)

Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac





--Use TEMP TABLE

Drop table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Conitinent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select Dea.continent, Dea.location, Dea.date, Dea.population, Vac.new_vaccinations
, sum(convert(int, vac.new_vaccinations)) Over (partition by Dea.location order by Dea.location
, Dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100

From PortfolioProject..CovidDeaths Dea
Join PortfolioProject..CovidVaccinations Vac
	On Dea.location = Vac.location
	And Dea.date = Vac.date
--Where dea.continent is not null
--Order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100 as PercentPopulationVaccinated
From PercentPopulationVaccinated




--Creating View to store data for later visualisation


Create View PercentPopulationVaccinated as
Select Dea.continent, Dea.location, Dea.date, Dea.population, Vac.new_vaccinations
, sum(convert(int, vac.new_vaccinations)) Over (partition by Dea.location order by Dea.location
, Dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100

From PortfolioProject..CovidDeaths Dea
Join PortfolioProject..CovidVaccinations Vac
	On Dea.location = Vac.location
	And Dea.date = Vac.date
Where dea.continent is not null
--Order by 2,3

Select *
From PercentPopulationVaccinated