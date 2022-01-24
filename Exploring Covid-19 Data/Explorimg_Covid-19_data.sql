--EXPLORING COVID-19 DATA
--SQL functions used: Joins, CTE (Common Table Expression), Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types


--EXPLORING THE 'covid_deaths' TABLE

select * from covid_deaths where continent is not null order by 3,4

-- We are selecting the Data that we will use for further analysis

Select Location, date, total_cases, new_cases, total_deaths, population
From covid_deaths
Where continent is not null 
order by 1,2


-- We will find the percentage of deaths which will give us an idea about the likelihood of fatalness in case anyone contarcts covid-19

Select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as death_percentage
From covid_deaths
Where location like '%india%'
and continent is not null 
order by 1,2


-- We will find out the percentage of population which was infected by covid

Select Location, date, Population, total_cases,  (total_cases/population)*100 as percent_of_population_infected
From covid_deaths
order by 1,2


-- We will find out the Highest Infection Rate in different locations

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as percent_population_infected
From covid_deaths
Group by Location, Population
order by Percent_population_infected desc


-- We will find out the hightes death counts in different countries

Select Location, MAX(cast(Total_deaths as bigint)) as total_death_count
From covid_deaths
Where continent is not null 
Group by Location
order by total_death_count desc



-- We will now fetch continent wise data for highest death count in different continents

Select continent, MAX(cast(Total_deaths as bigint)) as total_death_count
From covid_deaths
Where continent is not null 
Group by continent
order by total_death_count desc


--We will find out the total number of Cases and total  number of Deaths Worldwide

Select SUM(cast(new_cases as bigint)) as total_cases, SUM(cast(new_deaths as bigint)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as death_percentage
From covid_deaths
where continent is not null

--EXPLORING THE 'Covid_vaccination' TABLE

select * from Covid_vaccination where continent is not null order by 3,4

-- We will now fetch the location wise cumulative count of vaccinations

Select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations
, SUM(CONVERT(bigint,cv.new_vaccinations)) OVER (Partition by cd.Location Order by cd.location, cd.Date) as cumulative_vaccinations
From covid_deaths cd
Join Covid_vaccination cv
	On cd.location = cv.location
	and cd.date = cv.date
where cd.continent is not null 
order by 2,3


--We will use CTE (Common Table Expresiosn) on the previous partion by query to show percentage of population that has recieved at least one Covid Vaccine

With covid_details (Continent, Location, Date, Population, New_Vaccinations, cumulative_vaccinations)
as
(
Select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations
, SUM(CONVERT(bigint,cv.new_vaccinations)) OVER (Partition by cd.Location Order by cd.location, cd.Date) as cumulative_vaccinations
From covid_deaths cd
Join Covid_vaccination cv
	On cd.location = cv.location
	and cd.date = cv.date
where cd.continent is not null 
)
Select *, (cumulative_vaccinations/Population)*100 as percentage_of_vaccinated_population
From covid_details


--ALTERNATE WAY: We will use Temporaray Table (temp. table) on the previous partion by query to show percentage of population that has recieved at least one Covid Vaccine

DROP Table if exists #covid_19_details
Create Table #covid_19_details
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
Cumulative_Vaccinations bigint
)

Insert into #covid_19_details
Select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations
, SUM(CONVERT(bigint,cv.new_vaccinations)) OVER (Partition by cd.Location Order by cd.location, cd.Date) as cumulative_vaccinations
From covid_deaths cd
Join Covid_vaccination cv
	On cd.location = cv.location
	and cd.date = cv.date
where cd.continent is not null 

Select *, (cumulative_vaccinations/Population)*100 as percentage_of_vaccinated_population
From #covid_19_details


--We will now create and save a view for future reference

Create View Vaccination_details as
Select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations
, SUM(CONVERT(bigint,cv.new_vaccinations)) OVER (Partition by cd.Location Order by cd.location, cd.Date) as cumulative_vaccinations
From  covid_deaths cd
Join Covid_vaccination cv
	On cd.location = cv.location
	and cd.date = cv.date
where cd.continent is not null 

select * from Vaccination_details