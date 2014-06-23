library(ggplot2)
library(grid)
library(proto)

GeomArrow <- proto(ggplot2:::Geom, {
    ## Based on GeomSegment
    ## Influenced by defunct `geom_field`: https://github.com/hadley/ggplot2/wiki/Creating-a-new-geom
    ## Alpha channel does not work, because `alpha()` function raises an error

    draw <- function(., data, scales, coordinates, arrow = NULL,
                     lineend = "butt", na.rm = FALSE, ...) {

        data <- ggplot2:::remove_missing(data, na.rm = na.rm,
                                         c("x", "y", "angle", "length", "linetype", "size", "shape"),
                                         name = "geom_arrow")

        ## Calculate and add on "xend" and "yend"
        data$xend <- data$x + data$length*cos(data$angle)
        data$yend <- data$y + data$length*sin(data$angle)
        minsize <- which.min(data$length)

        if (is.linear(coordinates)) {
            return(with(coord_transform(coordinates, data, scales), {
                
                arrowsize <- with(data.frame(x, xend, y, yend)[minsize],
                                  sqrt((x-xend)^2 + (y-yend)^2))
                segmentsGrob(x, y, xend, yend, default.units="native",
                             gp = gpar(col= colour, fill = colour,
                                 lwd=size * ggplot2:::.pt, lty=linetype, lineend = lineend),
                             arrow = arrow(length = unit(arrowsize, "npc")))

            }
                        ))
            
        } else return(zeroGrob())

    }

    objname <- "arrow" # name of the geom in lowercase. Must correspond to GeomArrow.
    desc <- "Single line segments"

    default_stat <- function(.) ggplot2:::StatIdentity
    required_aes <- c("x", "y") 
    default_aes <- function(.) aes(colour="black", angle=pi/4, length=1, size=0.5, linetype=1)
    guide_geom <- function(.) "path"

})

geom_arrow <- function (mapping = NULL, data = NULL, stat = "identity",
                        position = "identity", arrow = NULL, lineend = "butt", na.rm = FALSE, ...) {

    GeomArrow$new(mapping = mapping, data = data, stat = stat,
                  position = position, arrow = arrow, lineend = lineend, na.rm = na.rm, ...)
}



