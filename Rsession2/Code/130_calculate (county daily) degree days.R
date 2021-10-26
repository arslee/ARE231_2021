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
df_temp <- list.files("Data/Processed/prism_co/temperatures/", full.names = T, ) %>%
  lapply(readRDS) %>%
  rbindlist() %>%
  na.omit()

## Calculate degree days by thresholds  -------------------------------------
thresholds <- c(0, 5, 8, 10, 12, 15, 20, 25, 29, 30, 31, 32, 33, 34)

df_temp[, tAvg := (tmin + tmax) / 2]
df_temp[, fips := as.integer(GEOID)]
df_temp[, GEOID := NULL]

plan(multisession)
df_dday <- future_map_dfc(.progress = T, thresholds, function(thr) {
  dday <- data.table(v = pmap_dbl(
    list(df_temp$tmin, df_temp$tmax),
    function(tmin, tmax) {
      degree_days(tmin, tmax, thr, 100)
    }
  ))
  setnames(dday, "v", paste0("dday", thr, "C"))
})

df_dday <- cbind(df_temp, df_dday)
setnames(df_dday, c("tmax", "tmin", "ppt"), c("tMax", "tMin", "prec"))
setcolorder(df_dday, c("fips", "year"))


#----@ output: Data/daily_dday_2019_2020.csv @----

fwrite(df_dday, "Data/Processed/daily_dday_2019_2020.csv")
