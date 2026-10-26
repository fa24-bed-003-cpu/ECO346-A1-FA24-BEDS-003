# Default graph for Question 4

# 1. Set repository folder
#AbdulMateen
#FA24-BEDS-003

# 2. Load required packages
library(ggplot2)
library(svglite)

# 3. Read local data files
person <- read.csv("data/pslm_person_subset.csv")
household <- read.csv("data/pslm_hh_subset.csv")

# 4. Attach household information to person data
data <- merge(
  person,
  household[, c("hhid", "hhweight", "prov_code", "urban_rural")],
  by = "hhid"
)

# 5. Select Variant 3: Sindh Urban earners
data <- data[
  data$prov_code == 3 &
    data$urban_rural == 2 &
    data$age >= 15 &
    data$age <= 64 &
    data$earn_annual > 0,
]

# 6. Create figures folder if it does not exist
dir.create("figures", showWarnings = FALSE)

# 7. Create the untouched default graph
p_default <- ggplot(data, aes(age, earn_annual)) +
  geom_point()

# 8. Save graph as SVG
ggsave(
  "figures/default.svg",
  plot = p_default,
  width = 8,
  height = 5
)
file.exists("figures/default.svg")
