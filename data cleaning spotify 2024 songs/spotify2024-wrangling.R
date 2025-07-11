library(tidyverse)

spotify <- read.csv("Most Streamed Spotify Songs 2024.csv", encoding="latin1")     # used the base function and the encoding option because of encoding issues in the first three columns

str(spotify)

# from observation of the output of the above,
# 1. The column names are not readable
# 2. Columns "all_time_rank":"shazam_counts" should be numeric
# 3. The column "release_date" should be date format
# 4. "all_time_rank" should be factor level
# 5. "explicit_track" should be logical

# 1. Making the column names readable
colnames(spotify) <-  spotify %>% 
  colnames() %>%
  str_replace_all(., "\\.", "_") %>%
  str_to_lower()

# 2. Making columns "all_time_rank":"shazam_counts" numeric
spotify <- spotify %>%
  mutate(across(c(all_time_rank, spotify_streams:spotify_playlist_reach,
                  youtube_views:youtube_playlist_reach,
                   airplay_spins:siriusxm_spins,
                  deezer_playlist_reach,
                  pandora_streams:shazam_counts), parse_number))

# 3. Correct "release_date" formatting
spotify <- replace(spotify, 4, as.Date(spotify$release_date, format = "%m/%d/%Y"))

# 4. Making "all_time_rank" ordered level
spotify <- spotify %>% 
  mutate(all_time_rank_factor = factor(all_time_rank, ordered = TRUE)) %>%     # with this conversion, the last song is ordered to be larger than the first. SO it should be reversed.
  mutate(all_time_rank_factor = fct_rev(all_time_rank_factor))

# 5. Making "explicit_track" logical
spotify <- spotify %>%
  mutate(explicit_track_logical = case_when(
    explicit_track == 0 ~ "False",
    explicit_track == 1 ~ "True"
  )) %>%     # recoding the variable first
  mutate(explicit_track_logical = as.logical(explicit_track_logical))

# Checking for missing values
dim(spotify)
NAs <- colSums(is.na(spotify)) %>% 
  sort(decreasing = TRUE) # Listing the number of NAs for each column

# From my observation:
# 1. the "tidal_popularity" column has no values. So it should be dropped.
# 2. Replacing NAs in the numeric columns above with 0s to mean that these tracks did not receive any streams. (Rationale for using 0 instead of mean or computing)
# 3. Check and remove duplicated rows

# 1. Dropping the "tidal_popularity" column
spotify <- select(spotify, -tidal_popularity)

# 2. Replacing NAs in numeric columns with 0s. (Rationale for using 0 instead of mean or computing)
spotify <- spotify %>% 
  mutate_if(is.numeric, ~replace(., is.na(.), 0)) %>%     # a column is mutated by replacing NA with 0 if its numeric
  mutate_if(is.integer, ~replace(., is.na(.), 0))     # a column is mutated by replacing NA with 0 if its integer

# 3. check for duplicates and remove them
duplicates <- spotify %>%
  group_by_all() %>%  # Group by all columns to identify identical rows
  summarise(frequency = n()) %>%  # Count occurrences of each unique row
  ungroup() %>% 
  filter(frequency > 1)     # filter rows with more than 1 frequency

# Two observations were duplicated. Removing them using the following:
spotify <- spotify %>% 
  distinct(.keep_all = TRUE)

# The data is now ready for further exploration

