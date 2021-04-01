library("tidyverse")
library("sf")
library("maps")
library("rnaturalearthdata")

brazil_cities <- world.cities %>% 
  as_tibble() %>% 
  filter(country.etc == "Brazil",
         pop > 1e6) %>% 
  st_as_sf(coords = c("long", "lat"), crs = 4326) %>% 
  mutate(capital = as.logical(capital))

brazil_sf <- countries50 %>% 
  st_as_sf() %>% 
  filter(name == "Brazil")

brazil_cities %>% 
  arrange(desc(pop)) %>% 
  ggplot() +
  geom_sf(data = brazil_sf) +
  geom_sf(data = brazil_cities,
          aes(colour = capital))
