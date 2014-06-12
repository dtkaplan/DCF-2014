## 96-well simulation

getCellCountData <- function(gp=3) {
  
  seedBase <- 6723
  set.seed(6723 + gp)
  cellLines <- c('Colon','Breast','CNS','Ovarian','Pancreatic')
  cellLines <- sample(cellLines,2)
  dilutions <- c(0,.05, .1, .5, 1, 2)
  baseCount <- 1200 + round(2000*runif(2))
  slope <- 600*runif(2, min=-1,max=2)
  cellCount1 <- c(baseCount[1] + slope[1]*1:length(dilutions),
                  baseCount[2] + slope[2]*1:length(dilutions) ) 
  protocol <- data.frame( column=paste("X",1:12,sep=''),
                          dilution=c(dilutions,dilutions),
                          cellLine=c(rep(cellLines,each=6)))
  res <- NULL
  for (k in 1:12) { # replications
    res <- cbind(res, 100*rpois(8,lambda=abs(cellCount1[k]/100)))
  }
  
  return( list(counts=data.frame(row=LETTERS[1:8], res), 
               protocol=protocol))
  
}
