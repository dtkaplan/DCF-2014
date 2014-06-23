library(ggplot2)
library(grid)
library(proto)

fieldGrob <- function(x, y, angle, length, size = 1, 
                      colour="black", linetype=1, arrow=NULL, ...){
    
    segmentsGrob(
        x0= x - 0.5*length*cos(angle), 
        y0= y - 0.5*length*sin(angle),
        x1= x + 0.5*length*cos(angle), 
        y1= y + 0.5*length*sin(angle), 
        default.units="native",
        gp = gpar(col=colour, 
            lwd=size*ggplot2:::.pt, 
            lty=linetype, 
            lineend = "butt"),
        arrow = arrow(length = unit(length*4,"cm")),
        )
}



## g <-
## fieldGrob(0.5, 0.5, pi/6, 0.2,1,  col="blue", arrow = T)
## pushViewport(vp=viewport(width=1, height=1))
## grid.draw(g)


GeomField <- proto(ggplot2:::Geom, {

    draw <- function(., data, scales, coordinates, arrow = NULL,
                     lineend = "butt", na.rm = FALSE, ...) {

        data <- ggplot2:::remove_missing(data, na.rm = na.rm,
                               c("x", "y", "angle", "length", "linetype", "size", "shape"),
                               name = "geom_field")

#        if (empty(data)) return(zeroGrob())

        if (is.linear(coordinates)) {
            return(with(coord_transform(coordinates, data, scales),
                        fieldGrob(x, y, angle, length)))
        }

        data$group <- 1:nrow(data)
        starts <- subset(data, select = c(-xend, -yend))
        ends <- ggplot2:::rename(subset(data, select = c(-x, -y)), c("xend" = "x", "yend" = "y"),
                       warn_missing = FALSE)

        pieces <- rbind(starts, ends)
        pieces <- pieces[order(pieces$group),]

        ggplot2:::GeomPath$draw_groups(pieces, scales, coordinates, arrow = arrow, ...)
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



scale_length <- function(..., expand = waiver()) {
    continuous_scale("length", "length_c", identity, ...,
                     expand = expand, guide = "none")
}


scale_length_manual <- function(..., values) {
    manual_scale(length, values, ...)
}



