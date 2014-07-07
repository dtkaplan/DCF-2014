Fetching and Reshaping Hurricane Sandy Wind Data
========================================================


We can explore wind data using a [large database created by the US government](http://www.esrl.noaa.gov/psd/data/gridded/data.ncep.reanalysis.html).  Like most web sites for government data, it's unclear how you would go about finding the exact data you want from the web site.

Fortunately, the `R` package `RNCEP` provides a convenient interface for querying this large database.


```r
require(RNCEP)
```

The function for gathering data is the rather generically named `NCEP.gather` function. This function is fairly complex and the only way to figure out how to use it is to peruse its help page:


```r
?NCEP.gather
```

From this page we discover that to get surface-level wind data, the variables we want are `uwnd.sig995` and `vwnd.sig995`.  We also can specify the month and year, which appears to go from 1948 to just a couple days ago. The `u` gives the longitudinal component of the wind in meters per second, while the `v` gives the latitudinal component.

To get the data we need to issue two separate queries to get each variable, and we need to download the data for an entire month since `NCEP.gather` does not allow you to specify whatday of the month. We here focus on an area on the Mid-Atlantic coast in the US, which is one of the areas most affected by the hurricane.


```r
lats <- c(35, 40)
longs <- c(-80, -75)

u <- NCEP.gather(variable = 'uwnd.sig995', level = 'surface',
                   months.minmax = c(10, 10), years.minmax = c(2011, 2011),
                   lat.southnorth = lats, lon.westeast = longs)
v <- NCEP.gather(variable = 'uwnd.sig995', level = 'surface',
                   months.minmax = c(10, 10), years.minmax = c(2011, 2011),
                   lat.southnorth = lats, lon.westeast = longs)
```





# Exploring and reshaping the data

What format does the data come back in?


```r
str(u)
```

```
##  num [1:3, 1:3, 1:124] 9.5 6.3 4.3 5.9 2.2 ...
##  - attr(*, "dimnames")=List of 3
##   ..$ : chr [1:3] "40" "37.5" "35"
##   ..$ : chr [1:3] "280" "282.5" "285"
##   ..$ : chr [1:124] "2011_10_01_00" "2011_10_01_06" "2011_10_01_12" "2011_10_01_18" ...
```

```r
head(u)
```

```
## [1] 9.5 6.3 4.3 5.9 2.2 3.5
```

The first line tells us that `u` is a 3-dimensional matrix, with 18 rows, 32 columns, and 124 of the third dimension.  From the *Value* section of `?NCEP.gather`, we know that the row names are the latitudes, the column names are the longitudes, and the 3rd-dimension names are the date. How the heck are we going to get this in a format we can plot?  Fortunately, simply calling `melt` function from the `reshape2` function breaks this down into a rectangular format quite nicely:


```r
require(reshape2)
```

```
## Loading required package: reshape2
```

```r
umelt.raw <- melt(u)
str(umelt.raw)
```

```
## 'data.frame':	1116 obs. of  4 variables:
##  $ Var1 : num  40 37.5 35 40 37.5 35 40 37.5 35 40 ...
##  $ Var2 : num  280 280 280 282 282 ...
##  $ Var3 : Factor w/ 124 levels "2011_10_01_00",..: 1 1 1 1 1 1 1 1 1 2 ...
##  $ value: num  9.5 6.3 4.3 5.9 2.2 ...
```

```r
head(umelt.raw)
```

```
##   Var1  Var2          Var3 value
## 1 40.0 280.0 2011_10_01_00   9.5
## 2 37.5 280.0 2011_10_01_00   6.3
## 3 35.0 280.0 2011_10_01_00   4.3
## 4 40.0 282.5 2011_10_01_00   5.9
## 5 37.5 282.5 2011_10_01_00   2.2
## 6 35.0 282.5 2011_10_01_00   3.5
```

Now, each row is one unique combination of latitude, longitude, and date, and the value at that combination. We can provide slightly nicer output by telling `melt` what we want to name our columns.  We now do this for both `u` and `v`.


```r
umelt <- melt(u, varnames = c("lat", "long", "date"), value.name = "u")
str(umelt)
```

```
## 'data.frame':	1116 obs. of  4 variables:
##  $ lat : num  40 37.5 35 40 37.5 35 40 37.5 35 40 ...
##  $ long: num  280 280 280 282 282 ...
##  $ date: Factor w/ 124 levels "2011_10_01_00",..: 1 1 1 1 1 1 1 1 1 2 ...
##  $ u   : num  9.5 6.3 4.3 5.9 2.2 ...
```

```r
head(umelt)
```

```
##    lat  long          date   u
## 1 40.0 280.0 2011_10_01_00 9.5
## 2 37.5 280.0 2011_10_01_00 6.3
## 3 35.0 280.0 2011_10_01_00 4.3
## 4 40.0 282.5 2011_10_01_00 5.9
## 5 37.5 282.5 2011_10_01_00 2.2
## 6 35.0 282.5 2011_10_01_00 3.5
```

```r
vmelt <- melt(v, varnames = c("lat", "long", "date"), value.name = "v")
str(vmelt)
```

```
## 'data.frame':	1116 obs. of  4 variables:
##  $ lat : num  40 37.5 35 40 37.5 35 40 37.5 35 40 ...
##  $ long: num  280 280 280 282 282 ...
##  $ date: Factor w/ 124 levels "2011_10_01_00",..: 1 1 1 1 1 1 1 1 1 2 ...
##  $ v   : num  9.5 6.3 4.3 5.9 2.2 ...
```

```r
head(vmelt)
```

```
##    lat  long          date   v
## 1 40.0 280.0 2011_10_01_00 9.5
## 2 37.5 280.0 2011_10_01_00 6.3
## 3 35.0 280.0 2011_10_01_00 4.3
## 4 40.0 282.5 2011_10_01_00 5.9
## 5 37.5 282.5 2011_10_01_00 2.2
## 6 35.0 282.5 2011_10_01_00 3.5
```

# Merging the data

But, we're going to want to combine information about u and v in order to make our plot.  So, we want these values side by side.

We expect that we have one in both datasets for each unique combination of latitude, longitude, date/time. But, we could be wrong, there may be some missing values.  If we for some reason only have "u", "v" is useless because we don't have enough information to draw the direction based on just one component alone.

Therefore, we want to line up all values in both datasets where latitude, longitude, and date/time are equal, discarding any values where a combination exists in one data set but not another.  This is called an *inner join*, and we can simply use the function `inner_join` from the `dplyr` package to accomplish this. All we need to do is specify the variables that we are using to join using the `by =` argument:


```r
require(dplyr)
```

```
## Loading required package: dplyr
## 
## Attaching package: 'dplyr'
## 
## The following objects are masked from 'package:stats':
## 
##     filter, lag
## 
## The following objects are masked from 'package:base':
## 
##     intersect, setdiff, setequal, union
```

```r
uv <- inner_join(umelt, vmelt, by = c("lat", "long", "date"))
str(uv)
```

```
## 'data.frame':	1116 obs. of  5 variables:
##  $ lat : num  40 37.5 35 40 37.5 35 40 37.5 35 40 ...
##  $ long: num  280 280 280 282 282 ...
##  $ date: Factor w/ 124 levels "2011_10_01_00",..: 1 1 1 1 1 1 1 1 1 2 ...
##  $ u   : num  9.5 6.3 4.3 5.9 2.2 ...
##  $ v   : num  9.5 6.3 4.3 5.9 2.2 ...
```

```r
head(uv)
```

```
##    lat  long          date   u   v
## 1 40.0 280.0 2011_10_01_00 9.5 9.5
## 2 37.5 280.0 2011_10_01_00 6.3 6.3
## 3 35.0 280.0 2011_10_01_00 4.3 4.3
## 4 40.0 282.5 2011_10_01_00 5.9 5.9
## 5 37.5 282.5 2011_10_01_00 2.2 2.2
## 6 35.0 282.5 2011_10_01_00 3.5 3.5
```

# Tweaks: correct formats, calculate speed & direction

This data is almost `ggplot2`-ready, but notice the format of the longitudes.  `ggplot2` wants the longitudes to go between –180° and 180°, whereas this data gives the negative longitudes in a positive format.  So, we need to convert all the longitudes that are above 180° to the negative format by subtracting 360°. (In this case, all the longitudes are negative, so this is what we do below.)

Also, we want to calculate the speed and direction, which we can do by way of trigonometry.

Finally, we convert the string given by NCEP into an R date format using the `ymd_h()` function from the `lubridate` package.

We do all of this in a single `mutate` command.


```r
library(lubridate)
  uv_2 <- mutate(uv, long = long - 360,
               speed = sqrt((u+v)^2),
               angle = atan2(v, u),
               date = ymd_h(date))

str(uv_2)
```

```
## 'data.frame':	1116 obs. of  7 variables:
##  $ lat  : num  40 37.5 35 40 37.5 35 40 37.5 35 40 ...
##  $ long : num  -80 -80 -80 -77.5 -77.5 -77.5 -75 -75 -75 -80 ...
##  $ date : POSIXct, format: "2011-10-01 00:00:00" "2011-10-01 00:00:00" ...
##  $ u    : num  9.5 6.3 4.3 5.9 2.2 ...
##  $ v    : num  9.5 6.3 4.3 5.9 2.2 ...
##  $ speed: num  19 12.6 8.6 11.8 4.4 ...
##  $ angle: num  0.785 0.785 0.785 0.785 0.785 ...
```

(If we had positive longitudes, we would need to alter this command to only subtract 180 from the longitudes that are over 180.)

# Filtering the data

We now have too many dates!  You can see all the unique values for a variable using the `unique` function:


```r
unique(uv_2$date)
```

```
##   [1] "2011-10-01 00:00:00 UTC" "2011-10-01 06:00:00 UTC"
##   [3] "2011-10-01 12:00:00 UTC" "2011-10-01 18:00:00 UTC"
##   [5] "2011-10-02 00:00:00 UTC" "2011-10-02 06:00:00 UTC"
##   [7] "2011-10-02 12:00:00 UTC" "2011-10-02 18:00:00 UTC"
##   [9] "2011-10-03 00:00:00 UTC" "2011-10-03 06:00:00 UTC"
##  [11] "2011-10-03 12:00:00 UTC" "2011-10-03 18:00:00 UTC"
##  [13] "2011-10-04 00:00:00 UTC" "2011-10-04 06:00:00 UTC"
##  [15] "2011-10-04 12:00:00 UTC" "2011-10-04 18:00:00 UTC"
##  [17] "2011-10-05 00:00:00 UTC" "2011-10-05 06:00:00 UTC"
##  [19] "2011-10-05 12:00:00 UTC" "2011-10-05 18:00:00 UTC"
##  [21] "2011-10-06 00:00:00 UTC" "2011-10-06 06:00:00 UTC"
##  [23] "2011-10-06 12:00:00 UTC" "2011-10-06 18:00:00 UTC"
##  [25] "2011-10-07 00:00:00 UTC" "2011-10-07 06:00:00 UTC"
##  [27] "2011-10-07 12:00:00 UTC" "2011-10-07 18:00:00 UTC"
##  [29] "2011-10-08 00:00:00 UTC" "2011-10-08 06:00:00 UTC"
##  [31] "2011-10-08 12:00:00 UTC" "2011-10-08 18:00:00 UTC"
##  [33] "2011-10-09 00:00:00 UTC" "2011-10-09 06:00:00 UTC"
##  [35] "2011-10-09 12:00:00 UTC" "2011-10-09 18:00:00 UTC"
##  [37] "2011-10-10 00:00:00 UTC" "2011-10-10 06:00:00 UTC"
##  [39] "2011-10-10 12:00:00 UTC" "2011-10-10 18:00:00 UTC"
##  [41] "2011-10-11 00:00:00 UTC" "2011-10-11 06:00:00 UTC"
##  [43] "2011-10-11 12:00:00 UTC" "2011-10-11 18:00:00 UTC"
##  [45] "2011-10-12 00:00:00 UTC" "2011-10-12 06:00:00 UTC"
##  [47] "2011-10-12 12:00:00 UTC" "2011-10-12 18:00:00 UTC"
##  [49] "2011-10-13 00:00:00 UTC" "2011-10-13 06:00:00 UTC"
##  [51] "2011-10-13 12:00:00 UTC" "2011-10-13 18:00:00 UTC"
##  [53] "2011-10-14 00:00:00 UTC" "2011-10-14 06:00:00 UTC"
##  [55] "2011-10-14 12:00:00 UTC" "2011-10-14 18:00:00 UTC"
##  [57] "2011-10-15 00:00:00 UTC" "2011-10-15 06:00:00 UTC"
##  [59] "2011-10-15 12:00:00 UTC" "2011-10-15 18:00:00 UTC"
##  [61] "2011-10-16 00:00:00 UTC" "2011-10-16 06:00:00 UTC"
##  [63] "2011-10-16 12:00:00 UTC" "2011-10-16 18:00:00 UTC"
##  [65] "2011-10-17 00:00:00 UTC" "2011-10-17 06:00:00 UTC"
##  [67] "2011-10-17 12:00:00 UTC" "2011-10-17 18:00:00 UTC"
##  [69] "2011-10-18 00:00:00 UTC" "2011-10-18 06:00:00 UTC"
##  [71] "2011-10-18 12:00:00 UTC" "2011-10-18 18:00:00 UTC"
##  [73] "2011-10-19 00:00:00 UTC" "2011-10-19 06:00:00 UTC"
##  [75] "2011-10-19 12:00:00 UTC" "2011-10-19 18:00:00 UTC"
##  [77] "2011-10-20 00:00:00 UTC" "2011-10-20 06:00:00 UTC"
##  [79] "2011-10-20 12:00:00 UTC" "2011-10-20 18:00:00 UTC"
##  [81] "2011-10-21 00:00:00 UTC" "2011-10-21 06:00:00 UTC"
##  [83] "2011-10-21 12:00:00 UTC" "2011-10-21 18:00:00 UTC"
##  [85] "2011-10-22 00:00:00 UTC" "2011-10-22 06:00:00 UTC"
##  [87] "2011-10-22 12:00:00 UTC" "2011-10-22 18:00:00 UTC"
##  [89] "2011-10-23 00:00:00 UTC" "2011-10-23 06:00:00 UTC"
##  [91] "2011-10-23 12:00:00 UTC" "2011-10-23 18:00:00 UTC"
##  [93] "2011-10-24 00:00:00 UTC" "2011-10-24 06:00:00 UTC"
##  [95] "2011-10-24 12:00:00 UTC" "2011-10-24 18:00:00 UTC"
##  [97] "2011-10-25 00:00:00 UTC" "2011-10-25 06:00:00 UTC"
##  [99] "2011-10-25 12:00:00 UTC" "2011-10-25 18:00:00 UTC"
## [101] "2011-10-26 00:00:00 UTC" "2011-10-26 06:00:00 UTC"
## [103] "2011-10-26 12:00:00 UTC" "2011-10-26 18:00:00 UTC"
## [105] "2011-10-27 00:00:00 UTC" "2011-10-27 06:00:00 UTC"
## [107] "2011-10-27 12:00:00 UTC" "2011-10-27 18:00:00 UTC"
## [109] "2011-10-28 00:00:00 UTC" "2011-10-28 06:00:00 UTC"
## [111] "2011-10-28 12:00:00 UTC" "2011-10-28 18:00:00 UTC"
## [113] "2011-10-29 00:00:00 UTC" "2011-10-29 06:00:00 UTC"
## [115] "2011-10-29 12:00:00 UTC" "2011-10-29 18:00:00 UTC"
## [117] "2011-10-30 00:00:00 UTC" "2011-10-30 06:00:00 UTC"
## [119] "2011-10-30 12:00:00 UTC" "2011-10-30 18:00:00 UTC"
## [121] "2011-10-31 00:00:00 UTC" "2011-10-31 06:00:00 UTC"
## [123] "2011-10-31 12:00:00 UTC" "2011-10-31 18:00:00 UTC"
```

This is all measurements from October, but we only want the final three days.  We can get just these three days using the `filter` command to specify that we want only the days that are after or equal to the 28th.


```r
uvtrim <- filter(uv_2, date >= ymd("2011-10-28"))

unique(uvtrim$date)
```

```
##  [1] "2011-10-28 00:00:00 UTC" "2011-10-28 06:00:00 UTC"
##  [3] "2011-10-28 12:00:00 UTC" "2011-10-28 18:00:00 UTC"
##  [5] "2011-10-29 00:00:00 UTC" "2011-10-29 06:00:00 UTC"
##  [7] "2011-10-29 12:00:00 UTC" "2011-10-29 18:00:00 UTC"
##  [9] "2011-10-30 00:00:00 UTC" "2011-10-30 06:00:00 UTC"
## [11] "2011-10-30 12:00:00 UTC" "2011-10-30 18:00:00 UTC"
## [13] "2011-10-31 00:00:00 UTC" "2011-10-31 06:00:00 UTC"
## [15] "2011-10-31 12:00:00 UTC" "2011-10-31 18:00:00 UTC"
```

Now, those are the values in our dataset.  Success!
