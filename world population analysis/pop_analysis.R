# Packages ----
library(tidyverse)
library(rworldmap)

# Load data ----
world_pop <- read_csv('datalab_export_2024-08-17 12_57_46.csv')
country_data <- read_csv('datalab_export_2024-08-17 12_59_55.csv')

# Joining the datasets ----
total_pop <- full_join(world_pop, country_data, by="Country Code")

total_pop <- total_pop %>%
  select(`Country Code`, TableName, Region:SpecialNotes, 
         everything()) %>%
  rename(CountryCode = `Country Code`)


# Data cleaning ----
# Cleaning categorical variable IncomeGroup
count(total_pop, IncomeGroup)

total_pop <- mutate(total_pop,
                    IncomeGroup.rec = ifelse(IncomeGroup=="null", NA, IncomeGroup),
                    IncomeGroup.fct = factor(IncomeGroup.rec,
                                             labels = c("High income",
                                                        "Low income",
                                                        "Lower middle income",
                                                        "Upper middle income")))
count(total_pop, IncomeGroup, IncomeGroup.fct)

# Cleaning regions and creating regions subset
regions <- c(unique(total_pop$Region))

region_pop <- total_pop %>%
  filter(TableName %in% regions & !is.na(TableName)) %>%
  select(-Region, -IncomeGroup, -`Indicator Name`, -`Indicator Code`) %>%
  arrange(desc(`2020`)) 
region_pop2 <- total_pop %>% 
  subset(TableName %in% regions & !is.na(TableName))%>%
  select(-Region, -IncomeGroup, -`Indicator Name`, -`Indicator Code`) %>%
  arrange(desc(`2020`)) 

# Q1: How did the world population change over time? ----
world_aggregate <- total_pop %>% 
  filter(CountryCode == "WLD") %>%
  select(-(TableName:`Indicator Code`)) %>%
  reshape(
    idvar = "CountryCode",
    varying = 2:64,
    sep = "",
    timevar = "year",
    times = c(1960:2020),
    new.row.names = 1:10000,
    direction = "long"
  )
colnames(world_aggregate)[3] <- "Population"

world_aggregate_viz <- ggplot(data = world_aggregate, mapping = aes(x = as.numeric(year), y = as.numeric(Population), group = 1)) +
  geom_line(color="tomato") +
  geom_point(color="red")+
  scale_y_continuous(labels = function(x) format(x, 1e6, big.mark=",",scientific = FALSE))+
  labs(title = "World Population 1960-2020", x = "Year", y = "Total Population")+
  theme_bw()+
  theme(plot.title = element_text(hjust=0.5))
world_aggregate_viz


# Q2: Which regions have large (small) populations? ----
region_pop_viz <- ggplot(data = region_pop, mapping = aes(y = forcats::fct_reorder(TableName, (`2020`)), x = `2020`)) +
  geom_col(aes(fill= TableName), show.legend = FALSE)+
  scale_x_continuous(labels = function(x) format(x, 1e6, big.mark=",",scientific = FALSE))+
  labs(title = "Most and Least Populous Regions in 2020", x = "", y = "Population")+
  theme_bw()+
  theme(plot.title = element_text(hjust = 0.5))
region_pop_viz


# Q3: Which regions experienced the highest population change (increase or decrease) in the past 10 years? ----
region_pop_long <- region_pop %>% 
  select("CountryCode",
         "TableName",
         55:64) %>%
  reshape(
    idvar = "CountryCode",
    varying = 3:12,
    sep = "",
    timevar = "year",
    times = c(2011:2020),
    new.row.names = 1:10000,
    direction = "long"
  )
colnames(region_pop_long) <- c("CountryCode", "Region", "Year", "Population")

region_pop_change_viz <- ggplot(data = region_pop_long, mapping = aes(x = as.numeric(Year), y = as.numeric(Population), group = Region)) +
  geom_line(aes(color = Region)) +
  geom_point(aes(colour = Region)) + 
  scale_x_continuous(limits = c(2011, 2020), breaks = c(2011, 2013, 2015, 2017, 2019))+
  scale_y_continuous(labels = scales::label_comma()) +
  labs(title = "Population Change in Regions (2011-2020)",
       x = "",
       y = "Population") +
  theme_light()+
  theme(plot.title = element_text(hjust = 0.5))
region_pop_change_viz


# Q4: Population change in the past 10 years ----
# Q4a: Most and least populous countries 
country_pop <- total_pop %>%
  select("CountryCode",
         "TableName",
         "Region",
         59:68) %>%
  filter(!(Region == "null" | is.na(Region)))

most_populous_viz <- country_pop %>% 
  slice_max(order_by = `2020`, n = 10) %>%
  ggplot(mapping = aes(x = `2020`, y = forcats::fct_reorder(TableName, `2020`))) +
  geom_col(aes(fill = CountryCode), show.legend = FALSE)+
  scale_x_continuous(labels = scales::label_comma()) +
  labs(title = "Most Populous Countries in the World, 2020",
       x = "Population",
       y = "") +
  theme_minimal()+
  theme(plot.title = element_text(hjust = 0.5))
most_populous_viz


