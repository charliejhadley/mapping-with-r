library("tidyverse")
library("sf")
library("janitor")
library("leaflet")
library("rmapshaper")

## ==== Get shapefiles ====
download.file(url = "https://opendata.arcgis.com/datasets/ae90afc385c04d869bc8cf8890bd1bcd_1.zip?outSR=%7B%22latestWkid%22%3A27700%2C%22wkid%22%3A27700%7D",
              destfile = "data/uk_local_authorities.zip")

unzip(zipfile = "data/uk_local_authorities.zip",
      exdir = "data/uk_local_authorities")

scotland_sf <- read_sf("data/uk_local_authorities") %>%
  filter(str_starts(lad17cd, "S")) %>%
  st_transform(4326)

scotland_sf <- ms_simplify(scotland_sf, keep = 0.01) # this simplifies the polygons to aid faster drawing

dir.create("data/scotland-shapefiles")

scotland_sf %>%
  write_sf("data/scotland-shapefiles/scotland.shp")

unlink("data/uk_local_authorities.zip")
unlink("data/uk_local_authorities/", recursive = TRUE)

## ==== Get local authority services

download.file(url = "https://statistics.gov.scot/downloads/cube-table?uri=http%3A%2F%2Fstatistics.gov.scot%2Fdata%2Flocal-authority-services-and-performance---shs",
              destfile = "data/local_authority_services.csv")

local_authority_services <- read_csv("data/local_authority_services.csv") %>%
  clean_names() %>%
  select(-units) # The Units is the same in all rows

scottish_service_response <- function(year,
                                      service_name,
                                      age,
                                      gender,
                                      urban_classification,
                                      simd_quintiles){
  
  age <- enquo(age)
  gender <- enquo(gender)
  simd_quintiles <- enquo(simd_quintiles)
  
  local_authority_services %>%
    filter(date_code == year) %>%
    filter(local_authority_services_and_performance == service_name) %>%
    filter(age == !!age) %>%
    filter(gender == !!gender) %>%
    filter(measurement == "Percent") %>%
    filter(urban_rural_classification == urban_classification) %>%
    filter(simd_quintiles == !!simd_quintiles) %>%
    filter(complete.cases(.)) %>%
    select(feature_code, local_authority_services_and_performance, measurement, value)
  
}


all_services <- c("I can influence decisions affecting my local area", "I want greater involvement in decision-making", 
                  "My council addresses key issues", "My council designs services around users' needs", 
                  "My council does its best with the money available", "My council is good at communicating performance", 
                  "My council is good at communicating services", "My council is good at listening", 
                  "My council provides high quality services")

map(all_services,
    ~scottish_service_response(year = 2012,
                              service_name = .x,
                              age = "All",
                              gender = "All",
                              urban_classification = "All",
                              simd_quintiles = "All") ) %>%
  bind_rows() %>%
  rename(question = local_authority_services_and_performance) %>% 
  select(-measurement) %>% 
  filter(question == "I can influence decisions affecting my local area") %>% 
  View()
  
  
  
write_csv("data/local_authority_services_and_performance_qs.csv")

unlink("data/local_authority_services.csv")
