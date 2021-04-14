library("tidyverse")
library("sf")
library("mapview")

age_finished_education <- read_csv("data/age-when-completed-education.csv")

london_sf <- read_sf("data/london_boroughs")

age_finished_education <- age_finished_education %>% 
  group_by(area) %>% 
  mutate(value = 100 * value / sum(value))

london_education_sf <- london_sf %>%
  left_join(age_finished_education,
            by = c("lad11nm" = "area")
  )


london_edu_16_or_under <- london_education_sf %>% 
  filter(age_group == "16 or under")

ggplot() +
  geom_sf(data = london_education_sf,
          aes(fill = value,
              colour = "No Data")) +
  scale_fill_viridis_c() +
  scale_colour_manual(values = "white") +
  guides(colour = guide_legend(override.aes = list(fill = "grey50"),
                               title = element_blank(),
                               order = 2
                               ),
         fill = guide_colorbar(order = 1)) +
  facet_wrap(~ age_group)

default_theme <- theme_gray()

viridis_settings <- scale_fill_viridis_b()

viridis_settings$na.value

## ======= DOT DENSITY


london_sf %>% 
  st_transform(crs = 4326) %>% 
  mapview()

ggplot() +
  geom_sf(data = dots_finished_edu,
          aes(colour = age_group,
              shape = "No data"),
          size = 0.001) +
  geom_sf(data = london_sf,
          alpha = 0) +
  scale_colour_brewer(palette = "Set3", name = "One dot = 25 people") +
  # scale_colour_viridis_d() +
  labs(title = "When do Londoners leave formal education?\n(Source: ONS Population Survey, 2018)") +
  guides(colour = guide_legend(override.aes = list(size=5))) +
  theme_void(base_size = 26)

















