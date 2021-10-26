# clear -------------------------------------------------------------------
rm(list = ls())



# working directory -------------------------------------------------------
setwd("C:/Users/Seunghyun Lee/Dropbox/Teaching/ARE231_2021/Rsession2/")
getwd()



# set up ------------------------------------------------------------------

source("Code/001_packages.R")
source("Code/002_functions.R")


# process -----------------------------------------------------------------

source("Code/110_construct cropland weight grid for PRISM.R")
source("Code/120_calculate (county daily) tmin, tmax, ppt.R")
source("Code/130_calculate (county daily) degree days.R")