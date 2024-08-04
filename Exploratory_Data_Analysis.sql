SELECT *
FROM layoffs_staging2;


-- Quick look at maxima and minima
SELECT MAX(total_laid_off),
    MIN(total_laid_off),
    MAX(percentage_laid_off)
FROM layoffs_staging2;


-- Companies with highest layoff percentage
SELECT *
FROM layoffs_staging2
WHERE percentage_laid_off = (
        SELECT MAX(percentage_laid_off)
        FROM layoffs_staging2
    )
ORDER BY funds_raised_millions DESC;


-- Total employees laid off 
SELECT company,
    SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company
ORDER BY 2 DESC;


SELECT MIN(`date`),
    MAX(`date`)
FROM layoffs_staging2;


SELECT YEAR(`date`),
    SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY YEAR(`date`)
ORDER BY 1 DESC;


SELECT stage,
    SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY stage
ORDER BY 2 DESC;


SELECT MONTH(`date`),
    SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY MONTH(`date`)
ORDER BY 1;


SELECT SUBSTRING(`date`, 1, 7) AS `MONTH`,
    SUM(total_laid_off)
FROM layoffs_staging2
WHERE SUBSTRING(`date`, 1, 7) IS NOT NULL
GROUP BY `MONTH`
ORDER BY 1 ASC;


WITH rolling_total AS (
    SELECT SUBSTRING(`date`, 1, 7) AS `MONTH`,
        SUM(total_laid_off) AS total_off
    FROM layoffs_staging2
    WHERE SUBSTRING(`date`, 1, 7) IS NOT NULL
    GROUP BY `MONTH`
    ORDER BY 1 ASC
)
SELECT `MONTH`,
    total_off,
    SUM(total_off) OVER(
        ORDER BY `MONTH`
    ) AS rolling_total
FROM rolling_total;


SELECT company,
    YEAR(`date`),
    SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company,
    YEAR(`date`)
ORDER BY 3 DESC;


WITH Company_Year (Company, years, total_laid_off) AS (
    SELECT company,
        YEAR(`date`),
        SUM(total_laid_off)
    FROM layoffs_staging2
    GROUP BY company,
        YEAR(`date`)
),
Company_Year_Rank AS (
    SELECT *,
        DENSE_RANK() OVER(
            PARTITION BY years
            ORDER BY total_laid_off DESC
        ) AS ranking
    FROM Company_Year
    WHERE years IS NOT NULL
)
SELECT *
FROM Company_Year_Rank
WHERE Ranking <= 5;