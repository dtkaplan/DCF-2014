## These cover continental US down to the top tip of South America
lats <- c(8, 49)
longs <- c(-140, -63)

source("functions.R")

##################################################
## Maps
##################################################

may2014 <- getWindDay(2014, 5, 30, 12, lat.southnorth=lats, lon.westeast=longs)
may1949 <- getWindDay(1949, 5, 30, 12, lat.southnorth=lats, lon.westeast=longs)

nov2013 <- getWindDay(2013, 11, 30, 12, lat.southnorth=lats, lon.westeast=longs)
nov1948 <- getWindDay(1948, 11, 30, 12, lat.southnorth=lats, lon.westeast=longs)

may2014_1949 <- rbind(may2014, may1949)
may2014_nov2013 <- rbind(may2014, nov2013)
nov2013_1948 <- rbind(nov2013, nov1948)

save(may2014_1949, may2014_nov2013, nov2013_1948, may2014, may1949, nov2013, file = "data/wind-2014-1949-comparisons.Rda")


##################################################
## Time Series
##################################################

## Warren, WI
lats2 <- c(45, 45)
longs2 <- c(-92.5, -92.5)


warren_wi <- getWind(years = c(1949, 2014), months = c(5, 5),
                     lat.southnorth = lats2, lon.westeast = longs2)

