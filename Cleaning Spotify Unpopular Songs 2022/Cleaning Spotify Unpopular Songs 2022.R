library(tidyverse)

songs <- read_csv("unpopular_songs.csv")
genre <- read_csv("z_genre_of_artists.csv")

# Getting sense of the `songs` dataframe
str(songs)
glimpse(songs)

# 1. The dataframe should start with track_id then track_artist then track_name and the rest can follow
# 2. The duration_ms variable should not be =<0 because it track duration cannot be less than zero
# 3. The duration_ms variable is in milliseconds and can be split into minutes and seconds
# 4. `mode` should be factor level (major or minor)
# 5. `key` should be a factor level
# 6. `popularity` can be an ordered factor level because the lower the number the lower the popularity
# 7. Merge the two dataframes. Common column are `track_artist` and `artist_name`


# 1. Reordering the columns
songs <- songs %>% 
  select(track_id,
         track_artist,
         track_name,     # Selecting the three first to ensure they come at the beginning of the dataframe then everything follows
         everything()
         )

head(songs)


# 2. Checking if `duration_ms` is less than 0
invalid_songs <- songs %>%
  filter(duration_ms == 0 | duration_ms < 0)     # filtering rows where the `duration_ms` column is equal to zero or less than 0

head(invalid_songs)    # No invalid tracks were found


# 3. Splitting `duration_ms` to minutes and seconds
songs$track_length <-  seconds_to_period(songs$duration_ms/1000)     # first, the `duration_ms` variable is divided by 1000 to convert it to seconds then the output is converted to periods
songs <- songs %>% mutate(track_length, duration_min = round(track_length, 2)) # A new column is created where the seconds are rounded to the nearest whole number

head(songs)


# 4. Converting `mode` to a factor level
songs$mode_fct <- factor(songs$mode,
                         levels = c(0, 1),
                         labels = c("Minor", "Major")
                         )

class(songs$mode_fct)     # the new column is of the factor class
levels(songs$mode_fct)


# 5. Converting `key` to a factor level
songs$key_fct <- factor(songs$key,
                        levels = c(0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11),
                        labels = c("C", "C#/Db", "D", "D#/Eb", "E", "F", "F#/Gb", "G", "G#/Ab", "A", "A#/Bb", "B"))     # the character `#` and `b` were used to represent the sharp and flat notations. Using the actual unicode notations is likely to introduce compatibility issues when the final output is exported to other formats. The conversion was guided by this wikipedia page: https://en.wikipedia.org/wiki/Pitch_class

class(songs$key_fct)     # the new column is of the factor class
levels(songs$key_fct)


# validating the conversion
## Here, the dataframe is grouped by the `key` and `key_fct` columns and then they are counted under each group. It shows how many values belong to each group in both case. When the two outputs are combined in the same dataframe, you can compare the number of observation in each group.
unique_key <- songs %>% 
  group_by(key) %>% 
  count()

unique_key_fct <- songs %>% 
  group_by(key_fct) %>% 
  count()

validate_key <- cbind(unique_key, unique_key_fct)

print(validate_key)     # The dataframe shows that the notations were correct and the observation within each group resembled the original column. It is safe to assume the conversion was accurate.


# 6. Converting `popularity` to an ordered factor level
songs$popularity <- factor(songs$popularity, ordered = TRUE)
class(songs$popularity)


# 7. Merge the two dataframes. Common column are `track_artist` and `artist_name`
songs <- songs %>%
  left_join(genre, by = c("track_artist"="artist_name"), relationship = "many-to-many")

str(songs)
unique(songs$genre)
# I noticed that all `genre` observations have square brackets (`[]`), which have to be removed
songs$genre <- str_remove_all(songs$genre, "\\[|\\]")

