#---------------[   Purpose    ]--------------------
#
# Exploratory data analysis only for yield
#
#---------------[   Sys Info   ]--------------------
#
#  Date  : Fri Oct 01 23:39:46 2021
#  Author: Seunghyun Lee
#  OS    : Windows
#  Node  : DESKTOP-8FJP3KC
#
#---------------[ Pinned Notes ]--------------------
#
#
#
#---------------[   Process    ]--------------------
df_ya <- readRDS("Data/Processed/df_ya.rds")

df_plot <- df_ya %>%
  select(year, contains("y_")) %>%
  pivot_longer(!year) %>%
  group_by(year, name) %>%
  summarise(value = mean(value, na.rm = T)) %>%
  ungroup()

df_plot %>%
  ggplot(aes(x = year, y = log(value), color = name)) +
  geom_line() +
  theme_minimal() +
  geom_vline(xintercept = c(1983, 1988, 2012), color = "blue") +
  theme_bw() +
  ggtitle("Log Yield")
