SELECT *	
FROM CovidDeaths_csv cdc 
WHERE continent is NOT NULL 
ORDER BY 3,4

SELECT *
FROM CovidVaccinations_csv cvc 
ORDER BY 3,4

SELECT location, date, total_cases,new_cases, total_deaths, population 
FROM CovidDeaths_csv cdc 
WHERE continent is NOT NULL 
ORDER by 1,2

Looking at total cases vs total deaths


SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM CovidDeaths_csv cdc 
WHERE location like '%India%'
and  continent is NOT NULL 
ORDER by 1,2 


Looking at the total cases vs population

SELECT location, date, population , total_cases , (total_cases /population)*100 as PercentPopulationinfected
FROM CovidDeaths_csv cdc 
WHERE location like '%India%'
ORDER by 1,2 

looking at countries with the highest infection rate compared to the population

SELECT location, population , MAX(total_cases) as HighestInfectionCount , max((total_cases /population))*100 as PercentPopulationinfected
FROM CovidDeaths_csv cdc 
group by population, location 
ORDER by  PercentPopulationinfected 

Countries with highest deatcount perpopulation

lets break things into continent

SELECT continent , MAX(CAST(total_deaths AS INT)) as TotalDeathCount
FROM CovidDeaths_csv cdc 
WHERE continent is not null
group by continent 
ORDER by  TotalDeathCount desc

showing the continent with highestdeathcount

SELECT continent , MAX(CAST(total_deaths AS INT)) as TotalDeathCount
FROM CovidDeaths_csv cdc 
WHERE continent is not null
group by continent 
ORDER by  TotalDeathCount desc


globalnumbers


SELECT  sum(new_cases)as total_cases , sum(new_deaths) as total_deaths , sum(new_deaths)/sum(new_cases)*100 as DeathPecentage
FROM CovidDeaths_csv cdc 
where  continent is NOT NULL 
ORDER by 1,2 

Totalpopulation vs vaccination

SELECT cdc.continent, cdc.location, cdc.date, cdc.population, cvc.new_vaccinations 
, SUM(cvc.new_vaccinations) OVER (partition by cdc.location order by cdc.location, cdc.date) as RollingPeopleVaccinated
FROM CovidDeaths_csv cdc 
JOIN CovidVaccinations_csv cvc 
    ON cdc.location = cvc.location 
    and cdc.date = cvc.date 
where  cdc.continent is NOT NULL 
    order by 2,3
 
use CTE	

WITH PopvsVac (continent,location, date, population,new_vaccinations, RollingPeopleVaccinated)
AS
(
SELECT cdc.continent, cdc.location, cdc.date, cdc.population, cvc.new_vaccinations 
, SUM(cvc.new_vaccinations) OVER (partition by cdc.location order by cdc.location, cdc.date) as RollingPeopleVaccinated
FROM CovidDeaths_csv cdc 
JOIN CovidVaccinations_csv cvc 
    ON cdc.location = cvc.location 
    and cdc.date = cvc.date 
where  cdc.continent is NOT NULL 
)

SELECT *, (RollingPeopleVaccinated/population)*100
from PopvsVac

temptable


Create Table PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into PercentPopulationVaccinated
Select cdc.continent, cdc.location, cdc.date, cdc.population, cvc.new_vaccinations
, SUM(CONVERT(int,cvc.new_vaccinations)) OVER (Partition by cdc.Location Order by cdc.location, cdc.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM CovidDeaths_csv cdc 
JOIN CovidVaccinations_csv cvc 
	On cdc.location = cvc.location
	and cdc.date = cvc.date
	
Select * (RollingPeopleVaccinated/Population)*100
From PercentPopulationVaccinated	



Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From CovidDeaths_csv cdc 
Where continent is not null 
and location not in ()
Group by continent
order by TotalDeathCount 




Select Location, Population,date, MAX(total_cases) as HighestInfectionCount,  Max(total_cases/population)*100 as PercentPopulationInfected
From CovidDeaths_csv cdc 

Group by Location, Population, date
order by PercentPopulationInfected desc



 


 
