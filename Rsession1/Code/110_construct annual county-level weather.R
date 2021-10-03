#---------------[   Purpose    ]--------------------
#
# To construct annual county-level weather variables
#
#---------------[   Sys Info   ]--------------------
#
#  Date  : Fri Oct 01 23:26:43 2021
#  Author: Seunghyun Lee
#  OS    : Windows
#  Node  : DESKTOP-8FJP3KC
#
#---------------[ Pinned Notes ]--------------------
#
#
#
#---------------[   Process    ]--------------------


#----@ input: Raw/weather_monthly.csv @----
df <- fread("Data/Raw/weather_monthly.csv")
df_weather <- df %>%
  filter(year %in% par$years & state %in% par$states & month %in% par$gs) %>%
  select(fips, year, month, prec, dday10C, dday30C) %>%
  group_by(fips, year) %>%
  summarize_at(c("prec", "dday10C", "dday30C"), sum, na.rm = T) %>%
  mutate(
    precsq = prec^2,
    gdd = dday10C - dday30C,
    hdd = dday30C
  ) %>%
  select(!c(dday10C, dday30C))

#----@ output: Data/Processed/df_weather.rds @----
saveRDS(df_weather, "Data/Processed/df_weather.rds")
