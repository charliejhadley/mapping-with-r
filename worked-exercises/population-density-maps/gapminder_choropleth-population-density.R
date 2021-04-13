library("gapminder")
library("rnaturalearthdata")
library("countrycode")

gapminder_2007 <- gapminder %>% 
  filter(year == 2007)

gapminder_2007 <- gapminder %>% 
  filter(year == 2007)

gapminder_2007 <- gapminder_2007 %>% 
  mutate(country_code = countrycode(country, "country.name", "iso3c"))

countries_sf <- countries110 %>% 
  st_as_sf() %>% 
  filter(name != "Antarctica")

gapminder_sf <- countries_sf %>% 
  left_join(gapminder_2007,
            by = c("iso_a3" = "country_code"))

gapminder_sf %>% 
  mutate(area = st_area(geometry)) %>% 
  select(name, area) %>% 
  arrange(area)

gapminder_sf %>%
  select(name) %>% 
  mapview::mapview()


ggplot() +
  geom_sf(data = gapminder_sf,
          aes(fill = lifeExp,
              colour = "No data"),
          size = 0.25
          ) +
  scale_fill_gradientn(colours = rainbow(12),
                       name = "Life expectancy") +
  scale_colour_manual(values = "white") +
  theme_void(base_size = 18) +
  theme(legend.position = "bottom", legend.direction = "horizontal", legend.box = "vertical") +
  guides(fill = guide_colorbar(barwidth = 30),
         colour = guide_legend(title = "",
                               override.aes = list(
                                 fill = "gray50",
                                 colour = "white"))) 


ggplot() +
  geom_sf(data = gapminder_sf,
          aes(fill = lifeExp)) +
  scale_fill_viridis_c(labels = scales::number_format(scale = 1e-9,
                                                      suffix = " Billion")) +
  theme_void() +
  coord_sf(crs = "+proj=robin +lon_0=0 +x_0=0 +y_0=0 +datum=WGS84 +units=m +no_defs")


life_exp_range <- gapminder_sf %>% 
  pull(lifeExp) %>% 
  sort() %>% 
  .[c(1, length(.))]

south_america_exc_guiana <- gapminder_sf %>% 
  select(name, contains("continent"), lifeExp) %>% 
  filter(continent.x == "South America")

bbox_south_america <- south_america_exc_guiana %>% 
  st_bbox() %>% 
  as.list()

south_america_exc_guiana %>% 
  bind_rows(gapminder_sf %>% filter(name == "France")) %>% 
  ggplot() +
  geom_sf(aes(fill = lifeExp,
              colour = "No data"),
          size = 0.25
  ) +
  scale_fill_gradientn(colours = rainbow(12),
                       name = "Life expectancy",
                       limits = life_exp_range) +
  scale_colour_manual(values = "white") +
  theme_void(base_size = 18) +
  theme(legend.position = "bottom", legend.direction = "horizontal", legend.box = "vertical") +
  guides(fill = guide_none(),
         colour = guide_none())  +
  coord_sf(xlim = c(bbox_south_america$xmin, bbox_south_america$xmax),
           ylim = c(bbox_south_america$ymin, bbox_south_america$ymax))


gapminder_sf %>% 
  select(name, contains("continent"), lifeExp) %>% 
  filter(continent.x == "Africa") %>% 
  ggplot() +
  geom_sf(aes(fill = lifeExp,
              colour = "No data"),
          size = 0.25
  ) +
  scale_fill_gradientn(colours = rainbow(12),
                       name = "Life expectancy",
                       limits = life_exp_range) +
  scale_colour_manual(values = "white") +
  theme_void(base_size = 18) +
  theme(legend.position = "bottom", legend.direction = "horizontal", legend.box = "vertical") +
  guides(fill = guide_none(),
         colour = guide_none())

library(ggplot2)
library(viridis)
n = 200
image(
  1:n, 1, as.matrix(1:n),
  col = viridis(n, option = "D"),
  xlab = "viridis n", ylab = "", xaxt = "n", yaxt = "n", bty = "n"
)

