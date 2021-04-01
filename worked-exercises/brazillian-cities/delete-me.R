library("tidyverse")
library("sf")
library("maps")
library("rnaturalearthdata")

brazil_cities <- world.cities %>% 
  as_tibble() %>% 
  filter(country.etc == "Brazil",
         pop > 1e6) %>% 
  st_as_sf(coords = c("long", "lat"), crs = 4326) %>% 
  mutate(capital = as.logical(capital)) %>% 
  arrange(desc(pop))

brazil_sf <- countries50 %>% 
  st_as_sf() %>% 
  filter(name == "Brazil")

brazil_cities %>% 
  arrange(desc(pop)) %>% 
  ggplot() +
  geom_sf(data = brazil_sf) +
  geom_sf(data = brazil_cities,
          aes(fill = capital,
              size = pop),
          pch = 21) +
  scale_size_area(labels = scales::number_format(scale = 1E-6,
                                                 suffix = " Million"), 
                  max_size = 15) +
  scale_fill_manual(labels = list("FALSE" = "City",
                                    "TRUE" = "Capital City"),
                    values = list("purple", "gold")) +
  guides(
    fill = guide_legend(override.aes = list(size = 10), title = NULL),
    size = guide_legend(override.aes = list(fill = "purple"))
  ) +
  theme_void() +
  labs(title = "Cities in Brazil with more than 1 Million residents")

## ==== quakes!

fiji_sf <- countries50 %>% 
  st_as_sf() %>% 
  filter(name == "Australia")
quakes_sf <- quakes %>% 
  st_as_sf(coords = c("long", "lat"), crs = 4326)

ggplot() +
  geom_sf(data = fiji_sf) +
  geom_sf(data = quakes_sf)










