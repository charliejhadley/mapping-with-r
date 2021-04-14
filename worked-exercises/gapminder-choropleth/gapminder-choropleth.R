library("tidyverse")
library("sf")
library("gapminder")
library("rnaturalearthdata")
library("countrycode")

gapminder_2007 <- gapminder %>% 
  filter(year == 2007)

countries_sf <- countries110 %>% 
  st_as_sf()

