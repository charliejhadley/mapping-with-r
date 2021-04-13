library("tidyverse")
library("sf")

age_finished_education <- read_csv("data/age-when-completed-education.csv")

london_sf <- read_sf("data/london_boroughs")

age_finished_education <- age_finished_education %>% 
  group_by(area) %>% 
  mutate(value = 100 * value / sum(value))

london_education_sf <- london_sf %>%
  left_join(age_finished_education,
            by = c("lad11nm" = "area")
  )

left_edu_at_16 <- london_education_sf %>% 
  filter(age_group == "16 or under")

ggplot() +
  geom_sf(data = left_edu_at_16,
          aes(fill = value,
              colour = "No data"),
          size = 0.25) +
  scale_fill_viridis_c(name = "",
                       labels = scales::percent_format(scale = 1)) +
  scale_colour_manual(values = "white") +
  guides(colour = guide_legend(title = "",
                               override.aes = list(
                                 fill = "gray50",
                                 colour = "white")),
         fill = guide_colorbar(barheight = 10)) +
  theme_void(base_size = 16)+
  labs(title = "Londoners who left formal education at 16 or under")


ggplot() +
  geom_sf(data = london_education_sf,
          aes(fill = value,
              colour = "No data"),
          size = 0.25) +
  scale_fill_viridis_c(name = "",
                       labels = scales::percent_format(scale = 1)) +
  scale_colour_manual(values = "white") +
  facet_wrap(~ age_group) +
  guides(colour = guide_legend(title = "",
                               override.aes = list(
                                 fill = "gray50",
                                 colour = "white")),
         fill = guide_colorbar(barheight = 10)) +
  theme_void(base_size = 16) +
  theme(strip.background = element_rect(fill = "grey85")) +
  labs(title = "When do Londoners leave formal education?")



thm_default <- theme_gray()

thm_default$strip.background
