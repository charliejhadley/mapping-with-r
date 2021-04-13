library("tidyverse")
library("sf")

brexit_results <- read_csv("data/brexit-referendum-results.csv")

uk_sf <- read_sf("data/uk_constituencies_2016")

brexit_sf <- uk_sf %>% 
  left_join(brexit_results)

brexit_colours <- c("Leave" = "#005ea7", "Remain" = "#ffb632")
