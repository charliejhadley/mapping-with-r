library("tidyverse")

scotland_sf <- read_sf("data/local-authority-shapefiles")

services_and_performance_qs <- read_csv("data/local_authority_services_and_performance_qs.csv")

services_and_performance_qs
