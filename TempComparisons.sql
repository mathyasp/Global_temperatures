-- View the data
SELECT *
FROM GlobalLandTemperaturesByCountry

-- View Major Countries' Temperature Trends Since 1900
SELECT Country, DATEPART(yyyy, dt), AVG(CONVERT(FLOAT, AverageTemperature)) AS AvgTemp
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
	GlobalLandTemperaturesByCountry.Country,
	DATEPART(yyyy, GlobalTemperatures.dt), 
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
SELECT DATEPART(yyyy, dt) AS Years, AVG(CONVERT(FLOAT, AverageTemperature)) AS AvgTemp, City
FROM GlobalLandTemperaturesByMajorCity
WHERE DATEPART(yyyy, dt) >= 1900
GROUP BY City, DATEPART(yyyy, dt)
ORDER BY City, DATEPART(yyyy, dt) DESC