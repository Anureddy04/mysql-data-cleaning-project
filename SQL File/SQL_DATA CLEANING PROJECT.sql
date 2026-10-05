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