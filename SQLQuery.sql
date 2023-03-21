--selecting all the data to check the connection
select *
From Portfolioproject..CovidDeaths
where continent is not null
order by 3,4

--select *
--From Portfolioproject..vaccinationCleaned
--order by 3,4


--selecting all the data we need
select location,population,date,new_cases,total_cases,total_deaths
FROM Portfolioproject..CovidDeaths
where continent is not null
order by 1,2

--looking at total cases vs total deaths
--taking a look at total percentage of people who died and likelihood of catching the disease with respect to given past years

SELECT location,total_cases,total_deaths,(total_deaths/total_cases)*100 as Death_percentage
FROM Portfolioproject..CovidDeaths
where continent is not null
order by 1,2


--looking at  death percentage data from india
SELECT location,total_cases,total_deaths,(total_deaths/total_cases)*100 as Death_percentage
FROM Portfolioproject..CovidDeaths
where location like '%India%'
order by 1,2


--looking at total cases vs population
--shows total number of infected population in comparision to total population
SELECT location,population,total_cases,(total_deaths/total_cases)*100 as Death_percentage
FROM Portfolioproject..CovidDeaths
where location like '%India%'
order by 1,2


--looking at countries at highst infection rate compared to population
SELECT location,population,max(total_cases)as Highest_Infection_Count,max(total_cases/population)*100 as infected_population_percentage
FROM Portfolioproject..CovidDeaths
where continent is not null
group by location,population
order by infected_population_percentage desc

--show countries with highest death rate and death_count  compared to population
SELECT location,population,max(cast(total_deaths as int))as Highest_Death_Count ,max(total_deaths/population)*100 as Death_percentage_of_population
FROM Portfolioproject..CovidDeaths
where continent is not null
group by location,population
order by Highest_Death_Count  desc


--grouping the data by continent   with highest death rate 
SELECT continent,max(cast(total_deaths as int))as Highest_Death_Count 
FROM Portfolioproject..CovidDeaths
where continent is not null
group by continent
order by Highest_Death_Count  desc

--Global Numbers

 
SELECT   sum(cast(total_cases as bigint)) as total_world_cases ,sum(cast(new_deaths as bigint)) as total_world_deaths--, (sum(new_deaths)/SUM(new_cases))*100
FROM Portfolioproject..CovidDeaths --gives arithematic ovwerflow if int is used as the dataset has grown considerably.
where continent is not null
AND total_cases is not null
and new_deaths is not null
--Group by date
order by 1,2

--looking at total vaccination vs total population

select CovidDeaths.continent,CovidDeaths.location,CovidDeaths.population,CovidDeaths.date,vaccinationCleaned.new_vaccinations,
SUM(convert(bigint,vaccinationCleaned.new_vaccinations)) over (partition by CovidDeaths.location order by CovidDeaths.location,
CovidDeaths.date) as rolling_people_vaccinated
--,(rolling_people_vaccinated/population)*100 as vaccination_percentage
From  Portfolioproject..CovidDeaths
JOIN Portfolioproject..vaccinationCleaned
on CovidDeaths.location= vaccinationCleaned.location
and CovidDeaths.date= vaccinationCleaned.date
where CovidDeaths.continent is not null
order by 2,3



--using CTE
with popvsvac(continent,location,population,date,new_vaccinations,rolling_people_vaccinated,people_vaccinated
)
as
(
select CovidDeaths.continent,CovidDeaths.location,population,CovidDeaths.date,vaccinationCleaned.new_vaccinations,
SUM(convert(bigint,vaccinationCleaned.people_vaccinated)) over (partition by CovidDeaths.location order by CovidDeaths.location,
CovidDeaths.date) as rolling_people_vaccinated,people_vaccinated


From  Portfolioproject..CovidDeaths
JOIN Portfolioproject..vaccinationCleaned
on CovidDeaths.location= vaccinationCleaned.location
and CovidDeaths.date= vaccinationCleaned.date
where CovidDeaths.continent is not null
--order by 2,3
)
select * , (people_vaccinated
/population)*100 as vaccination_percentage
from popvsvac

--CreATING VIEW fOR vISUALIZATION lATER

Create View  vaccinated_population as


select CovidDeaths.continent,CovidDeaths.location,population,CovidDeaths.date,vaccinationCleaned.new_vaccinations,
SUM(convert(bigint,vaccinationCleaned.people_vaccinated)) over (partition by CovidDeaths.location Order by CovidDeaths.location,
CovidDeaths.date) as rolling_people_vaccinated,people_vaccinated
From  Portfolioproject..CovidDeaths
JOIN Portfolioproject..vaccinationCleaned
on CovidDeaths.location= vaccinationCleaned.location
and CovidDeaths.date= vaccinationCleaned.date
where CovidDeaths.continent is not null
--order by 2,3


SELECT * FROM sys.views WHERE name = 'vaccinated_population'