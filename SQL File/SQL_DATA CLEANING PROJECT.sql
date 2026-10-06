-- Data Cleaning --
use World_layoffs;
select * from layoffs;

-- 1.Remove Duplicates
-- 2.Standardize the Data
-- 3.Null Values or blank Values
-- 4.Remove any Columns

create table layoffs_staging
LIKE layoffs;
INSERT INTO layoffs_staging
SELECT * FROM layoffs;

SELECT * FROM  layoffs_staging;

SELECT *,
ROW_NUMBER() OVER(PARTITION BY company,location,industry,total_laid_off,percentage_laid_off,'date',stage,country,funds_raised_millions) as row_num
from layoffs_staging;

with duplicate_cte as
(
SELECT *,
ROW_NUMBER() OVER(PARTITION BY company,location,industry,total_laid_off,percentage_laid_off,'date',stage,country,funds_raised_millions) as row_num
FROM layoffs_staging
)
SELECT * 
FROM duplicate_cte
WHERE row_num >1;

SELECT * from layoffs_staging
WHERE company = 'casper';


with duplicate_cte as
(
SELECT *,
ROW_NUMBER() OVER(PARTITION BY company,location,industry,total_laid_off,percentage_laid_off,'date',stage,country,funds_raised_millions) as row_num
FROM layoffs_staging
)
DELETE 
FROM duplicate_cte
WHERE row_num >1;

set SQL_SAFE_UPDATES=0;
CREATE TABLE `layoffs_staging2`(
     `company` text,
     `location` text,
     `industry` text,
     `total_laid_off` int DEFAULT NULL,
     `percentage_laid_off` text,
     `date` text,
     `stage` text,
     `country` text,
     `funds_raised_millions` int DEFAULT null,
     `row_num` INT
)ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

SELECT *
FROM layoffs_staging2;

INSERT INTO layoffs_staging2
SELECT *,
ROW_NUMBER() OVER(PARTITION BY company,location,industry,total_laid_off,percentage_laid_off,'date',stage,country,funds_raised_millions) as row_num
from layoffs_staging;


SELECT *
FROM layoffs_staging2
where row_num>1;

delete
FROM layoffs_staging2
where row_num>1;

-- Standardizing data 
SELECT company, TRIM(company)
from layoffs_staging2;

UPDATE layoffs_staging2
set company=TRIM(company);

SELECT distinct industry
from layoffs_staging2
order by 1;

SELECT *
from layoffs_staging2
where industry LIKE 'Crypto%';

UPDATE layoffs_staging2
SET industry = 'Crypto'
where industry LIKE 'Crypto%';

SELECT distinct location
from layoffs_staging2
order by 1;

SELECT distinct country
from layoffs_staging2
order by 1;

SELECT distinct country
from layoffs_staging2
WHERE country LIKE 'United States%'
order by 1;

SELECT distinct country, TRIM(TRAILING '.' FROM country)
from layoffs_staging2
order by 1;

UPDATE layoffs_staging2
SET country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE 'United States';

SELECT `date`
FROM layoffs_staging2;

SELECT `date`,
STR_TO_DATE(`date`, '%m/%d/%Y')
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;

SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

SELECT *
from layoffs_staging2
where industry IS NULL
or industry = '';

SELECT *
from layoffs_staging2
where company = 'Airbnb';

update layoffs_staging2
SET industry = NULL
WHERE industry = ''; 

SELECT t1.industry,t2.industry
FROM layoffs_staging2 t1
join layoffs_staging2 t2
ON t1.company = t2.company
WHERE t1.industry IS NULL AND t2.industry IS NOT NULL;

UPDATE layoffs_staging2 t1
join layoffs_staging2 t2
ON  t1.company = t2.company
SET t1.industry = t2.industry
where t1.industry IS NULL AND t2.industry IS NOT NULL;

SELECT *
from layoffs_staging2
where company LIKE 'Bally%';

SELECT *
from layoffs_staging2;

SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

DELETE 
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

ALTER TABLE layoffs_staging2
DROP COLUMN row_num;

SELECT *
FROM layoffs_staging2;

select MAX(total_laid_off), MAX(percentage_laid_off)
FROM layoffs_staging2;

SELECT *
FROM layoffs_staging2
WHERE percentage_laid_off=1
order by total_laid_off desc;

SELECT *
FROM layoffs_staging2
WHERE percentage_laid_off=1
order by funds_raised_millions desc;

SELECT company,sum(total_laid_off)
from layoffs_staging2
group by company
order by 2 DESC;

select min(date) , max(date)
from layoffs_staging2;

SELECT industry,sum(total_laid_off)
from layoffs_staging2
group by industry
order by 2 desc;

SELECT country,sum(total_laid_off)
from layoffs_staging2
group by country
order by 2 DESC;

SELECT `date` ,sum(total_laid_off)
from layoffs_staging2
group by `date`
order by 1 DESC;

SELECT year(`date`),sum(total_laid_off)
from layoffs_staging2
group by year(`date`)
order by 2 DESC;

SELECT stage,sum(total_laid_off)
from layoffs_staging2
group by stage
order by 2 DESC;

SELECT company,sum(percentage_laid_off)
from layoffs_staging2
group by company
order by 2 DESC;

SELECT company,avg(percentage_laid_off)
from layoffs_staging2
group by company
order by 2 DESC;

SELECT month(`date`),sum(total_laid_off)
from layoffs_staging2
group by month(`date`)
order by 2 DESC;

select substring(`date`,1,7) as `month`, sum(total_laid_off)
from layoffs_staging2
where substring(`date`,1,7) is not null
group by `month`
order by 1 desc;

with Rolling_Total as 
(
select substring(`date`,1,7) as `month`, sum(total_laid_off) as total_off
from layoffs_staging2
where substring(`date`,1,7) is not null
group by `month`
order by 1
)
select `month`, total_off,
sum(total_off) over(order by `month`) as rolling_total
from Rolling_Total;

SELECT company,sum(total_laid_off)
from layoffs_staging2
group by company
order by 2 DESC;

SELECT company,year(`date`),sum(total_laid_off)
from layoffs_staging2
group by company,year(`date`)
order by 3 desc;

with Company_Year (company, years,total_laid_off) as
(
SELECT company,year(`date`),sum(total_laid_off)
from layoffs_staging2
group by company,year(`date`)
)
select *, dense_rank() over(partition by years order by total_laid_off desc) as ranking
from Company_Year
where years is not null
order by ranking;

with Company_Year (company, years,total_laid_off) as
(
SELECT company,year(`date`),sum(total_laid_off)
from layoffs_staging2
group by company,year(`date`)
),company_year_rank as
(select *, dense_rank() over(partition by years order by total_laid_off desc) as ranking
from Company_Year
where years is not null
)
select * from company_year_rank
where ranking <=5;
