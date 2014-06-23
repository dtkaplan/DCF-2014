library(ggplot2)
library(grid)
library(proto)

fieldGrob <- function(x, y, angle, length, size, 
  colour="black", linetype=1, arrow=NULL){
	
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
	        arrow = arrow
               )
}



g <-
fieldGrob(0.5, 0.5, pi/6, 0.2,1,  col="blue")
pushViewport(vp=viewport(width=1, height=1))
grid.draw(g)



GeomField <- proto(Geom, {
  draw <- function(., data, scales, coordinates, ...) 
{
	# draw the field grobs in relation to the data
}
 
  draw_legend <- function(., data, ...) {
    # show a grob in the key that represents the data
  }
 
  objname <- "field" # name of the geom in lowercase. Must correspond to GeomField.
  desc <- "Single line segments"
 
  default_stat <- function(.) StatIdentity
  required_aes <- c("x", "y", "angle", "length") 
  default_aes <- function(.) aes(colour="black", angle=pi/4, length=1, size=0.5, linetype=1)
  guide_geom <- function(.) "field"
 
  icon <- function(.) # a grob representing the geom for the webpage
 
  desc_params <- list( # description of the (optional) parameters of draw
	 )
 
  seealso <- list(
    geom_path = GeomPath$desc,
    geom_segment = GeomPath$desc,
    geom_line = GeomLine$desc
  )
 
  examples <- function(.) {
    # examples of the geom in use
  }
  
})



draw <- function(., data, scales, coordinates, arrow=NULL, ...) {
  with(coordinates$transform(data, scales), 
        fieldGrob(x, y, angle, length, size, 
        col=colour, linetype, arrow)
      )    
  }



  draw_legend <- function(., data, ...) {
    data <- aesdefaults(data, .$default_aes(), list(...))
 
    with(data, ggname(.$my_name(),
		fieldGrob(0.5, 0.5, angle, length, size,  col=colour, linetype) )
	)
  }



geom_field <- GeomField$build_accessor()



ScaleLength <- proto(ScaleContinuous, expr={
  doc <- TRUE
  common <- NULL
  
  new <- function(., name=NULL, limits=NULL, breaks=NULL, labels=NULL, trans = NULL, to = NULL) {
    .super$new(., name=name, limits=limits, breaks=breaks, labels=labels, trans=trans, variable = "length", to = to)
  }
  
  map <- function(., values) {
    # rescale(values, .$to, .$input_set())
   values
  }
  output_breaks <- function(.) .$map(.$input_breaks())
  
  objname <- "length"
  desc <- "Length scale for continuous variable"
  
})



ScaleLengthDiscrete <- proto(ScaleDiscrete, expr={
  common <- NULL
  objname <- "length_discrete"
  .input <- .output <- "length"
  desc <- "Length scale for discrete variables"
  doc <- FALSE
 
  max_levels <- function(.) 11
  output_set <- function(.) seq(1, 5, length=11)
 
})



 scale_length <- ScaleLength$build_accessor()
 scale_length_discrete <- ScaleLengthDiscrete$build_accessor()



scale_length_manual <- ScaleManual$build_accessor(list(variable = "\"length\""))


