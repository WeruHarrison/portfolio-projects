library(tidyverse)

# Data audit
df <- readRDS("cleaned_unpopular_songs.rds")
glimpse(df)
summary(df)
colSums(is.na(df))
sapply(df, function(x) sum(is.na(x)))
sum(duplicated(df))
sum(duplicated(df$track_id))

# Data cleaning: the 'genre' variable is the cause of the 1700 duplicates shown by the 'tracl_id' variable. So, I subset the original df without the 'genre' variable.
df_nogenre <- df %>%
  select(!genre) %>%
  distinct(track_id, .keep_all = TRUE)

# Understanding the target variable: popularity
range(df_nogenre$popularity)

## frequency distribution
df_nogenre %>%
  count(popularity) %>%
  mutate(
    "%" = n / sum(n) * 100
  )

## visualising the frequency distribution
ggplot(data = df_nogenre) +
  geom_bar(mapping = aes(x=popularity))+
  theme_bw()+
  labs(y=NULL,
       x = "Popularity Score",
       y = "Number of Songs",
       title = "Frequency Distribution of Popularity Scores")

# some notable variables to study:----
# 1. speechiness: Possibly right skewed because median<mean
# 2. acousticness: Possibly right skewed because median<mean
# 3. liveness: Possibly right skewed because median<mean
# 4. tempo: has a minimum tempo of 0 BPM, which is unusual for music
# 5. duration_min: possible outliers as the max duration is over 56m compared to the median of 3.26m.

## Confirming the skewness of speechiness, acouticness, and liveness
hist_acousticness <- hist(df_nogenre$acousticness, 
                          main = "Histogram of Acousticness", 
                          xlab =  "Acousticness")
hist_speechiness <- hist(df_nogenre$speechiness, 
                         main = "Histogram of speechiness", 
                         xlab =  "speechiness")
hist_liveness <- hist(df_nogenre$liveness, 
                      main = "Histogram of liveness", 
                      xlab =  "liveness")













