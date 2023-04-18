SELECT *
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
ORDER BY 3,4

-- Select data that we are going to be using

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2

-- Looking at the percentage between Total Cases and Total Deaths in Viet Nam
-- If you contract covid in VietNam, the percentage of your death will be very small.

SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage 
FROM PortfolioProject..CovidDeaths
WHERE Location like '%Viet%'
ORDER BY 1,2


-- Looking at the percentage between Total Cases and Population
-- Shows that percentage of population got Covid in Viet Nam

SELECT Location, date, Population, total_cases, (total_cases/Population)*100 as Got_Covid_Percentage 
FROM PortfolioProject..CovidDeaths
WHERE Location like '%Viet%'
ORDER BY Got_Covid_Percentage DESC

-- Looking at Countries with Highest Infection Rate compared to Population

SELECT Location, Population, MAX(total_cases) AS Infection_Count, Max((total_cases/Population)*100) as Highest_Got_Covid_Percentage 
FROM PortfolioProject..CovidDeaths
GROUP BY Location, Population
ORDER BY Highest_Got_Covid_Percentage DESC


-- Looking at Countries with Highest Death Count per Population

SELECT Location, MAX(CAST(Total_deaths AS int)) AS Total_Death_Count
FROM PortfolioProject..CovidDeaths
WHERE continent is not null 
GROUP BY  Location
ORDER BY Total_Death_Count DESC


--Looking at Continents with Highest Death Count per Population

SELECT continent, MAX(CAST(Total_deaths AS int)) AS Total_Death_Count
FROM PortfolioProject..CovidDeaths
WHERE continent is not null 
GROUP BY continent
ORDER BY Total_Death_Count DESC


-- GLOBAL NUMBERS
SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases) *100 as Death_Percentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not null 
--GROUP BY date 
ORDER BY 1,2



-- Looking at Total Population vs Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location ORDER BY dea.date) as Rolling_People_Vaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location
and dea.date=vac.date
WHERE dea.continent is not null
ORDER BY 2,3


--USE CTE
WITH POP_VAC (continent,location,date,population,new_vaccinations,Rolling_People_Vaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location ORDER BY dea.date) as Rolling_People_Vaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location
and dea.date=vac.date
WHERE dea.continent is not null
--ORDER BY 2,3
)
SELECT *, (Rolling_People_Vaccinated/Population)*100 as Percent_People_Vaccinated_perPopulation
FROM POP_VAC


--TEMP TABLE

DROP Table if exists #Percent_Population_Vaccinated
CREATE TABLE #Percent_Population_Vaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
Rolling_People_Vaccinated numeric
)


INSERT into #Percent_Population_Vaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location ORDER BY dea.date) as Rolling_People_Vaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location
and dea.date=vac.date
--WHERE dea.continent is not null
--ORDER BY 2,3

SELECT *, (Rolling_People_Vaccinated/Population)*100 as Percent_People_Vaccinated_perPopulation
FROM #Percent_Population_Vaccinated


-- Creating View to store data for later visualizations
Create View Percent_Population_Vaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location ORDER BY dea.date) as Rolling_People_Vaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location
and dea.date=vac.date
WHERE dea.continent is not null
--ORDER BY 2,3



SELECT *
FROM Percent_Population_Vaccinated