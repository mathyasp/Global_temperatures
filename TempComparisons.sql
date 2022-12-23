-- View the data
SELECT *
FROM GlobalLandTemperaturesByCountry

SELECT *
FROM GlobalTemperatures

SELECT *
FROM GlobalLandTemperaturesByMajorCity

-- View Major Countries' Temperature Trends Since 1900
SELECT 
	DATEPART(yyyy, dt) AS Years, 
	Country, 
	AVG(CONVERT(FLOAT, AverageTemperature)) AS AvgTemp
FROM GlobalLandTemperaturesByCountry 
WHERE Country IN ('United States', 'United Kingdom', 'China', 'Russia', 'India', 'Brazil', 'Australia')
AND DATEPART(yyyy, dt) >= 1900
GROUP BY DATEPART(yyyy, dt), Country
ORDER BY Country, DATEPART(yyyy, dt) DESC

-- View Global Temperature Trends Since 1900
SELECT DATEPART(yyyy, dt) AS Years, AVG(CONVERT(FLOAT, LandAverageTemperature)) AS AvgTemp
FROM GlobalTemperatures
WHERE DATEPART(yyyy, dt) >= 1900
GROUP BY DATEPART(yyyy, dt) 
ORDER BY DATEPART(yyyy, dt) DESC

-- Join Global Temperatures and Temperatures by Country to Compare Trends Since 1900
SELECT 
	DATEPART(yyyy, GlobalTemperatures.dt) AS Years, 
	GlobalLandTemperaturesByCountry.Country,
	AVG(CONVERT(FLOAT, GlobalLandTemperaturesByCountry.AverageTemperature)) AS AvgTemp,
	AVG(CONVERT(FLOAT, GlobalTemperatures.LandAverageTemperature)) AS AvgTempGlobal
FROM GlobalLandTemperaturesByCountry
FULL OUTER JOIN GlobalTemperatures
	ON GlobalLandTemperaturesByCountry.dt = GlobalTemperatures.dt
WHERE Country IN ('United States', 'United Kingdom', 'China', 'Russia', 'India', 'Brazil', 'Australia')
AND DATEPART(yyyy, GlobalTemperatures.dt) >= 1900
GROUP BY DATEPART(yyyy, GlobalTemperatures.dt), GlobalLandTemperaturesByCountry.Country
ORDER BY GlobalLandTemperaturesByCountry.Country, DATEPART(yyyy, GlobalTemperatures.dt) DESC

-- View Major Cities' Temperature Trends Since 1900 
SELECT 
	DATEPART(yyyy, dt) AS Years,
	City, 
	AVG(CONVERT(FLOAT, AverageTemperature)) AS AvgTemp
FROM GlobalLandTemperaturesByMajorCity
WHERE City IN ('New York', 'London', 'Shanghai', 'Moscow', 'Mumbai', 'Sao Paulo', 'Sydney')
AND DATEPART(yyyy, dt) >= 1900
GROUP BY City, DATEPART(yyyy, dt)
ORDER BY City, DATEPART(yyyy, dt) DESC

-- Join Temperatures by Country with Temperatures by Major City to Compare Trends Since 1900
SELECT 
	DATEPART(yyyy, GlobalLandTemperaturesByMajorCity.dt) AS Years, 
	GlobalLandTemperaturesByMajorCity.Country,
	GlobalLandTemperaturesByMajorCity.City,
	AVG(CONVERT(FLOAT, GlobalLandTemperaturesByCountry.AverageTemperature)) AS AvgTempCountry,
	AVG(CONVERT(FLOAT, GlobalLandTemperaturesByMajorCity.AverageTemperature)) AS AvgTempCity
FROM GlobalLandTemperaturesByMajorCity
FULL OUTER JOIN GlobalLandTemperaturesByCountry
	ON GlobalLandTemperaturesByMajorCity.dt = GlobalLandTemperaturesByCountry.dt
	AND GlobalLandTemperaturesByMajorCity.Country = GlobalLandTemperaturesByCountry.Country
WHERE GlobalLandTemperaturesByMajorCity.City IN ('New York', 'London', 'Shanghai', 'Moscow', 'Mumbai', 'Sao Paulo', 'Sydney')
AND DATEPART(yyyy, GlobalLandTemperaturesByMajorCity.dt) >= 1900
GROUP BY 
	DATEPART(yyyy, GlobalLandTemperaturesByMajorCity.dt), 
	GlobalLandTemperaturesByMajorCity.City,
	GlobalLandTemperaturesByMajorCity.Country
ORDER BY GlobalLandTemperaturesByMajorCity.City, DATEPART(yyyy, GlobalLandTemperaturesByMajorCity.dt) DESC

-- Find Change in Temperature for Major Countries from 1900 to 2013
SELECT 
	DATEPART(yyyy, dt) AS Years, 
	Country, 
	AVG(CONVERT(FLOAT, AverageTemperature)) AS AvgTemp,
	AVG(CONVERT(FLOAT, AverageTemperature)) -LAG(AVG(CONVERT(FLOAT, AverageTemperature)), 1) OVER(PARTITION BY Country ORDER BY DATEPART(yyyy, dt)) AS TempChange
FROM GlobalLandTemperaturesByCountry 
WHERE Country IN ('United States', 'United Kingdom', 'China', 'Russia', 'India', 'Brazil', 'Australia')
AND DATEPART(yyyy, dt) IN ('2013', '1900') 
GROUP BY DATEPART(yyyy, dt), Country
ORDER BY Country, DATEPART(yyyy, dt) DESC

