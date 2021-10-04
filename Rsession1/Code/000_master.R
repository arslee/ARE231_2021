# clear
rm(list = ls())

# set directory
if (Sys.info()[["nodename"]] == "DESKTOP-8FJP3KC") {
  setwd("C:/Users/Seunghyun Lee/Dropbox/Teaching/ARE231_2021/Rsession1/")
}else{
  setwd("/Users/seunghyunlee/Dropbox/Teaching/ARE231_2021/Rsession1") 
}

getwd()
# setup files
source("Code/001_packages.R")
source("Code/002_functions.R")
source("Code/003_parameters_public.R")
source("Code/004_parameters_private.R")

# codes
source("Code/100_download and clean yield and acreage.R")
source("Code/110_construct annual county-level weather.R")
source("Code/120_exploratory data visualization.R")
source("Code/130_analysis.R")
