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
  distinct(track_id, .keep_all = TRUE)

# Understanding the target variable: popularity

range(df_nogenre$popularity)

## frequency ditribution
df_nogenre %>%
  count(popularity) %>%
  mutate(
    "%" = n / sum(n) * 100
  )

## visualising the frequency distribution
ggplot(data = df_nogenre) +
  geom_bar(mapping = aes(x=popularity))+
  labs(y=NULL,
       x = "Popularity Score",
       y = "Number of Songs",
       title = "Frequency Distribution of Popularity Scores")

