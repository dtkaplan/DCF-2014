
require(RColorBrewer)

makeExampleData <- function(n=5, seed=0) {
  if ( seed > 0 ) set.seed( round(seed) )
  y <- if (seed==0) {
    1:n
  } else { rnorm(n) }
  data.frame( group=as.character(1:n), x=1:n, y=y )
}

exampleData <- makeExampleData( n=7, seed=101 )

killbackground <-
  theme(panel.background = element_blank(),axis.line=element_blank(),
        axis.text.x=element_blank(),
        axis.text.y=element_blank(),
        axis.ticks=element_blank(),
        axis.title.x=element_blank(),
        axis.title.y=element_blank(),
        legend.position="none",
        panel.background=element_blank(),
        panel.border=element_blank(),
        panel.grid.major=element_blank(),
        panel.grid.minor=element_blank(),
        plot.background=element_blank())

showColorSquares <- function( 
  .data, type=NULL, palette=NULL, colFun=rainbow, letters=FALSE ) {
  pp <- 
    ggplot( .data , aes(x=rank(y)) ) +
    geom_bar( stat="identity", 
              aes(fill=group,y=1+0*y), 
              position=position_stack(width=.9) ) +
    killbackground + 
    coord_fixed() + 
    ylim(-.2,1.2)
  if (letters) 
    pp <-  pp + geom_text( y=.5, aes( label=group ) ) 
  scale <- if( is.null(palette) ) {
    scale_fill_manual( 
      values=colFun(nrow(.data)), guide="none" )
  } else {
    scale_fill_brewer( type="seq",palette=palette )  
  }
  pp + scale
}


