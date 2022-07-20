
CREATE VIEW forestation 
AS (SELECT
fa.*,
la.total_area_sq_mi,
re.region,
re.income_group,
((fa.forest_area_sqkm)/(la.total_area_sq_mi*2.59))*100 AS percent_designated_forest
FROM forest_area fa
JOIN land_area la 
ON fa.country_code=la.country_code and fa.year = la.year
JOIN regions re
ON la.country_code=re.country_code);

/* - - - -  - */

SELECT
fo.forest_area_sqkm
FROM
forestation fo
WHERE
fo.year=1990 and
fo.country_name='World';

/* - - - -  - */

SELECT
fo.forest_area_sqkm
FROM
forestation fo
WHERE
fo.year=2016 and
fo.country_name='World';

/* - - - -  - */

WITH t1 AS(
SELECT
*
FROM
forestation fo
WHERE
fo.year=1990 and
fo.country_name='World'),
t2 AS (
SELECT
*
FROM
forestation fo
WHERE
fo.year=2016 and
fo.country_name='World')

SELECT
t2.forest_area_sqkm - t1.forest_area_sqkm AS change_sqkm,
((t2.forest_area_sqkm/t1.forest_area_sqkm)-1)*100 AS pct_change_sqkm
FROM
t1
JOIN t2
ON t1.country_name = t2.country_name;

/* - - - -  - */
WITH t1 AS(
SELECT
*
FROM
forestation fo
WHERE
fo.year=1990 and
fo.country_name='World'),
t2 AS (
SELECT
*
FROM
forestation fo
WHERE
fo.year=2016 and
fo.country_name='World')

SELECT
fs.country_name,
fs.forest_area_sqkm,
(abs(fs.forest_area_sqkm - sub1.change_sqkm)) as difference_abs
FROM
forestation fs,
	(SELECT
	t1.forest_area_sqkm - t2.forest_area_sqkm AS change_sqkm
	FROM
	t1
	JOIN t2
	ON t1.country_name = t2.country_name) sub1
WHERE fs.year=2016 
     and fs.forest_area_sqkm IS NOT NULL
ORDER BY difference_abs
LIMIT 1;

/* - - - -  - */

CREATE VIEW forestation_region
AS (SELECT
re.region,
fa.year,
(sum(fa.forest_area_sqkm)/sum(la.total_area_sq_mi*2.59))*100 AS percent_designated_forest
FROM forest_area fa
JOIN land_area la 
ON fa.country_code=la.country_code and fa.year = la.year
JOIN regions re
ON la.country_code=re.country_code
GROUP BY 1,2);

/* - - - -  - */

SELECT *
FROM forestation_region
WHERE
 region = 'World' and
 year = 2016;
 
 /* - - - -  - */
 
 SELECT *
FROM forestation_region
WHERE year = 2016 and region != 'World'
ORDER BY percent_designated_forest DESC
LIMIT 1;

 /* - - - -  - */

SELECT *
FROM forestation_region
WHERE year = 2016 and region != 'World'
ORDER BY percent_designated_forest
LIMIT 1;

 /* - - - -  - */
 
 SELECT *
FROM forestation_region
WHERE
 region = 'World' and
 year = 1990;
 
 /* - - - -  - */
 
 SELECT *
FROM forestation_region
WHERE year = 1990 and region != 'World'
ORDER BY percent_designated_forest DESC
LIMIT 1;

 /* - - - -  - */

SELECT *
FROM forestation_region
WHERE year = 1990 and region != 'World'
ORDER BY percent_designated_forest
LIMIT 1;
 
  /* - - - -  - */
  
WITH region_1990 AS(
SELECT
*
FROM
forestation_region fo
WHERE
fo.year=1990 ),
region_2016 AS (
SELECT
*
FROM
forestation_region fo
WHERE
fo.year=2016)

SELECT
r90.region,
r90.percent_designated_forest as perc_1990,
r16.percent_designated_forest as perc_2016
FROM
region_1990 r90
JOIN region_2016 r16
ON r90.region = r16.region;

/* - - - -  - */

WITH country_1990 AS
(SELECT
fa.country_name,
fa.forest_area_sqkm AS forest_area_1990,
la.total_area_sq_mi AS land_area_1990
FROM forest_area fa
JOIN land_area la 
ON fa.country_code=la.country_code and fa.year = la.year
WHERE
fa.year=1990),
country_2016 AS 
(SELECT
fa.country_name,
fa.forest_area_sqkm AS forest_area_2016,
la.total_area_sq_mi AS land_area_2016
FROM forest_area fa
JOIN land_area la 
ON fa.country_code=la.country_code and fa.year = la.year
WHERE
fa.year=2016)

SELECT
c90.*,
c16.forest_area_2016,
c16.land_area_2016,
c16.forest_area_2016-c90.forest_area_1990 AS diff_absolute_fa,
((c16.forest_area_2016/c90.forest_area_1990)-1)*100 AS diff_relative_fa
FROM
country_1990 c90
JOIN country_2016 c16
ON c90.country_name = c16.country_name
WHERE forest_area_1990 IS NOT NULL and
forest_area_2016 IS NOT NULL
ORDER BY diff_absolute_fa DESC;



