library(reshape2)
library(dplyr)
library(RNCEP)

getWind <- function(year, month, day = NULL, lat.southnorth, lon.westeast) {
  ## Retrieves & reshapes wind data by year, month, [and day]
  
  u <- NCEP.gather(variable = 'uwnd.sig995', level = 'surface',
                   months.minmax = c(month, month), years.minmax = c(year, year),
                   lat.southnorth = lat.southnorth, lon.westeast = lon.westeast)
  
  v <- NCEP.gather(variable = 'vwnd.sig995', level = 'surface',
                   months.minmax = c(month, month), years.minmax = c(year, year),
                   lat.southnorth = lat.southnorth, lon.westeast = lon.westeast)
  
  umelt <- melt(u, varnames = c("lat", "long", "datestring"), value.name = "u")
  vmelt <- melt(v2000, varnames = c("lat", "long", "datestring"), value.name = "v")
  
  uv <- inner_join(umelt, vmelt, by = c("lat", "long", "datestring"))
  
  uv$long <- uv$long - 360
  
  return(uv)
    
}

