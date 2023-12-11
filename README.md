# Finish - STAT-451-Final-Project

I explored the homelessness issue in King County, where Seattle is located. 

I began with an overview of the homelessness problem in the U.S.. I showed the distribution and the trend of homelessness in the U.S. I expected to turn the reader's attention to King County by comparing the homelessness rate in King County with the national level. Then, I explored the demographical pattern of the homeless population in King County, including race, age, and gender. I also investigated the geographical pattern of the homeless population to identify if specific neighborhoods are more affected. Finally, I explored the health and social services available to the homeless population, including their distribution in King County and development in recent years.

# Data Sources
## ~~County_2017den.csv - PIT Estimates by County~~
~~This dataset disaggregates and imputes matching for Point-In-Time (PIT) estimates at the CoC level to the County level. Dr. Almquist from the University of Washington created this dataset and published it in _Almquist, Z. W., N. E. Helwig, and Y. You (2020). Connecting Continuum of Care Point-in-Time Homeless Counts to United States Census Areal Units. Mathematical Population Studies 27(1), 46–58._. The dataset is available in R at https://github.com/SSDALab/CoCHomeless.~~
The mapping of the homeless population from the CoC regions to the counties is inaccurate, overestimating the homeless population in rural and suburban areas. Analysis and comparison based on this mapping may be biased, so I dropped this dataset and the visualizations based on it.

## 2007-2022-PIT-Counts-by-CoC.xlsx - PIT Estimates by State and by CoC
This dataset contains PIT estimates of homelessness by state and by CoC from 2007 - 2022. HUD provides these datasets for use by CoC grantees, homeless services planners, and research institutions. It is available at https://www.hudexchange.info/resource/3031/pit-and-hic-data-since-2007/.

## NST-EST2022-POP.csv - County and State Population Data in 2022
This dataset contains the county population totals and the components of change for the years 2020 to 2022. U.S. Census Bureau provides and maintains this dataset. It is available at https://www.census.gov/data/tables/time-series/demo/popest/2020s-counties-total.html.

## CoC_GIS_National_Boundary.gdb - Boundaries of CoC Regions in 2022
This dataset contains the geographic boundaries of all the CoC regions in 2022. HUD provides these datasets for use by CoC grantees, homeless services planners, and research institutions. It is available in the form of shapefile at https://www.hudexchange.info/programs/coc/gis-tools/.

## cb_2022_us_county_5m - Boundaries of Counties in 2022
This dataset contains the geographic boundaries of all the counties in 2022. U.S. Census Bureau provides and maintains this dataset. It is available in the form of shapefile and .kml at https://www.census.gov/geographies/mapping-files/time-series/geo/cartographic-boundary.html.

## cb_2022_us_state_5m - Boundaries of States in 2022
This dataset contains the geographic boundaries of all the states in 2022. U.S. Census Bureau provides and maintains this dataset. It is available in the form of shapefile and .kml at https://www.census.gov/geographies/mapping-files/time-series/geo/cartographic-boundary.html.

## ACSDP1Y2022.DP05-2023-12-11T034310.csv - Demographical Data of King County in 2022
This dataset contains the size of different gender, race, and age groups in King County in 2022. U.S. Census Bureau provides and maintains this dataset. It is available in the form of .csv and .xlsx ar https://data.census.gov/table/ACSDP1Y2022.DP05?g=050XX00US53033.

# Data Process
## create_state_data.R
This RScript maps homeless data from the CoC level to the state level, combining the homeless data and the population data to calculate the homeless rate. It generates the data "state_total_data.csv" used by the first tab, "Homelessness in the U.S.".

## create_coc_data.R
This RScript maps population data from the county level to the CoC level, combining the homeless data and the population data to calculate the homeless rate. It generates the data "coc_total_data.csv" used by the first tab, "Homelessness in the U.S.".

## create_demo_data.R
This RScript extracts the data about Seattle/King County and combines it with the demographical data of King County. It generates the data "demo_total_data.csv" used by the second tab, "Homelessness in the U.S.".

# Analysis
## ~~Geographical Distribution of the Rate of Homelessness by Counties~~

## Geographical Distribution of the Rate of Homelessness by States
This graph shows the rate of homelessness per 10,000 population in 2022 for every state in the U.S. using a map with colors. It allows a large-scale exploration of the geographical distribution of the rate of homelessness in the U.S. We can see that the homelessness issue is more severe in the West Coast and the Northeastern states. The homelessness rates in the central and southern states are relatively low, but there are also individual states where homelessness is a problem to some extent.

## Geographical Distribution of the Rate of Homelessness by CoC Regions
This graph shows the rate of homelessness per 10,000 population in 2022 for every CoC region in the U.S. using a map with colors. It allows a relatively low-scale exploration of the geographical distribution of the rate of homelessness in the U.S. We see the same large-scale pattern of the distribution of homelessness rate in the previous plot. Within each state, the distribution of homelessness rates is uneven and primarily concentrated in large cities and suburban areas. This is more evident in states with overall lower rates of homelessness, where urban areas have significantly higher rates of homelessness than other areas.

## Top 10 States with the Highest Estimated Homeless Rate in 2022
This graph shows the top 10 states with the highest estimated homeless rate in 2022 using a bar plot, where I highlight Washington state, where Seattle/King County is located. It allows a more accurate comparison of the homeless rate between the states where the homeless problem is severe. We can see that the homelessness rates in these states are much higher than the national average, with the highest being California, exceeding the national average by more than double. Washington State is among them and ranks sixth among all states, having a quite serious homelessness problem.

## Top 20 CoC Regions with the Highest Estimated Homeless Rate in 2022
This graph shows the top 20 CoC regions with the highest estimated homeless rate in 2022 among 387 regions using a bar plot, where I highlight the King County CoC region that covers King County. It allows a more accurate and lower-scale comparison of the homeless rate between the areas. We can see that the problem of homelessness is disproportionately distributed and concentrated in specific areas, as the top twenty regions have homelessness rates several times higher than the national average. Although not as severe as in major metropolises like Los Angeles, New York, and San Francisco, Seattle/King County still has a very serious homelessness problem, ranking 16th among all 387 regions.

## Future work:
Part 1 Overview in the U.S.: Distinguish urban, suburban, and rural areas in the bar plots.
Part 2 Distribution of Homelessness in King County
Part 3 Development of support services in King County
