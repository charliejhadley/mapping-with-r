library("tidyverse")
library("sf")
# remotes::install_github("hrbrmstr/albersusa")
library("albersusa")
library("politicaldata")

data(pres_results)

usa_sf <- usa_sf()

pres_results <- pres_results %>% 
  filter(year == 2016) %>% 
  mutate(result = ifelse(dem > rep, "Democrats", "Republicans"))

party_colours <- c("Republicans" = "#F80007", "Democrats" = "#117AD4")