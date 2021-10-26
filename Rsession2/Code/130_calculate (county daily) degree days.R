#---------------[   Purpose    ]--------------------
#
# Construct county-level degree days for 2019 and 2020
#
#---------------[   Sys Info   ]--------------------
#
#  Date  : Mon Oct 25 20:10:09 2021
#  Author: Seunghyun Lee
#  OS    : Windows
#  Node  : DESKTOP-8FJP3KC
#
#---------------[ Pinned Notes ]--------------------
#
#
#
#---------------[   Process    ]--------------------


## Load county-level temperature data  -------------------------------------
#----@ input:  Data/prism_co/temperatures/@----
df_dday <- list.files("Data/Processed/prism_co/temperatures/", full.names = T, ) %>%
  lapply(readRDS) %>%
  rbindlist() %>%
  na.omit()

## Calculate degree days by thresholds  -------------------------------------
thresholds <- c(0, 5, 8, 10, 12, 15, 20, 25, 29, 30, 31, 32, 33, 34)

df_dday[, tAvg := (tmin + tmax) / 2]
df_dday[, fips := as.integer(GEOID)]
df_dday[, GEOID := NULL]

df_dday[, paste0("dday", thresholds, "C") := map(thresholds, function(thr) {
  degree_days(tmin, tmax, thr, 100) %>% as.numeric()
})][]

setnames(df_dday, c("tmax", "tmin", "ppt"), c("tMax", "tMin", "prec"))
setcolorder(df_dday, c("fips","year"))

#----@ output: Data/daily_dday_2019_2020.csv @----

fwrite(df_dday, "Data/Processed/daily_dday_2019_2020.csv")
