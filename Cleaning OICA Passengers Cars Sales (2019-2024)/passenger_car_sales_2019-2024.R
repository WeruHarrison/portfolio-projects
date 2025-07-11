library(tidyverse)
library(readxl)
library(janitor)

# loading the dataset
pc_sales <- read_xlsx("pc_sales_2024.xlsx", skip = 3)

# viewing the dataframe to note initial problems
str(pc_sales)

# Notable issues:
# 1. The column names should be cleaned 
# 2. The dataset is in wide format instead of long format
# 3. The first column contains both regions and countries.

# 1. Renaming the columns and removing NAs
pc_sales <- pc_sales %>% 
  select(1:7) %>%
  rename(
    "country" = "REGIONS/COUNTRIES",
    "2019" = "Q1-Q4 2019",
    "2020" = "Q1-Q4 2020",
    "2021" = "Q1-Q4 2021",
    "2022" = "Q1-Q4 2022",
    "2023" = "Q1-Q4 2023",
    "2024" = "Q1-Q4 2024"
  ) %>%
  remove_empty()

# 2. Converting the dataframe to wide format
pc_sales <- pc_sales %>%
  pivot_longer(cols = 2:7, names_to = "year", values_to = "sales") %>%
  mutate(year = as.numeric(year))

# 3. Creating a separate dataframe for country and regions
regions <- c (
  "EUROPE",
  "EU 27 countries + EFTA + UK",
  "RUSSIA, TURKEY & OTHER EUROPE",
  "OTHER COUNTRIES/REGIONS",
  "AMERICA",
  "USMCA (former NAFTA)",
  "CENTRAL & SOUTH AMERICA",
  "ASIA/OCEANIA/MIDDLE EAST",
  "ASEAN",
  "AFRICA",
  "ALL COUNTRIES/REGIONS",
  "TOTAL OICA MEMBERS",
  "* including LCV& HCV",
  "OTHER COUNTRIES"
)

pc_sales_region <- pc_sales %>%
  filter(country %in% regions & !is.na(sales)) %>%
  rename("regions" = "country")

pc_sales_country <- pc_sales %>%
  filter(!(country %in% regions)) %>% 
  mutate(country = str_to_title(country)) %>%
  arrange(country, year)

# Exporting the cleaned data frames
write.csv(pc_sales_country, file = "clean_passenger_car_sales_by_country_2019-2024.csv")
write.csv(pc_sales_region, file = "clean_passenger_car_sales_by_region_2019-2024.csv")


