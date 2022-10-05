## -----------------------------------------------------------------------------
## Operational sea lice forecast
## Download most recent lice data
## Tim Szewczyk
## -----------------------------------------------------------------------------

library(tidyverse)
library(lubridate)
library(jsonlite)

out.f <- "liceCounts_newest.csv"

site.url <- "http://aquaculture.scotland.gov.uk/csvexport/ms_site_details.csv"
site.df <- read_csv(url(site.url)) %>%
  rename(site=`Marine Scotland Site ID`) %>%
  select(site, Easting, Northing)

# Gathered using Firefox Developer Edition > Tools > Browser Tools > Web Developer Tools
lice.url <- "https://utility.arcgis.com/usrsvcs/servers/8999c2e86c7246cb93b420e810458293/rest/services/Secure/Sealice/MapServer/1/query?f=json&where=1%3D1&returnGeometry=false&spatialRel=esriSpatialRelIntersects&outFields=*&orderByFields=WEEK_BEGINNING%20DESC&outSR=4326&resultOffset=0&resultRecordCount=10000"

fromJSON(lice.url)$features$attributes %>% 
  mutate(week=ymd(WEEK_BEGINNING)) %>%
  rename(lice_wkAvg=WEEKLY_AVERAGE_AF, site=SITE_NO) %>%
  select(site, lice_wkAvg, week) %>%
  filter(week > (max(week)-15),  # in case of NA, use data from most recent week
         !is.na(lice_wkAvg)) %>%
  arrange(desc(week)) %>%
  group_by(site) %>%
  slice_head(n=1) %>%
  left_join(site.df, by="site") %>%  
  write_csv(out.f)
  
  