least_populous_viz <- country_pop %>% 
  slice_min(order_by = `2020`, n = 10) %>%
  ggplot(mapping = aes(x = `2020`, y = forcats::fct_reorder(TableName, `2020`))) +
  geom_col(aes(fill = CountryCode), show.legend = FALSE)+
  scale_x_continuous(labels = scales::label_comma()) +
  labs(title = "Least Populous Countries in the World, 2020",
       x = "Population",
       y = "") +
  theme_minimal()+
  theme(plot.title = element_text(hjust = 0.5))
least_populous_viz

# Q4b: Countries with the highest population change
rate_pop_change <- country_pop %>% 
  mutate("Change" = `2020`-`2011`,
         "Change, %" = round(((`2020`-`2011`)/`2011`)*100, 2)) %>%
  select(CountryCode, TableName, Change, `Change, %`) %>%
  arrange(desc(`Change, %`))
print(rate_pop_change)

# countries with the highest increase
increase_pop <- slice_max(rate_pop_change, order_by = `Change, %`, n = 10)

# countries with the highest decrease
decrease_pop <- slice_min(rate_pop_change, order_by = `Change, %`, n = 10)

rate_pop_change_viz <- bind_rows(increase_pop, decrease_pop) %>%
  ggplot(mapping = aes(x = `Change, %`, y = forcats::fct_reorder(TableName, `Change, %`))) +
  geom_col(aes(fill = CountryCode), show.legend = FALSE) +
  geom_text(data = decrease_pop, aes(label = `Change, %`), nudge_x = 2.5, size = 3) +
  geom_text(data = increase_pop, aes(label = `Change, %`), nudge_x = -2.25, size = 3) +
  scale_x_continuous(labels = scales::label_comma()) +
  labs(title = "Countries With The Highest Population Decrease, 2011-2020",
       x = "Population Change (%)",
       y = "") +
  theme_minimal()+
  theme(plot.title = element_text(hjust = 0.5))
rate_pop_change_viz


# Q5: Population change of all countries in the last 10 years ----
world <- map_data("world") %>% 
  filter(! long > 180) 
world <- world %>%
  mutate(region = case_when(
    trimws(subregion) == "British" ~ "British Virgin Islands",
    trimws(subregion) == "US" ~ "US Virgin Islands",
    trimws(subregion) == "Hong Kong" ~ "Hong Kong",
    trimws(subregion) == "Macao" ~ "Macao",
    TRUE ~ as.character(region)
  ))

pop_change$TableName <- recode(pop_change$TableName, 
                     `"Bahamas, The"` = "Bahamas",
                     `"Congo, Dem. Rep."` = "Democratic Republic of the Congo",
                     `"Congo, Rep."` = "Republic of Congo",
                     `"Egypt, Arab Rep."` = "Egypt",
                     `"Gambia, The"` = "Gambia",
                     `"Hong Kong SAR, China"` = "Hong Kong",
                     `"Iran, Islamic Rep."` = "Iran",
                     `"Korea, Dem. People's Rep."` = "North Korea",
                     `"Korea, Rep."` = "South Korea",
                     `"Macao SAR, China"` = "Macao",
                     `"Micronesia, Fed. Sts."` = "Micronesia",
                     `"Venezuela, RB"` = "Venezuela",
                     `"Yemen, Rep."` = "Yemen",
                     `Antigua and Barbuda` = "Antigua",
                     "Virgin Islands (U.S.)" = "US Virgin Islands",
                     "Brunei Darussalam" = "Brunei",
                     "Cabo Verde" = "Cape Verde",
                     "Côte d'Ivoire" = "Ivory Coast",
                     "Curaçao" = "Curacao",
                     "Eswatini" = "Swaziland",
                     "Kyrgyz Republic" = "Kyrgyzstan",
                     "Lao PDR" = "Laos",
                     "Russian Federation" = "Russia",
                     "São Tomé and Principe" = "Sao Tome and Principe",
                     "Sint Maarten (Dutch part)" = "Sint Maarten",
                     "Slovak Republic" = "Slovakia",
                     "St. Kitts and Nevis" = "Saint Kitts",
                     "St. Lucia" = "Saint Lucia",
                     "St. Martin (French part)" = "Saint Martin",
                     "St. Vincent and the Grenadines" = "Saint Martin",
                     "Syrian Arab Republic" = "Syria",
                     "Trinidad and Tobago" = "Trinidad",
                     "United Kingdom" = "UK",
                     "United States" = "US"
                     )
as.data.frame(world)
world_pop_change <- merge(world, 
                          pop_change, 
                          by.x = "region", 
                          by.y = "TableName", 
                          all = TRUE)  %>%
  arrange(group, order)

world_pop_change_viz <- ggplot() +
  geom_polygon(data = world_pop_change, 
               aes(x = long, y = lat, group = group,
               fill = `Change, %`)) +
  coord_quickmap() +
  theme_void() +
  labs(title = "Population Change of All Countries (2011-2020)") +
  scale_fill_continuous(name="Population\ngrowth rate", type = "viridis") +
  theme(legend.position="bottom", plot.title = element_text(hjust = 0.5))
world_pop_change_viz

