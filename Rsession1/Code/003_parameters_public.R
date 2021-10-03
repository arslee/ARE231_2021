par <- list()

par$crops <- c("CORN", "SOYBEANS")
par$years <- 1981:2019
par$states <- c("IA", "IL", "IN")
par$fips <- cb %>%
  filter(STATEFP %in% 17:19) %>%
  pull(GEOID)
par$gs <- 4:9
