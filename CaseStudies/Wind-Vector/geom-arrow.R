library(ggplot2)
library(grid)
library(proto)

GeomField <- proto(ggplot2:::Geom, {

    draw <- function(., data, scales, coordinates, arrow = NULL,
                     lineend = "butt", na.rm = FALSE, ...) {

        data <- ggplot2:::remove_missing(data, na.rm = na.rm,
                                         c("x", "y", "angle", "length", "linetype", "size", "shape"),
                                         name = "geom_field")

        ## Calculate and add on "xend" and "yend"
        data$xend <- data$x + data$length*cos(data$angle)
        data$yend <- data$y + data$length*sin(data$angle) 

        if (is.linear(coordinates)) {
            return(with(coord_transform(coordinates, data, scales), {
                segmentsGrob(x, y, xend, yend, default.units="native",
                                     ## gp = gpar(col=alpha(colour, alpha), fill = alpha(colour, alpha),
                                     ##     lwd=size * .pt, lty=linetype, lineend = lineend),
                                     arrow = arrow)
            }
                        ))
            
        } else return(zeroGrob())

    }
    
    objname <- "field" # name of the geom in lowercase. Must correspond to GeomField.
    desc <- "Single line segments"
    
    default_stat <- function(.) ggplot2:::StatIdentity
    required_aes <- c("x", "y") 
    default_aes <- function(.) aes(colour="black", angle=pi/4, length=1, size=0.5, linetype=1)
    guide_geom <- function(.) "path"
    
})

geom_field <- function (mapping = NULL, data = NULL, stat = "identity",
                        position = "identity", arrow = NULL, lineend = "butt", na.rm = FALSE, ...) {
    
    GeomField$new(mapping = mapping, data = data, stat = stat,
                  position = position, arrow = arrow, lineend = lineend, na.rm = na.rm, ...)
}



