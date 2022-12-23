# Global_temperatures
## SQL Analysis of Global Temperature Data

For this study, I wanted to take a look at Global Temperature trends to see how major countries and major cities would compare to each other. I was particularly looking to find any possible trends since 1900 and to see if there were any regional differences. 

For this study I used initial data found from Berkley Earth via [kaggle](https://www.kaggle.com/datasets/berkeleyearth/climate-change-earth-surface-temperature-data) under this [licence](https://creativecommons.org/licenses/by-nc-sa/4.0/). The original data set can also be found [here](https://berkeleyearth.org/data/).

The description provided from the kaggle dataset provides a further explanation of what is included:

"Global Land and Ocean-and-Land Temperatures (GlobalTemperatures.csv):

    Date: starts in 1750 for average land temperature and 1850 for max and min land temperatures and global ocean and land temperatures
    LandAverageTemperature: global average land temperature in celsius
    LandAverageTemperatureUncertainty: the 95% confidence interval around the average
    LandMaxTemperature: global average maximum land temperature in celsius
    LandMaxTemperatureUncertainty: the 95% confidence interval around the maximum land temperature
    LandMinTemperature: global average minimum land temperature in celsius
    LandMinTemperatureUncertainty: the 95% confidence interval around the minimum land temperature
    LandAndOceanAverageTemperature: global average land and ocean temperature in celsius
    LandAndOceanAverageTemperatureUncertainty: the 95% confidence interval around the global average land and ocean temperature

Other files include:

    Global Average Land Temperature by Country (GlobalLandTemperaturesByCountry.csv)
    Global Average Land Temperature by State (GlobalLandTemperaturesByState.csv)
    Global Land Temperatures By Major City (GlobalLandTemperaturesByMajorCity.csv)
    Global Land Temperatures By City (GlobalLandTemperaturesByCity.csv)

The raw data comes from the Berkeley Earth data page."

## What I looked at

For my analysis, I focused on data starting in the year 1900 up until the most recent data in the dataset. I focused on 7 major countries as well as their most populous cities. 

#### Countries: 

* United States
* United Kingdom
* China
* Russia
* India
* Brazil
* Australia

#### Cities:

* New York
* London
* Shanghai
* Moscow
* Mumbai
* Sao Paulo
* Sydney

## Data cleaning

There was some data cleaning necessary as the 'dt' column was formatted as a DATETIME and I was primarily interested in the year. Additionally, the numeric values for the various temperature fields were formatted as a VARCHAR rather than a FLOAT. I also wanted the results to be sorted by the Country/City and have the dates sorted in descending order to identify any trends over time. 

```sql
SELECT DATEPART(yyyy, dt) AS Years, AVG(CONVERT(FLOAT, AverageTemperature)) AS AvgTemp, City
FROM GlobalLandTemperaturesByMajorCity
WHERE City IN ('New York', 'London', 'Shanghai', 'Moscow', 'Mumbai', 'Sao Paulo', 'Sydney')
AND DATEPART(yyyy, dt) >= 1900
GROUP BY City, DATEPART(yyyy, dt)
ORDER BY City, DATEPART(yyyy, dt) DESC;
```

## Analysis

In addition to locating trends, I also wanted to see how these trends by Country would compare to the average Global temperature trends. For this I used an OUTER JOIN to combine the "GlobalTemperatures" table and the "GlobalLandTemperaturesByCountry" table.

```sql
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
```

Additionally, I wanted to see how City trends would compare to Country trends to see if there was a difference in Cities. My hypothesis was that the Cities would see a more significant temperature increase than the entire Countries' temperature increase. For this, I also used an OUTER JOIN. 

```sql
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
```
Finally, I wanted to see how temperatures from the major countries I selected had changed from 1900 to 2013

```sql
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
```

This output contained the values that were needed but also included a "NULL" value for each Country's "1900" field. These NULL values were removed in Excel prior to importing to Tableau.

## Visualization

To highlight the trends I found, I used Tableau to create a dashboard in order to showcase these trends and relationships. These results can be found [here](https://public.tableau.com/app/profile/mathyas.papp/viz/GlobalTemperatures_16718274802340/Dashboard1)


![Dashboard 1](https://user-images.githubusercontent.com/119142489/209411565-0fc237a2-2b59-4db8-8793-0264ba048ab5.png)



## Conclusion
My findings revealed that there was a clear increase in Global Temperatures. When looking at the average of the 7 Countries and 7 cities I selected, there was also a clear increase, though more gradual. It was interesting to see, however, that some countries have seen a significant drop in temperature from 1900 to 2013 (UK, India, Australia, Brazil). The cause of this decrease could simply be a fluctuation in temperature for the year of 2013. More time will need to pass to see if this decrease is a trend or an outlier. 
