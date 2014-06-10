u <- NCEP.gather(variable = 'uwnd.sig995', level = 'surface',
                 months.minmax = c(5, 5), years.minmax = c(2014, 2014),
                 lat.southnorth = c(8, 49), lon.westeast = c(-140, -63))

v <- NCEP.gather(variable = 'vwnd.sig995', level = 'surface',
                 months.minmax = c(5, 5), years.minmax = c(2014, 2014),
                 lat.southnorth = c(8, 49), lon.westeast = c(-140, -63))

save(u, v, file = "data/uv-2014-5-30.Rda")
