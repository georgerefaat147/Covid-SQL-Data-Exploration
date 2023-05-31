CREATE database Covid_Project ;
select * from `covid-data vacinated` order by 3, 4 ;
select * from `covid-data  death` order by 3, 4 ;
SELECT  STR_TO_DATE(date, '%m/%d/%Y')
FROM    `covid-data  death` ;

SELECT  STR_TO_DATE(date, '%m/%d/%Y')
FROM    `covid-data vacinated` ;

UPDATE `covid-data  death` SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');
UPDATE `covid-data vacinated` SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');
select total_cases from`covid-data  death`;
select total_deaths from`covid-data  death`;
ALTER TABLE `covid-data  death` 
MODIFY COLUMN total_cases int;
UPDATE `covid-data  death` SET total_cases = IF(total_cases = '', '0', total_cases);
UPDATE `covid-data  death` SET total_deaths = IF(total_deaths = '', '0',total_deaths);
UPDATE `covid-data vacinated` SET total_vaccinations = IF(total_vaccinations = '', '0',total_vaccinations);

UPDATE `covid-data vacinated` SET new_vaccinations = IF(new_vaccinations = '', '0',new_vaccinations);

ALTER TABLE `covid-data  death` MODIFY COLUMN total_cases INT UNSIGNED DEFAULT 0 NULL;

ALTER TABLE `covid-data  death` MODIFY COLUMN total_deaths INT UNSIGNED DEFAULT 0 NULL;
ALTER TABLE `covid-data vacinated` MODIFY COLUMN total_vaccinations INT UNSIGNED DEFAULT 0 NULL;
ALTER TABLE `covid-data vacinated` MODIFY COLUMN new_vaccinations INT UNSIGNED DEFAULT 0 NULL;

#Selecting data that i am gonig to use

select location , date , total_cases , total_deaths, population from `covid-data  death` order by 1 ,2;

#looking at total cases vs total deaths

select location , date , total_cases , total_deaths , (total_deaths/total_cases)*100  as 'percentage' from `covid-data  death` 
where location like ('%states') order by 1 ,2 
;

#looking at total cases vs the population 
select location , date , total_cases , population , ((total_cases/population)*100) as 'percentage' from `covid-data  death` 
#where location like ('%states') 
order by 1 ,2 ;

#countries with high infection rate compared to the population 
 select location , population , max(total_cases) as Highist_Infection_Count  ,    max((total_cases/population))*100 as 'percentage' from `covid-data  death` 
group by location , population
order by percentage desc   ;

#countries with high infection rate compared to the population 
 select location , population, date , max(total_cases) as Highist_Infection_Count  ,    max((total_cases/population))*100 as 'percentage' from `covid-data  death` 
group by location , population ,date
order by percentage desc   ;

#countries with death rate compared to the population 

select location , max(total_deaths) as tota_death_count from `covid-data  death`
where continent != ""
group by location 
order by tota_death_count desc ;

#continent with death rate compared to the population 
select continent , max(total_deaths) as tota_death_count from `covid-data  death`
where continent != ""
group by continent 
order by tota_death_count desc ;

select location , max(total_deaths) as tota_death_count from `covid-data  death`
where continent = ""
group by  location
order by tota_death_count desc ;

#Global numbers 
select  sum(new_cases)  as total_cases, sum(total_deaths) as total_deathes ,sum(new_deaths )/ sum(new_cases)*100 as DeathPercentage
from `covid-data  death` 
where continent  != ""
#group by date
order by 1 ,2 ;

#total population vs vacination
select dea.continent, dea.location, dea.population, vac.new_vaccinations
, sum(vac.new_vaccinations) over(partition by dea.location order by dea.location and dea.date) as rolling_People_Vacinated 
from `covid-data  death` dea
join `covid-data vacinated` vac
on dea.location= vac.location
and dea.date = vac.date 
where dea.continent  != ""
order by 2,3 ;

#Use CTE

with Pop_VS_Vac ( continent, location, date ,population ,new_vaccinations,rolling_People_Vacinated)
as (
select dea.continent, dea.location,dea.date , dea.population, vac.new_vaccinations
, sum(vac.new_vaccinations) over(partition by dea.location order by dea.location , dea.date) as rolling_People_Vacinated 
from `covid-data  death` dea
join `covid-data vacinated` vac
on dea.location= vac.location
and dea.date = vac.date 
where dea.continent  != "")
#order by 2,3 
select *,(rolling_People_Vacinated/population)*100
from Pop_VS_Vac ;


#Temp Table
create table Percent_Population_Vaccinated
(continent nvarchar (255),
Location nvarchar (255),
Date datetime,
Population numeric,
New_Vaccination numeric,
Rolling_People_Vaccinated numeric
);

insert into Percent_Population_Vaccinated
with Pop_VS_Vac ( continent, location, date ,population ,new_vaccinations,rolling_People_Vacinated)
as (
select dea.continent, dea.location,dea.date , dea.population, vac.new_vaccinations
, sum(vac.new_vaccinations) over(partition by dea.location order by dea.location , dea.date) as rolling_People_Vacinated 
from `covid-data  death` dea
join `covid-data vacinated` vac
on dea.location= vac.location
and dea.date = vac.date )
#where dea.continent  != "")
#order by 2,3 
select *,(rolling_People_Vacinated/population)*100
from  Percent_Population_Vaccinated;

#Creating view to store in data later

Create View Percent_Population_Vaccinated as
select dea.continent, dea.location,dea.date , dea.population, vac.new_vaccinations
, sum(vac.new_vaccinations) over(partition by dea.location order by dea.location , dea.date) as rolling_People_Vacinated 
from `covid-data  death` dea
join `covid-data vacinated` vac
on dea.location= vac.location
and dea.date = vac.date 
where dea.continent  != ""
order by 2,3 