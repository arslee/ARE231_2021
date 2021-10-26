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
  drop_na()

## Calculate degree days by thresholds  -------------------------------------
thresholds <- c(0, 5, 8, 10, 12, 15, 20, 25, 29, 30, 31, 32, 33, 34)

plan(multisession)

df_dday <- future_map_dfc(
  .progress = T,
  thresholds, function(thr) {
    print(thr)
    dday <- future_pmap_dbl(
      list(df_temp$tmin, df_temp$tmax),
      function(tmin, tmax) {
        degree_days(tmin, tmax, thr, 100)
      }
    )
    out <- data.table(v = dday)
    setnames(out, "v", paste0("dday", thr, "C"))
  }
)

df_dday <- cbind(df_temp, df_dday)
setDT(df_dday)
setnames(df_dday, c("tmax", "tmin", "ppt", "GEOID"), c("tMax", "tMin", "prec", "fips"))

df_dday[, tAvg := (tMin + tMax) / 2]
df_dday[, fips := as.integer(fips)]

#----@ output: Data/daily_dday_2019_2020.csv @----

fwrite(df_dday, "Data/Processed/daily_dday_2019_2020.csv")


## Compare my data with Schlenker's for (monthly) 2019--------------------------------------------------------------


#--- SL ---#
df_monthlySL_ddayprec <- df_dday[year == 2019, lapply(.SD, sum, na.rm = T), .SDcols = patterns("dday|prec"), .(fips, month)] %>%
  melt(id.vars = c("fips", "month"))

df_monthlySL_temp <- df_dday[year == 2019, lapply(.SD, mean, na.rm = T), .SDcols = patterns("tM|tA"), .(fips, month)] %>%
  melt(id.vars = c("fips", "month"))

df_monthlySL <- rbind(df_monthlySL_ddayprec, df_monthlySL_temp)
rm(df_monthlySL_ddayprec, df_monthlySL_temp)

setnames(df_monthlySL, "value", "valueSL")

#--- WS ---#
df_monthlyWS <- fread("Data/Raw/monthlyGDD_WS.csv")[year == 2019, ][, year := NULL] %>%
  melt(id.vars = c("fips", "month"))
setnames(df_monthlyWS, "value", "valueWS")


#--- plot ---#
df_plot <- df_monthlySL[df_monthlyWS, on = c("fips", "month", "variable")][, .(valueSL, valueWS, variable)]

df_plot %>%
  ggplot(aes(x = valueWS, y = valueSL)) +
  geom_point(color = alpha("black", .02)) +
  geom_smooth(method = "lm", formula = "y~x") +
  facet_wrap(~variable, scales = "free", nrow = 3) +
  theme_classic(base_size = 10) +
  theme(
    axis.text = element_text(size = 25),
    axis.text.x = element_text(size = 20),
    axis.text.y = element_text(size = 20),
    axis.title = element_text(size = 25, face = "bold"),
    strip.text = element_text(size = 20)
  ) +
  ggtitle("WS vs SL: Monthly Weather Data for 2019 ")

ggsave(filename = "Figure/compare_WS_SL_monthly_2019.png", width = 20, height = 10, dpi = 300, units = "in", device = "png")
