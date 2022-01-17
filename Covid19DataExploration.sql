--EXPLORING GLOBAL COVID-19 DATA

--DISPLAY DATA SORTED BY LOCATION AND DATE
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..covid_deaths
ORDER BY 1,2;


--DEATHS PER CASES
--Shows likelihood of dying if someone contracted Covid-19 in Indonesia
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage
FROM PortfolioProject..covid_deaths
WHERE location = 'Indonesia'
ORDER BY 1,2;


-- GLOBAL DEATH RATE
--Shows global likelihood of dying if someone contracted Covid-19
SELECT date, SUM(new_cases) AS total_cases_daily, SUM(CAST(new_deaths AS INT)) AS total_deaths_daily, 100 * (SUM(CAST(new_deaths AS INT))) / (SUM(new_cases)) AS death_percentage_daily
FROM PortfolioProject..covid_deaths
WHERE continent IS NOT NULL AND new_cases IS NOT NULL
GROUP BY date
ORDER BY 1;


-- GLOBAL NUMBERS
--Percentage of deaths per cases globally
SELECT SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS INT)) AS total_deaths, 100 * (SUM(CAST(new_deaths AS INT))) / (SUM(new_cases)) AS global_death_percentage
FROM PortfolioProject..covid_deaths
WHERE continent IS NOT NULL AND new_cases IS NOT NULL


--TOTAL CASES VS POPULATION
--Shows the percentage of population who had contracted Covid in Indonesia
SELECT location, date, total_cases, population, (total_cases/population)*100 as positive_case_percentage
FROM PortfolioProject..covid_deaths
WHERE location = 'Indonesia'
ORDER BY 2;


--COUNTRY WITH THE HIGHEST INFECTION RATE
--Shows country with highest number of cases within its population (in percentage)
SELECT location, population, MAX(total_cases) as highest_case, MAX((total_cases/population)*100) AS infection_rate
FROM PortfolioProject..covid_deaths
GROUP BY location, population
ORDER BY infection_rate DESC;


--COUNTRY WITH THE HIGHEST DEATH RATE
--Shows country with highest number of deaths within its population (in percentage)
SELECT location, MAX(cast(total_deaths as int)) as highest_death, MAX((total_deaths/population)*100) AS death_rate
FROM PortfolioProject..covid_deaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY death_rate DESC;

--CONTINENT WITH THE HIGHEST DEATH RATE
--Shows continent with highest number of cases within its population (in percentage)
SELECT a.continent, SUM(a.population) AS continent_population, SUM(a.total_deaths_by_country) AS deaths_by_continent, 100*(SUM(a.total_deaths_by_country))/(SUM(a.population)) AS continent_death_rate
FROM
	(SELECT continent, location, population, MAX(cast(total_deaths as int)) as total_deaths_by_country
	FROM PortfolioProject..covid_deaths
	WHERE continent IS NOT NULL
	GROUP BY continent, location, population) a
GROUP BY continent
ORDER BY continent_death_rate DESC

--TOTAL DEATH COUNT BY CONTINENT
SELECT continent, SUM(death_count_by_country) AS death_count_by_continent
FROM
	(SELECT continent, location, MAX(cast(total_deaths as int)) AS death_count_by_country
	FROM PortfolioProject..covid_deaths
	WHERE continent IS NOT NULL
	GROUP BY continent, location) a
GROUP BY continent
ORDER BY death_count_by_continent DESC;

--VACCINATION RATE
--Shows the percentage of total global population that had been vaccinated
SELECT SUM(vax_by_country.country_population) AS global_population, SUM(vax_by_country.country_vaccinated) AS global_vaccinated, 100 * (SUM(vax_by_country.country_vaccinated)) / (SUM(vax_by_country.country_population)) AS vaccination_rate
FROM
(SELECT ded.location, MAX(ded.population) AS country_population, MAX(CAST(vax.people_vaccinated AS FLOAT)) as country_vaccinated
FROM covid_deaths ded
JOIN covid_vaccinations vax
ON ded.location = vax.location
AND ded.date = vax.date
WHERE ded.continent IS NOT NULL
GROUP BY ded.location) vax_by_country

--ROLLING VACCINATION RATE
--Shows the rolling percentage of vaccinated people in each country on a daily basis
SELECT ded.continent, ded.location, ded.date, ded.population, vax.new_vaccinations, SUM(CAST(vax.new_vaccinations AS float)) OVER (PARTITION BY ded.location ORDER BY ded.location, ded.date) AS rolling_people_vaccinated
FROM covid_deaths ded
JOIN covid_vaccinations vax
	ON ded.location = vax.location
	AND ded.date = vax.date
WHERE ded.continent IS NOT NULL
ORDER BY 2,3


--CREATE VIEW FOR VACCINATED PERCENTAGE
CREATE VIEW vaccination_percentage AS
SELECT ded.continent, ded.location, ded.date, ded.population, vax.new_vaccinations, SUM(CAST(vax.new_vaccinations AS float)) OVER (PARTITION BY ded.location ORDER BY ded.location, ded.date) AS rolling_people_vaccinated
FROM covid_deaths ded
JOIN covid_vaccinations vax
	ON ded.location = vax.location
	AND ded.date = vax.date
WHERE ded.continent IS NOT NULL