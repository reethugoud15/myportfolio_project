select * from sqlt..coviddeaths;

-- Select the data that we are going to use
Select Location, date, total_cases, new_cases, total_deaths, population from sqlt..CovidDeaths where location = 'Nicaragua';



--Total Vaccinations by Location:

SELECT
    location,
    SUM(cast(people_vaccinated as float)) AS TotalVaccinations
FROM
    sqlt..CovidVaccinations
GROUP BY
    location
ORDER BY
    TotalVaccinations DESC;



--Total Deaths by Location:
SELECT
    location,
    SUM(cast(new_deaths as int)) AS TotalDeaths
FROM
    sqlt..CovidDeaths
GROUP BY
    location
ORDER BY
    TotalDeaths DESC;


--Daily Deaths Trend:

SELECT
    date,
    SUM(cast(new_deaths as int)) AS DailyDeaths
FROM
    sqlt..CovidDeaths
GROUP BY
    date
ORDER BY
    date;

--Total cases Vs Total Deaths



SELECT 
    Location, 
    MAX(CAST(total_cases AS INT)) AS tc, 
    MAX(CAST(total_deaths AS INT)) AS td, 
    MAX(CAST(total_deaths AS float))/nullif(MAX(CAST(total_cases AS float)),0) * 100 AS deathpercentage 
FROM
    sqlt..CovidDeaths
where continent != ''	
GROUP BY 
    Location 
ORDER BY 
    deathpercentage DESC;


--Deaths by continent

SELECT Location,
max(cast(total_deaths as float)) as total_deaths_continent
FROM
	sqlt..CovidDeaths
WHERE
	continent = ''
GROUP BY
	Location 
order by
	location desc;



--What country has highest infection rate compared to the population


Select location,  population, max(total_cases), max(convert(float,total_cases))/max(nullif(convert(float,population),0)) from sqlt..CovidDeaths
Group by location, population;

-- Analyzing vaccination data along with population information

SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations, 
       SUM(CONVERT(INT, cv.new_vaccinations)) OVER (PARTITION BY cd.Location ORDER BY cd.location, cd.Date) AS RollingPeopleVaccinated
FROM SQLT..CovidDeaths AS cd
JOIN SQLT..CovidVaccinations AS cv ON cd.location = cv.location AND cd.date = cv.date
WHERE cd.continent IS NOT NULL 
ORDER BY 2, 3;

-- Calculating the percentage of population vaccinated using a Common Table Expression (CTE)

WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS (
    SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
           SUM(CONVERT(INT, cv.new_vaccinations)) OVER (PARTITION BY cd.Location ORDER BY cd.location, cd.Date) AS RollingPeopleVaccinated
    FROM SQLT..CovidDeaths AS cd
    JOIN SQLT..CovidVaccinations AS cv ON cd.location = cv.location AND cd.date = cv.date
    WHERE cd.continent IS NOT NULL 
)
SELECT *, (RollingPeopleVaccinated / Population) * 100
FROM PopvsVac;

-- Using a temporary table to calculate the percentage of population vaccinated

DROP TABLE IF EXISTS #PercentPopulationVaccinated;

CREATE TABLE #PercentPopulationVaccinated (
    Continent NVARCHAR(255),
    Location NVARCHAR(255),
    Date DATETIME,
    Population NUMERIC,
    New_vaccinations NUMERIC,
    RollingPeopleVaccinated NUMERIC
);

INSERT INTO #PercentPopulationVaccinated
SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
       SUM(CONVERT(INT, cv.new_vaccinations)) OVER (PARTITION BY cd.Location ORDER BY cd.location, cd.Date) AS RollingPeopleVaccinated
FROM SQLT..CovidDeaths AS cd
JOIN SQLT..CovidVaccinations AS cv ON cd.location = cv.location AND cd.date = cv.date;

SELECT *, (RollingPeopleVaccinated / Population) * 100
FROM #PercentPopulationVaccinated;

-- Creating a view to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated AS
SELECT 
    cd.continent, 
    cd.location, 
    cd.date, 
    cd.population, 
    cv.new_vaccinations,
    SUM(CONVERT(INT, cv.new_vaccinations)) OVER (PARTITION BY cd.Location ORDER BY cd.location, cd.Date) AS RollingPeopleVaccinated
FROM 
    SQLT..CovidDeaths AS cd
JOIN 
    sqlt..CovidVaccinations AS cv ON cd.location = cv.location AND cd.date = cv.date
WHERE 
    cd.continent IS NOT NULL;




