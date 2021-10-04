#---------------[   Purpose    ]--------------------
#
# Run regressions and compare coef and confidence intervals depending on specifications
#
#---------------[   Sys Info   ]--------------------
#
#  Date  : Fri Oct 01 22:40:49 2021
#  Author: Seunghyun Lee
#  OS    : Windows
#  Node  : DESKTOP-8FJP3KC
#
#---------------[ Pinned Notes ]--------------------
#
#
#
#---------------[   Process    ]--------------------


# prep data ---------------------------------------------------------------

df_weather <- readRDS("Data/Processed/df_weather.rds")
df_ya <- readRDS("Data/Processed/df_ya.rds")

df <- left_join(df_ya, df_weather, by = c("fips", "year"))



# primitive lists for grid ---------------------------------------------------------

period_list <- list(
  full = 1981:2019,
  pre2000 = 1981:2000,
  post2000 = 2001:2019
)

trend_list <- list(
  cty_lr = "year:factor(fips)",
  st_ly = "year:factor(state_alpha)",
  cty_qdr = "year:factor(fips)+year^2:factor(fips)",
  st_qdr = "year:factor(state_alpha)+year^2:factor(state_alpha)"
)

weather_list <- list(
  w_prec = "prec+precsq+gdd+hdd",
  wo_prec = "gdd+hdd"
)


# grid for regression -----------------------------------------------------

grid <- expand_grid(
  crop = tolower(par$crops),
  period = names(period_list),
  weight = c("none", "a"),
  cluster = c("year", "state_alpha"),
  trend = names(trend_list),
  weather = names(weather_list)
) %>%
  mutate(id = 1:n())


#  regression function ----------------------------------------------------

reg <- function(crop, period, weight, cluster, trend, weather, id) {

  #--- regression equation ---#
  y <- paste0("log(", "y_", crop, ")")
  fml <- paste0(y, "~", weather_list[[weather]], "+", trend_list[[trend]], "|fips") %>% formula()

  print(y)
  print(id)

  #--- run regressions ---#
  if (weight != "none") {
    w <- paste0(weight, "_", crop)
    output <- feols(fml, data = df, weights = df %>% pull(w), cluster = cluster)
  } else {
    output <- feols(fml, data = df, cluster = cluster)
  }

  #--- extract results of interest ---#
  output %>%
    tidy() %>%
    filter(term == "hdd")
}


# run regression and store results ----------------------------------------

df_result <- grid %>%
  mutate(result = pmap(., reg)) %>%
  unnest(result) %>%
  mutate(low = estimate - 1.96 * std.error, high = estimate + 1.96 * std.error)




# prep data for plot ------------------------------------------------------

columns <- names(grid)[names(grid) != "id"]
df_plot <- lapply(1:length(columns), function(col) {
  df_result %>%
    group_by(across(columns[col])) %>%
    slice(1) %>%
    # extract only first rows by the group
    mutate(dim = columns[col])
}) %>% bind_rows()


# plot --------------------------------------------------------------------

df_plot %>%
  mutate(spec = paste(crop, period, weight, cluster, trend, weather, sep = "\n")) %>%
  ggplot(aes(spec, estimate)) +
  geom_point() +
  geom_errorbar(aes(ymin = low, ymax = high)) +
  facet_wrap(~dim, scales = "free_x", ) +
  theme_bw()

ggsave("Figure/result.png", height = 5, width = 7)
