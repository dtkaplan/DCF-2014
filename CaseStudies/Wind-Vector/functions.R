library(reshape2)
library(dplyr)
library(RNCEP)

getWindDay <- function(year, month, day, hour = c(0, 6, 12, 18), 
                    lat.southnorth, lon.westeast) {
  ## Retrieves & reshapes wind data by year, month, day, hour
  
  chosenDay <- sprintf("%d_%02d_%02d_%02d", year, month, day, hour)
  
  if(length(chosenDay) > 1) stop("All of year, month, day, and hour must be specified and of length 1")
  
  
  u <- NCEP.gather(variable = 'uwnd.sig995', level = 'surface',
                   months.minmax = c(month, month), years.minmax = c(year, year),
                   lat.southnorth = lat.southnorth, lon.westeast = lon.westeast)
  
  v <- NCEP.gather(variable = 'vwnd.sig995', level = 'surface',
                   months.minmax = c(month, month), years.minmax = c(year, year),
                   lat.southnorth = lat.southnorth, lon.westeast = lon.westeast)
  
  umelt <- melt(u, varnames = c("lat", "long", "datestring"), value.name = "u")
  vmelt <- melt(v, varnames = c("lat", "long", "datestring"), value.name = "v")
  
  uv <- inner_join(umelt, vmelt, by = c("lat", "long", "datestring"))
  
  uv$long <- ifelse(uv$long > 180, uv$long - 360, uv$long) # Convert to negative notation
  
  ## Calculate speed and direction from u and v
  uv <- mutate(may2014, speed = sqrt((u+v)^2),
         angle = atan2(v, u))

  uv_filt <- filter(uv, datestring %in% chosenDay )  
  
  return(uv_filt)
    
}

