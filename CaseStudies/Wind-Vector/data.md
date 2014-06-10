Fetching and Reshaping the Data
========================================================


We can explore wind data using a [large database created by the US government](http://www.esrl.noaa.gov/psd/data/gridded/data.ncep.reanalysis.html).  Like most web sites for government data, it's unclear how you would go about finding the exact data you want from the web site.

In this case, we want the wind direction and speeds for May 30, 2014. We want to look at a region including the continental US, Mexico, and Central America, and the ocean areas nearby.  This corresponds to latitudes 8° to 49° and longitudes –140° to –163°.

Fortunately, the `R` package `RNCEP` provides a convenient interface for querying this large database.


```r
require(RNCEP)
```

The function for gathering data is the rather generically named `NCEP.gather` function. This function is fairly complex and the only way to figure out how to use it is to peruse its help page:


```r
?NCEP.gather
```

From this page we discover that to get surface-level wind data, the variables we want are `uwnd.sig995` and `vwnd.sig995`.  We also can specify the month and year, which appears to go from 1948 to just a couple days ago. The `u` gives the longitudinal component of the wind in meters per second, while the `v` gives the latitudinal component.

To get the data we need to issue two separate queries to get each variable, and we need to download the data for an entire month since `NCEP.gather` does not allow you to specify whatday of the month.


```r
u <- NCEP.gather(variable = 'uwnd.sig995', level = 'surface',
                   months.minmax = c(5, 5), years.minmax = c(2014, 2014),
                   lat.southnorth = c(8, 49), lon.westeast = c(-140, -63))
  
v <- NCEP.gather(variable = 'vwnd.sig995', level = 'surface',
                   months.minmax = c(5, 5), years.minmax = c(2014, 2014),
                   lat.southnorth = c(8, 49), lon.westeast = c(-140, -63))
```



# Exploring and reshaping the data

What format does the data come back in?


```r
str(u)
```

```
##  num [1:18, 1:32, 1:124] -7.5 -6.8 -6.2 -5.4 -3.3 ...
##  - attr(*, "dimnames")=List of 3
##   ..$ : chr [1:18] "50" "47.5" "45" "42.5" ...
##   ..$ : chr [1:32] "220" "222.5" "225" "227.5" ...
##   ..$ : chr [1:124] "2014_05_01_00" "2014_05_01_06" "2014_05_01_12" "2014_05_01_18" ...
```

```r
head(u)
```

```
## [1] -7.5 -6.8 -6.2 -5.4 -3.3 -0.9
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
## 'data.frame':	71424 obs. of  4 variables:
##  $ Var1 : num  50 47.5 45 42.5 40 37.5 35 32.5 30 27.5 ...
##  $ Var2 : num  220 220 220 220 220 220 220 220 220 220 ...
##  $ Var3 : Factor w/ 124 levels "2014_05_01_00",..: 1 1 1 1 1 1 1 1 1 1 ...
##  $ value: num  -7.5 -6.8 -6.2 -5.4 -3.3 ...
```

```r
head(umelt.raw)
```

```
##   Var1 Var2          Var3 value
## 1 50.0  220 2014_05_01_00  -7.5
## 2 47.5  220 2014_05_01_00  -6.8
## 3 45.0  220 2014_05_01_00  -6.2
## 4 42.5  220 2014_05_01_00  -5.4
## 5 40.0  220 2014_05_01_00  -3.3
## 6 37.5  220 2014_05_01_00  -0.9
```

Now, each row is one unique combination of latitude, longitude, and date, and the value at that combination. We can provide slightly nicer output by telling `melt` what we want to name our columns.  We now do this for both `u` and `v`.


```r
umelt <- melt(u, varnames = c("lat", "long", "datestring"), value.name = "u")
str(umelt)
```

```
## 'data.frame':	71424 obs. of  4 variables:
##  $ lat       : num  50 47.5 45 42.5 40 37.5 35 32.5 30 27.5 ...
##  $ long      : num  220 220 220 220 220 220 220 220 220 220 ...
##  $ datestring: Factor w/ 124 levels "2014_05_01_00",..: 1 1 1 1 1 1 1 1 1 1 ...
##  $ u         : num  -7.5 -6.8 -6.2 -5.4 -3.3 ...
```

```r
head(umelt)
```

```
##    lat long    datestring    u
## 1 50.0  220 2014_05_01_00 -7.5
## 2 47.5  220 2014_05_01_00 -6.8
## 3 45.0  220 2014_05_01_00 -6.2
## 4 42.5  220 2014_05_01_00 -5.4
## 5 40.0  220 2014_05_01_00 -3.3
## 6 37.5  220 2014_05_01_00 -0.9
```

```r
vmelt <- melt(v, varnames = c("lat", "long", "datestring"), value.name = "v")
str(vmelt)
```

```
## 'data.frame':	71424 obs. of  4 variables:
##  $ lat       : num  50 47.5 45 42.5 40 37.5 35 32.5 30 27.5 ...
##  $ long      : num  220 220 220 220 220 220 220 220 220 220 ...
##  $ datestring: Factor w/ 124 levels "2014_05_01_00",..: 1 1 1 1 1 1 1 1 1 1 ...
##  $ v         : num  -12.5 -12.5 -11 -5.8 -1.5 ...
```

```r
head(vmelt)
```

```
##    lat long    datestring     v
## 1 50.0  220 2014_05_01_00 -12.5
## 2 47.5  220 2014_05_01_00 -12.5
## 3 45.0  220 2014_05_01_00 -11.0
## 4 42.5  220 2014_05_01_00  -5.8
## 5 40.0  220 2014_05_01_00  -1.5
## 6 37.5  220 2014_05_01_00   1.1
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
uv <- inner_join(umelt, vmelt, by = c("lat", "long", "datestring"))
str(uv)
```

```
## 'data.frame':	71424 obs. of  5 variables:
##  $ lat       : num  50 47.5 45 42.5 40 37.5 35 32.5 30 27.5 ...
##  $ long      : num  220 220 220 220 220 220 220 220 220 220 ...
##  $ datestring: Factor w/ 124 levels "2014_05_01_00",..: 1 1 1 1 1 1 1 1 1 1 ...
##  $ u         : num  -7.5 -6.8 -6.2 -5.4 -3.3 ...
##  $ v         : num  -12.5 -12.5 -11 -5.8 -1.5 ...
```

```r
head(uv)
```

```
##    lat long    datestring    u     v
## 1 50.0  220 2014_05_01_00 -7.5 -12.5
## 2 47.5  220 2014_05_01_00 -6.8 -12.5
## 3 45.0  220 2014_05_01_00 -6.2 -11.0
## 4 42.5  220 2014_05_01_00 -5.4  -5.8
## 5 40.0  220 2014_05_01_00 -3.3  -1.5
## 6 37.5  220 2014_05_01_00 -0.9   1.1
```

# Filtering the data

We now have too many dates!  You can see all the unique values for a variable using the `unique` function:


```r
unique(uv$datestring)
```

```
##   [1] 2014_05_01_00 2014_05_01_06 2014_05_01_12 2014_05_01_18 2014_05_02_00
##   [6] 2014_05_02_06 2014_05_02_12 2014_05_02_18 2014_05_03_00 2014_05_03_06
##  [11] 2014_05_03_12 2014_05_03_18 2014_05_04_00 2014_05_04_06 2014_05_04_12
##  [16] 2014_05_04_18 2014_05_05_00 2014_05_05_06 2014_05_05_12 2014_05_05_18
##  [21] 2014_05_06_00 2014_05_06_06 2014_05_06_12 2014_05_06_18 2014_05_07_00
##  [26] 2014_05_07_06 2014_05_07_12 2014_05_07_18 2014_05_08_00 2014_05_08_06
##  [31] 2014_05_08_12 2014_05_08_18 2014_05_09_00 2014_05_09_06 2014_05_09_12
##  [36] 2014_05_09_18 2014_05_10_00 2014_05_10_06 2014_05_10_12 2014_05_10_18
##  [41] 2014_05_11_00 2014_05_11_06 2014_05_11_12 2014_05_11_18 2014_05_12_00
##  [46] 2014_05_12_06 2014_05_12_12 2014_05_12_18 2014_05_13_00 2014_05_13_06
##  [51] 2014_05_13_12 2014_05_13_18 2014_05_14_00 2014_05_14_06 2014_05_14_12
##  [56] 2014_05_14_18 2014_05_15_00 2014_05_15_06 2014_05_15_12 2014_05_15_18
##  [61] 2014_05_16_00 2014_05_16_06 2014_05_16_12 2014_05_16_18 2014_05_17_00
##  [66] 2014_05_17_06 2014_05_17_12 2014_05_17_18 2014_05_18_00 2014_05_18_06
##  [71] 2014_05_18_12 2014_05_18_18 2014_05_19_00 2014_05_19_06 2014_05_19_12
##  [76] 2014_05_19_18 2014_05_20_00 2014_05_20_06 2014_05_20_12 2014_05_20_18
##  [81] 2014_05_21_00 2014_05_21_06 2014_05_21_12 2014_05_21_18 2014_05_22_00
##  [86] 2014_05_22_06 2014_05_22_12 2014_05_22_18 2014_05_23_00 2014_05_23_06
##  [91] 2014_05_23_12 2014_05_23_18 2014_05_24_00 2014_05_24_06 2014_05_24_12
##  [96] 2014_05_24_18 2014_05_25_00 2014_05_25_06 2014_05_25_12 2014_05_25_18
## [101] 2014_05_26_00 2014_05_26_06 2014_05_26_12 2014_05_26_18 2014_05_27_00
## [106] 2014_05_27_06 2014_05_27_12 2014_05_27_18 2014_05_28_00 2014_05_28_06
## [111] 2014_05_28_12 2014_05_28_18 2014_05_29_00 2014_05_29_06 2014_05_29_12
## [116] 2014_05_29_18 2014_05_30_00 2014_05_30_06 2014_05_30_12 2014_05_30_18
## [121] 2014_05_31_00 2014_05_31_06 2014_05_31_12 2014_05_31_18
## 124 Levels: 2014_05_01_00 2014_05_01_06 2014_05_01_12 ... 2014_05_31_18
```

Amongst these results, we can see the date and time we actually want: May 30 at noon is `"2014_05_30_12"`. We can trim this down to just this date and time using the `filter` command from `dplyr`. The first argument is the original data frame, and the second is the criteria we want to filter on; we want the only the values of the data where the variable `datestring` equals `"2014_05_30_12"`.


```r
uvtrim <- filter(uv, datestring %in% "2014_05_30_12")

unique(uvtrim$datestring)
```

```
## [1] 2014_05_30_12
## 124 Levels: 2014_05_01_00 2014_05_01_06 2014_05_01_12 ... 2014_05_31_18
```

Now that is the only unique value in our dataset.  Success!

# Correcting the longitude format

This data is almost `ggplot2`-ready, but notice the format of the longitudes.  `ggplot2` wants the longitudes to go between –180° and 180°, whereas this data gives the negative longitudes in a positive format.  So, we need to convert all the longitudes that are above 180° to the negative format by subtracting 360°.

All the longitudes are negative in the Western hemisphere, so in this case we can just subtract from the lot:


```r
uvtrim$long <- uvtrim$long - 360
```

(If we had positive longitudes, we would need to alter this command to only subtract 180 from the longitudes that are over 180.)

