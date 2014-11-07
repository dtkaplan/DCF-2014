## Compute the correlation between every pair of variables.

pairCor <- function( data ) {
  M <- model.matrix( ~ ., data )
  varNames <- colnames(M)
  Combs <- combn( 2:ncol(M), 2 )
  x=Combs[1,] 
  y=Combs[2,]
  Res <- data.frame( name1=varNames[x], 
                     name2=varNames[y]
  )
  r <- numeric( length(x) )
  for (k in 1:nrow(Res)) {
    r[k] <- cor( M[,x[k]],M[,y[k]],use="complete")

  }
  Res[["r"]] <- r
  return(Res)
}

showNet <- function(variablePairs) {
  V <- edgesToVertices( variablePairs, from=name1, to=name2 )
  E <- edgesForPlotting( V, ID=ID, x, y, from=name1, to=name2, Edges=variablePairs )

    ggplot( V ) + 
    geom_segment( data=E, 
                aes( x=x, y=y, xend=xend, yend=yend,
                     color=factor(sign(r)),
                     size=5*sqrt(abs(r))) ) +
    geom_text(size=6, aes(label=ID, x=x, y=y)) 
}