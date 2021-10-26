#---------------[   Purpose    ]--------------------
#
# Calculate tmin, tmax and ppt using PRISM rasters and cropland weight
#
#---------------[   Sys Info   ]--------------------
#
#  Date  : Sat Oct 23 14:51:22 2021
#  Author: Seunghyun Lee
#  OS    : Windows
#  Node  : DESKTOP-8FJP3KC
#
#---------------[ Pinned Notes ]--------------------
#
#
#
#---------------[   Process    ]--------------------


## Prep data ------------------------------
#----@ input: prism rasters @----
prism_list <- list.files("Data/prism/", full.names = T, pattern = ".*bil$", recursive = TRUE)
prism_list %>% head()

#----@ input: prism rasters @----
crop_R <- raster("Data/Processed/PRISM_grid_cropland.tif")

## Construct monthly grids for loop ---------------------------------------------------
months <- seq(as.Date("2019/01/01"),
  as.Date("2020/12/31"),
  by = "1 month"
) %>%
  str_sub(1, 7) %>%
  str_remove("-")



# Calculate tmin, tmax and ppt using PRISM rasters and cropland weight ----------------
plan(multisession)
future_map(.progress = T, months, function(m) {
  library(stringr)
  library(exactextractr)
  library(tidyverse)
  library(raster)
  library(dplyr)
  library(stringr)
  library(sf)

  prism_S <- prism_list[prism_list %>% str_detect(m)] %>%
    lapply(raster) %>%
    stack()

  out <- cbind(cb[, "GEOID"], exactextractr::exact_extract(prism_S, cb, "weighted_mean", weights = crop_R, stack_apply = T)) %>%
    st_drop_geometry() %>%
    pivot_longer(!"GEOID") %>%
    mutate(
      var = str_extract(name, "tmax|tmin|ppt"),
      date = str_extract(name, "[0-9]{8}"),
      year = as.integer(str_sub(date, 1, 4)),
      month = as.integer(str_sub(date, 5, 6)),
      day = as.integer(str_sub(date, 7, 8))
    ) %>%
    dplyr::select(-c("name", "date")) %>%
    spread(var, value)

  saveRDS(out, paste0("Data/Processed/prism_co/temperatures/", "t", m, ".rds"))
})
