# simpler interface for predictions from party::ctree

funCT <- function( ctmod ) {
  explanatory <- ctmod@data@env$input
  inNames <- names( explanatory )
  inClass <- unlist(lapply( explanatory, class ))
  f <- function( ... ) {
    # format inputs as a dataframe
    inputs <- data.frame( ... )
    # Check inputs for a match
    stopifnot( all( inNames %in% names(inputs) ) )
    # Convert the ... inputs into the right kind of things
    newInputs <- rbind( head( explanatory, 1), 
                        inputs)[-1,]
    
    response <- whoIsPregnant@data@env$response[1,]
    # calculate the function outputs
    outputs <- treeresponse( ctmod, newInputs )
    if ( inherits( response, "factor" ) ) {
      # format the outputs as a data frame
      res <- data.frame(
        matrix( unlist(outputs), 
                ncol=length(levels(response)),
                byrow=TRUE ) )
      names(res) <- levels(response)
    } else {
      res <- outputs
    }
      
    return( cbind(inputs, res) )
  }
  
  
  return( f )
  
}