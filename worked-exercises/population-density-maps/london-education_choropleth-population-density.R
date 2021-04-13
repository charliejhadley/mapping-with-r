library("tidyverse")
library("sf")

age_finished_education <- read_csv("data/age-when-completed-education.csv")

london_sf <- read_sf("data/london_boroughs")

age_finished_education <- age_finished_education %>% 
  group_by(area) %>% 
  mutate(value = 100 * value / sum(value)) %>% 
  ungroup()

london_education_sf <- london_sf %>%
  left_join(age_finished_education,
            by = c("lad11nm" = "area")
  )
