library("tidyverse")
library("sf")
library("mapview")

scotland_sf <- read_sf("data/uk_local_authorities",
                       layer = "local_authorities_scotland")

wales_sf <- read_sf("data/uk_local_authorities",
                    layer = "local_authorities_wales")

england_sf <- read_sf("data/uk_local_authorities",
                      layer = "local_authorities_england")

uk_sf <- scotland_sf %>%
  bind_rows(wales_sf) %>%
  bind_rows(england_sf)

brexit_votes <- read_csv("data/brexit-referendum-results.csv")

brexit_votes <- brexit_votes %>%
  mutate(result = if_else(remain > leave, "Remain", "Leave"))

uk_sf %>%
  left_join(brexit_votes,
            by = c("lad17cd" = "area_code")) %>%
  mapview(zcol = "remain")


uk_sf %>%
  left_join(brexit_votes,
            by = c("lad17cd" = "area_code")) %>%
  mapview(zcol = "result")






