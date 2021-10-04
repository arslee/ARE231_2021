#---------------[   Purpose    ]--------------------
#
# To download annual county-level acreage and yield data for 3 I states from 1981 to 2019
#
#---------------[   Sys Info   ]--------------------
#
#  Date  : Fri Oct 01 21:17:19 2021
#  Author: Seunghyun Lee
#  OS    : Windows
#  Node  : DESKTOP-8FJP3KC
#
#---------------[ Pinned Notes ]--------------------
#
#
#
#---------------[   Process    ]--------------------



# Test --------------------------------------------------------------------

nassqs_auth(key = par$apikey)

params <- list(
  commodity_desc = "CORN",
  source_desc = "SURVEY",
  agg_level_desc = "COUNTY",
  state_alpha = par$states[1],
  year = 2012,
  statisticcat_desc = "YIELD"
)

df <- nassqs(params)

class(df)
sapply(df, class)
head(df)



# 1. Loop --------------------------------------------------------------------

## grid  -------------------------------------
grid <- expand_grid(
  st = par$states,
  var = c(
    "CORN, GRAIN - YIELD, MEASURED IN BU / ACRE",
    "SOYBEANS - YIELD, MEASURED IN BU / ACRE",
    #----@ note: use harvested acres  @----
    "CORN, GRAIN - ACRES HARVESTED",
    "SOYBEANS - ACRES HARVESTED"
  )
)

## function  -------------------------------------
extract_nass <- function(st, var) {
  library(rnassqs)
  nassqs(
    source_desc = "SURVEY",
    agg_level_desc = "COUNTY",
    state_alpha = st,
    short_desc = var
  ) %>% 
  filter(year %in% par$years)
}

## loop  -------------------------------------
plan(multisession)
df <- future_pmap(.progress=T, grid, extract_nass) %>% rbindlist(use.names = T)


# 2. clean -------------------------------------------------------------------

df_ya <- df %>%
  filter(county_name != "OTHER (COMBINED) COUNTIES") %>%
  distinct() %>%
  mutate(
    Value = as.numeric(str_replace(Value, ",", "")),
    fips = as.integer(paste0(state_fips_code, county_code))
  ) %>%
  select(state_alpha, fips, year, short_desc, commodity_desc, statisticcat_desc, Value) %>%
  mutate(var = paste0(str_sub(statisticcat_desc, 1, 1), "_", commodity_desc) %>% tolower()) %>%
  select(state_alpha, fips, year, var, Value) %>%
  spread(var, Value)


vis_miss(df_ya)
summary(df_ya)


# 3. export ---------------------------------------------------------------------
#----@ output: Data/Processed/df_ya.rds @----
saveRDS(df_ya, "Data/Processed/df_ya.rds")


