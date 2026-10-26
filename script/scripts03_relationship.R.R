
# QUESTION 3: Earnings by Age

library(ggplot2)
library(svglite)
library(scales)

# Create 5-year age bands
age_labels <- paste(
  seq(15, 60, by = 5),
  seq(19, 64, by = 5),
  sep = "-"
)

data$age_band <- cut(
  data$age,
  breaks = seq(15, 65, by = 5),
  right = FALSE,
  labels = age_labels
)

# Calculate weighted mean earnings
band_means <- aggregate(
  cbind(
    weighted_earnings = data$earn_annual * data$hhweight,
    total_weight = data$hhweight
  ),
  by = list(age_band = data$age_band),
  FUN = sum
)

band_means$weighted_mean <-
  band_means$weighted_earnings / band_means$total_weight

# Count earners in each age band
band_counts <- as.data.frame(table(data$age_band))
names(band_counts) <- c("age_band", "n_observations")

band_means <- merge(
  band_means,
  band_counts,
  by = "age_band",
  all.x = TRUE,
  sort = FALSE
)

# Correct age-band order and midpoint
band_means$age_band <- factor(
  band_means$age_band,
  levels = age_labels
)

band_means <- band_means[
  order(match(as.character(band_means$age_band), age_labels)),
]

band_means$midpoint <- seq(17, 62, by = 5)
band_means$thin <- band_means$n_observations < 30

# Full table for README
band_table <- data.frame(
  band = as.character(band_means$age_band),
  number_of_earners = band_means$n_observations,
  weighted_mean_earnings = round(band_means$weighted_mean)
)

print(band_table)

# Identify highest weighted mean
highest_band <- band_means[
  which.max(band_means$weighted_mean),
]

highest_label <- paste(
  "Highest:",
  as.character(highest_band$age_band)
)

# Draw graph
p_q3 <- ggplot(data, aes(x = age, y = earn_annual)) +
  geom_point(
    position = position_jitter(width = 0.4, height = 0),
    alpha = 0.25,
    color = "grey35"
  ) +
  geom_line(
    data = band_means,
    aes(x = midpoint, y = weighted_mean, group = 1),
    color = "blue",
    linewidth = 1
  ) +
  geom_point(
    data = band_means,
    aes(
      x = midpoint,
      y = weighted_mean,
      fill = thin
    ),
    shape = 21,
    color = "blue",
    size = 4,
    stroke = 1.2
  ) +
  geom_text(
    data = highest_band,
    aes(
      x = midpoint,
      y = weighted_mean,
      label = highest_label
    ),
    color = "red",
    vjust = -1,
    inherit.aes = FALSE
  ) +
  scale_fill_manual(
    values = c("FALSE" = "blue", "TRUE" = "white"),
    guide = "none"
  ) +
  scale_x_continuous(
    breaks = seq(15, 65, by = 5),
    limits = c(15, 65)
  ) +
  scale_y_log10(
    breaks = 10^(4:7),
    labels = label_comma()
  ) +
  coord_cartesian(ylim = c(10000, 10000000)) +
  labs(
    title = "Weighted Mean Earnings Peak at Ages 55–59",
    x = "Age (years)",
    y = "Annual earnings (Rs)",
    caption = paste(
      "Source: PSLM 2019–20 | Sindh urban earners, ages 15–64,",
      "with positive annual earnings | Weighted by household weight",
      "| Hollow markers indicate age bands with fewer than 30 earners"
    )
  ) +
  theme_minimal()

print(p_q3)

# Save figure
dir.create("figures", showWarnings = FALSE)

ggsave(
  "figures/q3_age_earnings.svg",
  plot = p_q3,
  width = 9,
  height = 6
)

# Required results
band_table[
  band_table$band %in% c("25-29", "45-49"),
]

band_table[
  which.max(band_table$weighted_mean_earnings),
]

file.exists("figures/relationship.svg")
