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


##################################################
## Time Series
##################################################

## Warren, WI
lats2 <- c(45, 45)
longs2 <- c(-92.5, -92.5)


warren_wi <- getWind(years = c(1950, 2013), months = c(1, 12),
                     lat.southnorth = lats2, lon.westeast = longs2)
warren_wi$degrees <- radians2degrees(warren_wi$angle)
warren_wi2013 <- filter(warren_wi, date >= ymd("20130101"))




## Gulf of Mexico
lats3 <- c(15, 15)
longs3 <- c(-92.5, -92.5)


gulf <- getWind(years = c(1949, 2013), months = c(1, 12),
                lat.southnorth = lats3, lon.westeast = longs3)
gulf$degrees <- radians2degrees(gulf$angle)
gulf2013 <- filter(gulf, date >= ymd("20130101"))

save(may2014_1949, may2014_nov2013, nov2013_1948, may2014, may1949, nov2013, warren_wi, warren_wi2013, gulf, gulf2013, file = "data/wind-2014-1949-comparisons.Rda")
