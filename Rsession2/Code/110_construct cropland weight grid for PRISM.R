#---------------[   Purpose    ]--------------------
#
# Calculate fraction of crop+pasture on the PRISM grid cells
#
#---------------[   Sys Info   ]--------------------
#
#  Date  : Sat Oct 23 12:40:11 2021
#  Author: Seunghyun Lee
#  OS    : Windows
#  Node  : DESKTOP-8FJP3KC
#
#---------------[ Pinned Notes ]--------------------
#
#
#
#---------------[   Process    ]--------------------
rm(list = ls())
source("Code/001_packages.R")
source("Code/002_functions.R")


# You can download PRISM data using `prism` package
# Below are some examples

# options(prism.path = "Your directory")
# get_prism_dailys("tmin", minDate = "2019-01-01", maxDate = "2020-12-31")
# get_prism_dailys("tmax", minDate = "2019-01-01", maxDate = "2020-12-31")
# get_prism_dailys("ppt",  minDate = "2019-01-01", maxDate = "2020-12-31")

## Obtain  prism file list ------------------------------
#----@ input: prism rasters @----

prism_list <- list.files("Data/Raw/prism/", full.names = T, pattern = ".*bil$", recursive = TRUE)
prism_list %>% head()

## Load landcover raster --------------------------------------
#----@ input: land cover 2019 from NLCD @----
nlcd_R <- raster("Data/Raw/nlcd_2019_land_cover_l48_20210604/nlcd_2019_land_cover_l48_20210604.img")

nlcd_R
plot(nlcd_R)

attributes(nlcd_R)
land_class_table <- data.table(attributes(nlcd_R)$data@attributes[[1]])
land_class_table$NLCD.Land.Cover.Class %>% unique()
land_class_table[NLCD.Land.Cover.Class %in% c("Hay/Pasture", "Cultivated Crops")]



## Polygonize one PRISM raster --------------------------------------------------
prism_R <- raster(prism_list[[1]])
prism_P <- rasterToPolygons(prism_R)
prism_P <- st_as_sf(prism_P)


## Calculate fraction of crop+pasture for each PRISM griddcell  ------------------
prism_P$crop_pasture <- exactextractr::exact_extract(
  nlcd_R, prism_P,
  function(value, coverage_fraction) {
    sum(coverage_fraction[value %in% c(81, 82)]) / sum(coverage_fraction)
  }
)

## Rasterize  -------------------------------------
crop_R <- fasterize(prism_P, prism_R, "crop_pasture")
names(crop_R) <- "PRISM_grid_cropland"


## Visualize  -------------------------------------
png("PRISM_grid_cropland", width = 1000 * 2, height = 1000, pointsize = 35)

plot(crop_R,
  main = "Fraction of crop + pasture land in PRISM gridcell",
  breaks = seq(0, 1, .1),
  col = brewer.ylgnbu(10),
  axes = F, box = F, legend.width = 2,
  legend.args = list(
    text = "Fraction of cropland in PRISM gridcell",
    side = 4, font = 1, line = 2.5, cex = 1
  )
)


dev.off()

## Export cropland weight grid -------------------------------------
#----@ output: Data/PRISM_grid_cropland.tif @----

writeRaster(crop_R, "Data/PRISM_grid_cropland.tif", overwrite = T)
