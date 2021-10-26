#---------------[   Purpose    ]--------------------
#
# Compare my data with Wolfram Schlenker's for (monthly) 2019
#
#---------------[   Sys Info   ]--------------------
#
#  Date  : Tue Oct 26 10:45:32 2021
#  Author: Seunghyun Lee
#  OS    : Windows
#  Node  : DESKTOP-8FJP3KC
#
#---------------[ Pinned Notes ]--------------------
#
# 
#
#---------------[   Process    ]--------------------




# Prep data ----------------------------------------------------------------------
#--- SL ---#
#----@ input: Data/Processed/daily_dday_2019_2020.csv @----
df_SL <- fread("Data/Processed/daily_dday_2019_2020.csv")


df_monthlySL_ddayprec <- df_SL[year == 2019, lapply(.SD, sum, na.rm = T), .SDcols = patterns("dday|prec"), .(fips, month)] %>%
  melt(id.vars = c("fips", "month"))

df_monthlySL_temp <- df_dday[year == 2019, lapply(.SD, mean, na.rm = T), .SDcols = patterns("tM|tA"), .(fips, month)] %>%
  melt(id.vars = c("fips", "month"))

df_monthlySL <- rbind(df_monthlySL_ddayprec, df_monthlySL_temp)
rm(df_monthlySL_ddayprec, df_monthlySL_temp, df_SL)

setnames(df_monthlySL, "value", "valueSL")

#--- WS ---#
#----@ input: Data/Raw/monthlyGDD_WS.csv @----
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
  ggtitle("WS vs SL: Monthly Weather Data for 2019")

ggsave(filename = "Figure/compare_WS_SL_monthly_2019.png", width = 20, height = 10, dpi = 300, units = "in", device = "png")
