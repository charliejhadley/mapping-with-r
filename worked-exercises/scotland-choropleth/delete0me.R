library("tidyverse")
library("sf")

scotland_sf <- read_sf("data/scotland-shapefiles")

services_and_performance_qs <- read_csv("data/local_authority_services_and_performance_qs.csv")

influence_decisions <- services_and_performance_qs %>% 
  filter(question == "I can influence decisions affecting my local area")



scotland_services <- scotland_sf %>% 
  left_join(services_and_performance_qs,
            by = c("lad17cd" = "feature_code"))

scotland_influence_q <- scotland_services %>% 
  filter(question == "I can influence decisions affecting my local area")

scotland_influence_q %>% 
  st_drop_geometry() %>% 
  View()

scotland_services %>% 
  filter(question == "I can influence decisions affecting my local area")

ggplot() +
  geom_sf(data = scotland_sf %>% 
            left_join(influence_decisions,
                      by = c("lad17cd" = "feature_code")),
          aes(fill = value))
  
