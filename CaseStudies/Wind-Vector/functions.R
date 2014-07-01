library(reshape2)
library(dplyr)
library(RNCEP)
library(lubridate)

getWindDay <- function(year, month, day, hour = c(0, 6, 12, 18), 
                    lat.southnorth, lon.westeast) {
  ## Retrieves & reshapes wind data by year, month, day, hour
  
  chosenDay <- sprintf("%d_%02d_%02d_%02d", year, month, day, hour)
  
  if(length(chosenDay) > 1) stop("All of year, month, day, and hour must be specified and of length 1")
  
  uv <- getWind(years = c(year, year), months = c(month, month),
                lat.southnorth = lat.southnorth, lon.westeast = lon.westeast)

  uv_filt <- filter(uv, date == ymd_h(chosenDay))  
  
  return(uv_filt)
    
}

getWind <- function(years, months, lat.southnorth, lon.westeast) {
  ## Retrieves & reshapes wind data by year, month
  
  u <- NCEP.gather(variable = 'uwnd.sig995', level = 'surface',
                   months.minmax = months, years.minmax = years,
                   lat.southnorth = lat.southnorth, lon.westeast = lon.westeast)

  v <- NCEP.gather(variable = 'vwnd.sig995', level = 'surface',
                   months.minmax = months, years.minmax = years,
                   lat.southnorth = lat.southnorth, lon.westeast = lon.westeast)

  
  umelt <- melt(u, varnames = c("lat", "long", "date"), value.name = "u")
  vmelt <- melt(v, varnames = c("lat", "long", "date"), value.name = "v")
  
  uv <- inner_join(umelt, vmelt, by = c("lat", "long", "date"))
  
  uv$long <- ifelse(uv$long > 180, uv$long - 360, uv$long) # Convert to negative notation
  
  ## Calculate speed and direction from u and v
  uv <- mutate(uv, speed = sqrt((u+v)^2),
               angle = atan2(v, u),
               date = ymd_h(date))

  return(uv)
    
}


radians2degrees <- function(x){
    ## Convert radians to degrees for windRose
    ((x + pi/2) * 180 / pi) %% 360
}
