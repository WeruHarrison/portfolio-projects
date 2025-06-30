library(tidyverse)

setwd("~/Projects/data wrangling/spotify-2024")
spotify <- read_csv("Most Streamed Spotify Songs 2024.csv")

dim(spotify)
str(spotify)

# Listing the number of NAs for each column
NAs <- colSums(is.na(spotify)) %>% sort(decreasing = TRUE)


# from my observation, 
# 1. the 'TIDAL Popularity' column has no values. So it should be dropped.
# 2. Replacing NAs in numeric columns with 0s. (Rationale for using 0 instead of mean or computing)
# 3. 'Release Date' should be date format
# 4. 'Explicit Track' should be factor level
# 5. Check and remove duplicated rows


# 1. Dropping the 'TIDAL Popularity' column
spotify <- select(spotify, -`TIDAL Popularity`)

# 2. Replacing NAs in numeric columns with 0s. (Rationale for using 0 instead of mean or computing)
spotify <- spotify %>% 
  mutate_if(is.numeric, ~replace(., is.na(.), 0))     # a column is mutated by replacing NA with 0 if its numeric

# there are 5 rows with missing Artist. I looked for each Track using its name, album and ISRC but I did not find anything relevant. So, I choose to remove the 5 rows. 
spotify <- spotify[!is.na(spotify$Artist), ]     # excluding the 5 rows with NAs in the Artist columns

# 3. Correct 'Release Date' formatting
spotify <- replace(spotify, 4, as.Date(spotify$`Release Date`, format = "%m/%d/%Y"))

# 4. Introducing factor level in 'Explicit Track' column and
# making 'Track Score' and 'All Time Rank' ordered level


# 5. check for duplicates and remove them
dup <- spotify %>%
  group_by_all() %>%  # Group by all columns to identify identical rows
  summarise(frequency = n()) %>%  # Count occurrences of each unique row
  ungroup() %>% 
  filter(frequency > 1)     # filter rows with more than 1 frequency

# Two Tracks were duplicated. Removing them using the following:
spotify <- spotify %>% 
  distinct(.keep_all = TRUE)
view(spotify)
