Author: Md Asher

# 📊 COVID-19 Data Analysis Using SQL

This project demonstrates how to perform exploratory data analysis (EDA) and gain insights into the global COVID-19 pandemic using SQL. It analyzes data from **CovidDeaths** and **CovidVaccinations** datasets using various SQL queries and techniques including window functions, CTEs, and temp tables.

---

## 📁 Datasets Used

- `CovidDeaths_csv`: Contains information about daily COVID cases, deaths, and population data by location.
- `CovidVaccinations_csv`: Contains daily vaccination records for different countries.

---

## 📌 Key Analyses & Queries

### 1. **Initial Exploration**
```sql
SELECT * FROM CovidDeaths_csv cdc
WHERE continent IS NOT NULL
ORDER BY 3,4;

SELECT * FROM CovidVaccinations_csv cvc
ORDER BY 3,4;
```

---

### 2. **Cases vs Deaths (India)**
```sql
SELECT location, date, total_cases, total_deaths, 
       (total_deaths / total_cases) * 100 AS DeathPercentage
FROM CovidDeaths_csv cdc
WHERE location LIKE '%India%' AND continent IS NOT NULL
ORDER BY 1,2;
```

---

### 3. **Total Cases vs Population (India)**
```sql
SELECT location, date, population, total_cases, 
       (total_cases / population) * 100 AS PercentPopulationInfected
FROM CovidDeaths_csv cdc
WHERE location LIKE '%India%'
ORDER BY 1,2;
```

---

### 4. **Countries with Highest Infection Rate (Relative to Population)**
```sql
SELECT location, population, MAX(total_cases) AS HighestInfectionCount,
       MAX((total_cases / population)) * 100 AS PercentPopulationInfected
FROM CovidDeaths_csv cdc
GROUP BY population, location
ORDER BY PercentPopulationInfected DESC;
```

---

### 5. **Continents with Highest Death Counts**
```sql
SELECT continent, MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM CovidDeaths_csv cdc
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC;
```

---

### 6. **Global Aggregates**
```sql
SELECT SUM(new_cases) AS total_cases,
       SUM(new_deaths) AS total_deaths,
       SUM(new_deaths)/SUM(new_cases)*100 AS DeathPercentage
FROM CovidDeaths_csv cdc
WHERE continent IS NOT NULL;
```

---

## 💉 Vaccination Analysis

### 7. **Rolling People Vaccinated (Using JOIN and Window Function)**
```sql
SELECT cdc.continent, cdc.location, cdc.date, cdc.population,
       cvc.new_vaccinations,
       SUM(cvc.new_vaccinations) OVER (
            PARTITION BY cdc.location ORDER BY cdc.location, cdc.date
       ) AS RollingPeopleVaccinated
FROM CovidDeaths_csv cdc
JOIN CovidVaccinations_csv cvc
     ON cdc.location = cvc.location AND cdc.date = cvc.date
WHERE cdc.continent IS NOT NULL
ORDER BY 2,3;
```

---

### 8. **Using CTE for Percentage Population Vaccinated**
```sql
WITH PopvsVac AS (
    SELECT cdc.continent, cdc.location, cdc.date, cdc.population,
           cvc.new_vaccinations,
           SUM(cvc.new_vaccinations) OVER (
               PARTITION BY cdc.location ORDER BY cdc.location, cdc.date
           ) AS RollingPeopleVaccinated
    FROM CovidDeaths_csv cdc
    JOIN CovidVaccinations_csv cvc
         ON cdc.location = cvc.location AND cdc.date = cvc.date
    WHERE cdc.continent IS NOT NULL
)
SELECT *, (RollingPeopleVaccinated / population) * 100 AS VaccinationRate
FROM PopvsVac;
```

---

### 9. **Temp Table Approach**
```sql
CREATE TABLE PercentPopulationVaccinated (
    Continent NVARCHAR(255),
    Location NVARCHAR(255),
    Date DATETIME,
    Population NUMERIC,
    New_vaccinations NUMERIC,
    RollingPeopleVaccinated NUMERIC
);

INSERT INTO PercentPopulationVaccinated
SELECT cdc.continent, cdc.location, cdc.date, cdc.population, cvc.new_vaccinations,
       SUM(CONVERT(INT, cvc.new_vaccinations)) OVER (
           PARTITION BY cdc.location ORDER BY cdc.location, cdc.date
       ) AS RollingPeopleVaccinated
FROM CovidDeaths_csv cdc
JOIN CovidVaccinations_csv cvc
     ON cdc.location = cvc.location AND cdc.date = cvc.date;
```

Then, query the temp table:
```sql
SELECT *, (RollingPeopleVaccinated / Population) * 100 AS VaccinationPercentage
FROM PercentPopulationVaccinated;
```

---

## 🔍 Additional Insights

- Total deaths by country:
```sql
SELECT location, SUM(CAST(new_deaths AS INT)) AS TotalDeathCount
FROM CovidDeaths_csv cdc
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC;
```

- Highest infection rate by date and country:
```sql
SELECT location, population, date, MAX(total_cases) AS HighestInfectionCount,
       MAX(total_cases/population)*100 AS PercentPopulationInfected
FROM CovidDeaths_csv cdc
GROUP BY location, population, date
ORDER BY PercentPopulationInfected DESC;
```

---

## 🛠️ Tools Used

- **SQL Server / MySQL / PostgreSQL**
- **Data Source:** COVID-19 data (assumed pre-cleaned CSVs)
- **Techniques:** Window functions, CTEs, Temp tables, Aggregations

---

## 📌 Conclusion

This project demonstrates how SQL can be a powerful tool for data analysis. By using various techniques, you can uncover key insights about the pandemic, including death rates, infection spread, and vaccination progress across the globe.

---
