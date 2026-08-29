library(tidyverse)

# Data audit ----
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

# Understanding the target variable: popularity ----
range(df_nogenre$popularity)

# frequency distribution
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

# Notable independent variables to study:----
# 1. speechiness: Possibly right skewed because median<mean
# 2. acousticness: Possibly right skewed because median<mean
# 3. liveness: Possibly right skewed because median<mean
# 4. tempo: has a minimum tempo of 0 BPM, which is unusual for music
# 5. duration_min: possible outliers as the max duration is over 56m compared to the median of 3.26m.

# Confirming the skewness of speechiness, acouticness, and liveness
hist_acousticness <- hist(df_nogenre$acousticness, 
                          main = "Histogram of Acousticness", 
                          xlab =  "Acousticness")
hist_speechiness <- hist(df_nogenre$speechiness, 
                         main = "Histogram of speechiness", 
                         xlab =  "speechiness")
hist_liveness <- hist(df_nogenre$liveness, 
                      main = "Histogram of liveness", 
                      xlab =  "liveness")

# Song Tempo ----
df_nogenre %>% 
  filter(tempo == 0) %>%
  count()

# I have decided to remove the songs with tempo of 0 bpm because they are just 13
df_nogenre <- df_nogenre %>% 
  filter(tempo != 0)

summary(df_nogenre$tempo)

# Song Duration----
# I used duration_ms for the analysis of the duration variable since it is numeric data type
ggplot(data = df_nogenre)+
  geom_histogram(mapping = aes(x = duration_ms/60000), 
                 bins = 40)+
  theme_bw()+
  labs(x = "Song Duration (Minutes)",
       y = "Number of Songs",
       title = "Histogram of Song Duration")

ggplot(data = df_nogenre)+
  geom_boxplot(mapping = aes(y = duration_ms/60000))+
  theme_bw()+
  labs(y = "Song Duration (Minutes)",
       title = "Boxplot of Song Duration")
# the visualisations support the summary statistics i.e. there are songs that have unusual lengths
# identifying outliers
q1 <- quantile(df_nogenre$duration_ms, 0.25)
q3 <- quantile(df_nogenre$duration_ms, 0.75)
iqr <- IQR(df_nogenre$duration_ms)
lower_boundary <-  q1 - (1.5 * iqr)
upper_boundary <-  q3 + (1.5 * iqr)

duration_outlier <- df_nogenre %>%
  arrange(desc(duration_ms)) %>%
  filter(duration_ms > upper_boundary | duration_ms < lower_boundary) %>%
  select(track_name,
         track_artist,
         duration_min,
         popularity)
# 176 songs are outside the boundaries proving duration that is outlier
# investigating whether the songs with duration outside the boundaries has significantly different statistics compared to thoe within the boundaries
df_nogenre <- df_nogenre %>%
  mutate(duration_outlier = if_else(duration_ms < lower_boundary | duration_ms > upper_boundary,
      "Outlier",
      "Within range"))

df_nogenre %>%
  group_by(duration_outlier) %>%
  mutate(popularity_num = as.numeric(popularity)) %>%
  summarise(
    n = n(),
    percentage = n / nrow(df_nogenre) * 100,
    mean_popularity = mean(popularity_num),
    median_popularity = median(popularity_num)
  )

# since the popularity of songs with unusual durations is almost identical to the non-outliers, I will not remove the outliers

