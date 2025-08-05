library(tidyverse)
library(gt)
library(gtExtras)
library(patchwork)

songs <- read.csv("cleaned_unpopular_songs.csv")

# Which artists have the most unpopular songs? What's the popularity of their songs on average?
# I started by selecting each song one time, omitting duplicates.
songs_by_artist <- songs %>% 
  select(
    track_artist, 
    track_name,
    popularity
    ) %>% 
  distinct(
    track_artist,
    track_name,
    popularity
    )

# Then, I grouped the new dataset by artist to count the number of songs of each artist and then arrange the counts in descending order before taking the top 10.
# These are the top artists who have most of their songs with popularity of less than ten.
unpopular_artists <- songs_by_artist %>%
  group_by(track_artist) %>% 
  count() %>% 
  arrange(desc(n)) %>%
  head(n=10)

# The next step was to find the average popularity score of these artists. 

# In this step, I used the dataset of unique songs, grouped by artists.
# I created a new variable that is the average of the popularity score of the songs of an artist then took the unique scores to preserve the artist and the average popularity score only.
avg_pop <- songs_by_artist %>% 
  group_by(track_artist) %>% 
  mutate(avg_pop = round(mean(popularity),2)) %>% 
  ungroup %>% 
  select(track_artist, avg_pop) %>%
  arrange(desc(avg_pop)) %>% 
  distinct(track_artist, avg_pop)

# Finally, I joined the two datasets such that I have the artist with the most unpopular songs together with their average popularity
most_unpopular_artists <- unpopular_artists %>%
  arrange(desc(n)) %>%
  left_join(avg_pop) %>%
  as_tibble()

# To create the chart, I started with a table of the average popularity scores by artist
plot_avg_pop_scores <- most_unpopular_artists %>%
  select(track_artist, 
         avg_pop
         ) %>%
  gt() %>%
  tab_header(title = md("Average Popularity by Artist")) %>%
  cols_label(track_artist="",
             avg_pop=""
             )

plot_avg_pop_scores

# Then, I created a lolipop chart of the number of songs of each artist
plot_artist_unpop_songs <- ggplot(most_unpopular_artists, aes(x=reorder(track_artist, n), y=n)) +
  geom_segment( aes(x=reorder(track_artist, n), xend=reorder(track_artist, n), y=0, yend=n), size=0.75) +
  geom_point(size=5, color="#1DB954", fill="#1DB954", shape=21, stroke=2) +
  coord_flip() +
  labs(
    title = "Top 10 Artists with the Most Unpopular Songs",
    x = "",
    y = "Number of Songs"
  ) +
  theme(
    plot.margin = grid::unit(c(.5,.5,1.5,.5), "cm"),
    axis.text.y = element_text(
      size = 8, 
      family = "Helvetica",
      hjust = 1
    ),
    axis.text.x = element_text(size = 8, vjust = -1),
    axis.ticks.x = element_blank(),
    panel.grid = element_blank(),
    panel.background = element_rect(fill = NA),
    plot.title = element_text(
      hjust = 0.5,
      vjust = 1
    ),
    axis.title.x = element_text(
      hjust = 0.5, 
      size=10, 
      vjust=-2
    ),
    axis.title.y = element_text(
      hjust = 0.5, 
      size=10, 
      vjust = 4
    ),
    text = element_text(
      family = "Helvetica", 
      face = "bold"
    )
  )

plot_artist_unpop_songs

# Finally, I combined the two in the same plot
plot_artist_unpop <- plot_artist_unpop_songs +
  inset_element(plot_avg_pop_scores, 
                left = 0.7, 
                bottom = 0.5, 
                right = 0.75, 
                top = 0.6)

plot_artist_unpop


# How does popularity score varies across music keys? Can danceability explain the variation?
plot_popularity_key <- ggplot(songs, 
                         aes(
                           x = popularity,
                           y = key_fct
                         )
) +
  geom_jitter(
    aes(color = danceability)
  ) +
  geom_boxplot(
    aes(group = key_fct), 
    color = "black", 
    alpha = 0.75, 
    width = 0.5, 
    outlier.shape = NA
  ) +
  # stat_summary(
  #   fun = median, 
  #   geom = "label", 
  #   aes(label=round(..y..))
  #   ) +
  scale_color_gradientn(
    colours = c(
      "black", 
      "blue", 
      "magenta", 
      "yellow"
    ),
    name = "Danceability"
  ) +
  labs(
    title = "Track Popularity for Each Music Key",
    x = "Track Popularity",
    y = "Music Key"
  ) +
  theme(
    legend.text = element_text(colour = "grey20"),
    plot.margin = grid::unit(c(.5,.5,1.5,.5), "cm"),
    axis.text.y = element_text(
      size = 6, 
      family = "Helvetica",
      hjust = 1
    ),
    axis.text.x = element_text(size = 8, vjust = -1),
    #axis.ticks.y = element_blank(),
    panel.grid = element_blank(),
    panel.background = element_rect(fill = NA),
    plot.title = element_text(
      hjust = 0.5,
      vjust = 1
    ),
    axis.title.x = element_text(
      hjust = 0.5, 
      size=10, 
      vjust=-2
    ),
    axis.title.y = element_text(
      hjust = 0.5, 
      size=10, 
      vjust = 4
    ),
    text = element_text(
      family = "Helvetica", 
      face = "bold"
    )
  )

plot_popularity_key

# What's the average danceability score of unpopular score?

