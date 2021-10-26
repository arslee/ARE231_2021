
# county and state boundaries
cb <- tigris::counties() %>% 
  filter(!STATEFP %in% c("15","02","72","78","60","66","69")) # drop outside the CONUS.

sb <- tigris::states() %>%
  filter(!STATEFP %in% c("15","02","72","78","60","66","69"))

# calculating degree days (from TrenchR)
degree_days <- function (T_min, T_max, LDT = NA, UDT = NA, method = "single.sine") 
{
  stopifnot(T_max >= T_min, method %in% c("single.sine", 
                                          "double.sine", "single.triangulation", "double.triangulation"))
  alpha = (T_max - T_min)/2
  dd = 0
  if (method == "single.sine") {
    if (T_min >= UDT && T_max >= UDT) {
      dd = (T_max - T_min)
    }
    else if (T_min >= LDT && T_max >= UDT) {
      theta2 = asin((UDT - (T_max + T_min)/2)/alpha)
      dd = 1/pi * (((T_max + T_min)/2 - LDT) * (theta2 + 
                                                  pi/2) + (UDT - LDT) * (pi/2 - theta2) - alpha * 
                     cos(theta2))
    }
    else if (T_min <= LDT && T_max >= UDT) {
      theta2 = asin((UDT - (T_max + T_min)/2)/alpha)
      theta1 = asin((LDT - (T_max + T_min)/2)/alpha)
      dd = 1/pi * ((((T_max + T_min)/2) - LDT) * (theta2 - 
                                                    theta1) + alpha * (cos(theta1) - cos(theta2)) + 
                     (UDT - LDT) * (pi/2 - theta2))
    }
    else if (T_min >= LDT && T_max <= UDT) {
      dd = ((T_max + T_min)/2) - LDT
    }
    else if (T_min <= LDT && T_max >= LDT) {
      theta1 = asin(pmax(-1, pmin(1, (LDT - (T_max + T_min)/2)/alpha)))
      dd = 1/pi * ((((T_max + T_min)/2) - LDT) * ((pi/2) - 
                                                    theta1) + alpha * cos(theta1))
    }
    else if (T_min < LDT && T_max <= LDT) {
      dd = 0
    }
  }
  if (method == "double.sine") {
    if (T_min >= LDT && T_max >= UDT) {
      dd = (UDT - LDT)/2
    }
    else if (T_min >= LDT && T_max >= UDT) {
      theta2 = asin((UDT - (T_max + T_min)/2)/alpha)
      dd = 1/(2 * pi) * (((T_max + T_min)/2 - LDT) * (theta2 + 
                                                        pi/2) + (UDT - LDT) * (pi/2 - theta2) - alpha * 
                           cos(theta2))
    }
    else if (T_min <= LDT && T_max >= UDT) {
      theta2 = asin((UDT - (T_max + T_min)/2)/alpha)
      theta1 = asin((LDT - (T_max + T_min)/2)/alpha)
      dd = 1/(2 * pi) * (((T_max + T_min)/2 - LDT) * (theta2 - 
                                                        theta1) + alpha * (cos(theta1) - cos(theta2)) + 
                           (UDT - LDT) * (pi/2 - theta2))
    }
    else if (T_min >= LDT && T_max <= UDT) {
      dd = 0.5 * ((T_max + T_min)/2 - LDT)
    }
    else if (T_min <= LDT && T_max >= LDT) {
      theta1 = asin(pmax(-1, pmin(1, (LDT - (T_max + T_min)/2)/alpha)))
      dd = 1/(2 * pi) * (((T_max + T_min)/2 - LDT) * (pi/2 - 
                                                        theta1) + alpha * cos(theta1))
    }
    else if (T_min <= LDT && T_max <= LDT) {
      dd = 0
    }
    dd = dd * 2
  }
  if (method == "single.triangulation") {
    MT = (T_max + T_min)/2
    if (T_min >= UDT && T_max >= UDT) {
      dd = (UDT - LDT)
    }
    else if (T_min >= LDT && T_max >= UDT) {
      dd = (MT - LDT) - ((T_max - UDT)^2/((T_max - T_min) * 
                                            2))
    }
    else if (T_min <= LDT && T_max >= UDT) {
      dd = ((T_max - LDT)^2 - (T_max - UDT)^2)/((T_max - 
                                                   T_min) * 2)
    }
    else if (T_min >= LDT && T_max <= UDT) {
      dd = MT - LDT
    }
    else if (T_min <= LDT && T_max >= LDT) {
      dd = (T_max - LDT)^2/((T_max - T_min) * 2)
    }
    else if (T_min <= LDT && T_max <= LDT) {
      dd = 0
    }
  }
  if (method == "double.triangulation") {
    MT = (T_max + T_min)/2
    if (T_min >= UDT && T_max >= UDT) {
      dd = (UDT - LDT)/2
    }
    else if (T_min >= LDT && T_max >= UDT) {
      dd = (MT - LDT) - ((T_max - UDT)^2/((T_max - T_min) * 
                                            4))
    }
    else if (T_min <= LDT && T_max >= UDT) {
      dd = ((T_max - LDT)^2 - (T_max - UDT)^2)/((T_max - 
                                                   T_min) * 4)
    }
    else if (T_min >= LDT && T_max <= UDT) {
      dd = (MT/4) - (LDT/2)
    }
    else if (T_min <= LDT && T_max >= LDT) {
      dd = (T_max - LDT)^2/((T_max - T_min) * 4)
    }
    else if (T_min <= LDT && T_max <= LDT) {
      dd = 0
    }
    dd = dd * 2
  }
  return(round(dd, 7))
}