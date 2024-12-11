
-- Exploratary Data Analytics

-- Analyze 100% layoffs from biggest companies

select *
from layoffs_staging2
where percentage_laid_off = 1
order by funds_raised_millions desc;

-- Analyze maximum employees laid off
select max(total_laid_off), max(percentage_laid_off)
from layoffs_staging2;

-- Understand the amount layoffs every year
select year(`date`), sum(total_laid_off)
from layoffs_staging2
group by year(`date`)
order by 1 desc;


-- Analyze Monthly layoff pattern
select substr(`date`,1,7) as `MONTH`, sum(total_laid_off)
from layoffs_staging2
where substr(`date`,1,7) is not null
group by `MONTH`
order by 1 asc
;

-- Common Table Expression to produce rolling total

with rolling_total as 
(
select substr(`date`,1,7) as `MONTH`, sum(total_laid_off) as total_off
from layoffs_staging2
where substr(`date`,1,7) is not null
group by `MONTH`
order by 1 asc
)
select `MONTH`, total_off,
sum(total_off) over(order by `MONTH`) as Rolling_Total
from rolling_total;


select company, year(`date`), sum(total_laid_off)
from layoffs_staging2
group by company, year(`date`)
order by 3 desc;



-- Complex CTE (common table expression) to analyze top 5 companies to layoff employees every year
-- Dense Rank, and partition usage

with company_year (company, years, total_laid_off) as
(
select company, year(`date`), sum(total_laid_off)
from layoffs_staging2
group by company, year(`date`)
order by 3 desc
),company_year_rank as 
(
select *, dense_rank() over(partition by years order by total_laid_off desc) as ranking
from company_year
where years is not null
)
select * from company_year_rank
where ranking <= 5; 
