library("tidyverse")
library("sf")
library("rmapshaper")
library("janitor")

## ==== Brexit Referendum Data ====
## Unfortunately, there's not a simple data file that contains the constituency
## level results for England, Northern Ireland, Scotland and Wales.
## This script combines multiple datasets into:
## - data/uk_constituencies_2016 which contains shapefiles for all constituencies
## - data/brexit-referendum-results.csv containing results for all constituencies
## All datasets are from the following Government sources:
## - geoportal.statistics.gov.uka
## - data.london.gov.uk
## - opendatani.gov.uk

## ==== Get shapefiles ====

# Webpage for download
# https://geoportal.statistics.gov.uk/datasets/westminster-parliamentary-constituencies-december-2016-full-clipped-boundaries-in-the-uk
download.file(url = "https://opendata.arcgis.com/datasets/48d0b49ff7ec4ad0a4f7f8188f6143e8_0.zip?outSR=%7B%22latestWkid%22%3A27700%2C%22wkid%22%3A27700%7D",
              destfile = "data/original_ni_constituencies_2016.zip")

unzip(zipfile = "data/original_ni_constituencies_2016.zip",
      exdir = "data/original_ni_constituencies_2016")

original_ni_constituencies_2016 <-  read_sf("data/original_ni_constituencies_2016")

ni_constituencies_2016 <- original_ni_constituencies_2016 %>% 
  filter(str_starts(pcon16cd, "N")) %>% 
  select(pcon16cd, pcon16nm) %>% 
  rename(area_code = pcon16cd,
         area_name = pcon16nm)

# Webpage for download
# https://geoportal.statistics.gov.uk/datasets/local-authority-districts-december-2016-full-clipped-boundaries-in-the-uk
download.file(url = "https://opendata.arcgis.com/datasets/7ff28788e1e640de8150fb8f35703f6e_0.zip?outSR=%7B%22latestWkid%22%3A27700%2C%22wkid%22%3A27700%7D",
              destfile = "data/original_esw_constituencies_2016.zip")

unzip(zipfile = "data/original_esw_constituencies_2016.zip",
      exdir = "data/original_esw_constituencies_2016")

original_esw_constituencies_2016 <-  read_sf("data/original_esw_constituencies_2016")

esw_constituencies_2016 <- original_esw_constituencies_2016 %>%
  filter(str_starts(lad16cd, "E|S|W")) %>% 
  select(lad16cd, lad16nm) %>% 
  rename(area_code = lad16cd,
         area_name = lad16nm)

# Manual fix
# Na h-Eileanan Siar is contracted to Eilean Siar for later compatibility
esw_constituencies_2016 <- esw_constituencies_2016 %>% 
  mutate(area_name = case_when(area_name == "Na h-Eileanan Siar" ~ "Eilean Siar",
                               TRUE ~ area_name))


uk_constituencies_2016 <- ni_constituencies_2016 %>% 
  bind_rows(esw_constituencies_2016) %>% 
  ms_simplify(0.01)

dir.create("data/uk_constituencies_2016")

uk_constituencies_2016 %>% 
  write_sf("data/uk_constituencies_2016/uk_constituencies_2016.shp")

unlink(c("data/original_esw_constituencies_2016.zip",
         "data/original_esw_constituencies_2016",
         "data/original_ni_constituencies_2016.zip",
         "data/original_ni_constituencies_2016"),
       recursive = TRUE)


## ==== Get results for England, Scotland and Wales =====
## Webpage for data
## https://data.london.gov.uk/dataset/eu-referendum-results?q=EU%20referend
esw_referendum_votes <-
  read_csv(
    "https://data.london.gov.uk/download/eu-referendum-results/52dccf67-a2ab-4f43-a6ba-894aaeef169e/EU-referendum-result-data.csv"
  ) %>%
  clean_names()  %>%
  select(area_code, area, votes_cast, remain, leave) %>%
  rename(area_name = area)

## ==== Get results for Nothern Ireland =====
## Webpage for data
## https://www.opendatani.gov.uk/dataset/eu-referendum-23-june-2016/resource/61cfee40-69f6-444e-bf03-3dd60bd6e1dc
ni_referendum_votes <- read_csv("https://www.opendatani.gov.uk/dataset/9a2f7593-297e-409d-bdac-39ccc172a14e/resource/61cfee40-69f6-444e-bf03-3dd60bd6e1dc/download/eu-referendum-2016-constituency-count-totals.csv") %>% 
  clean_names()

ni_referendum_votes <- ni_referendum_votes %>%
  filter(!constituency == "TOTAL") %>%
  rename(
    area_name = constituency,
    votes_cast = number_of_ballot_papers_counted,
    remain = number_of_votes_cast_in_favour_of_remain,
    leave = number_of_votes_cast_in_favour_of_leave
  ) %>%
  select(area_name, votes_cast, remain, leave) %>% 
  mutate(area_name = str_replace(area_name, "&", "and"))

ni_area_codes <- uk_constituencies_2016 %>% 
  st_drop_geometry() %>% 
  filter(str_starts(area_code, "N"))

ni_referendum_votes <- ni_area_codes %>% 
  left_join(ni_referendum_votes)

## ==== Combine results for all constituencies 

brexit_results <- esw_referendum_votes %>% 
  bind_rows(ni_referendum_votes) %>% 
  mutate(result = if_else(remain > leave, "Remain", "Leave")) %>% 
  write_csv("data/brexit-referendum-results.csv")