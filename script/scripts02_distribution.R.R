# QUESTION 2: Weighted earnings distribution

library(ggplot2)
library(svglite)
library(scales)

# Count valid earners before applying histogram range
n_earners <- nrow(data)

# Histogram range: Rs 10,000 to Rs 10,000,000
in_range <- data$earn_annual >= 10000 &
  data$earn_annual <= 10000000

n_excluded <- sum(!in_range)
hist_data <- data[in_range, ]

# Weighted statistics from all valid earners
unweighted_median <- median(data$earn_annual)
weighted_results <- weighted_quantile(
  data$earn_annual,
  data$hhweight,
  c(0.10, 0.50, 0.90)
)

p10 <- weighted_results[1]
p50 <- weighted_results[2]
p90 <- weighted_results[3]
p90_p10_ratio <- p90 / p10

# Histogram using log10 earnings
p_hist <- ggplot(
  hist_data,
  aes(x = log10(earn_annual), weight = hhweight)
) +
  geom_histogram(
    breaks = seq(4, 7, by = 0.1),
    aes(y = after_stat(count / sum(count) / 0.1)),
    fill = "steelblue",
    color = "white"
  ) +
  geom_vline(
    xintercept = log10(p50),
    linetype = "dashed",
    color = "red"
  ) +
  geom_vline(
    xintercept = log10(p90),
    linetype = "dashed",
    color = "darkgreen"
  ) +
  annotate(
    "text",
    x = log10(p50),
    y = Inf,
    label = paste("Median: Rs", format(round(p50), big.mark = ",")),
    color = "red",
    angle = 90,
    vjust = 1.5,
    hjust = 1.1
  ) +
  annotate(
    "text",
    x = log10(p90),
    y = Inf,
    label = paste("P90: Rs", format(round(p90), big.mark = ",")),
    color = "darkgreen",
    angle = 90,
    vjust = 1.5,
    hjust = 1.1
  ) +
  scale_x_continuous(
    breaks = 4:7,
    labels = c("10,000", "100,000", "1,000,000", "10,000,000")
  ) +
  labs(
    title = "The 90th-percentile earner makes 5.8 times the 10th-percentile earner",
    x = "Annual earnings (Rs)",
    y = "Weighted density per log10 unit",
    caption = paste0(
      "Source: PSLM 2019–20 | Sindh urban earners, ages 15–64, ",
      "positive earnings | Weighted by hhweight | ",
      n_excluded, " earners outside histogram range"
    )
  ) +
  theme_minimal()

# Save as SVG
dir.create("figures", showWarnings = FALSE)

ggsave(
  "figures/distribution.svg",
  plot = p_hist,
  width = 9,
  height = 6
)

# Print required statistics
cat("No. of earners:", n_earners, "\n")
cat("Unweighted median:", round(unweighted_median), "\n")
cat("Weighted P10:", round(p10), "\n")
cat("Weighted median:", round(p50), "\n")
cat("Weighted P90:", round(p90), "\n")
cat("P90/P10 ratio:", round(p90_p10_ratio, 2), "\n")
cat("Excluded from histogram:", n_excluded, "\n")

