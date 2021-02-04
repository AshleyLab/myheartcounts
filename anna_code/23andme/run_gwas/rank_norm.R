#' Rank normalization
#'
#' This function fits the data exactly to the normal distribution (or any other quantile function given as \code{FUN}) using corresponding quantiles.
#' @param x the data to normalize
#' @param ties.method the \code{ties.method} argument for \code{\link{rank}}
#' @param FUN a quantile function such as \code{\link{qnorm}}
#' @param na.action a function to handle \code{NA}s. Defaults to the value of \code{\link{options}("na.action")}
#' @return the normalized data
#' @examples
#' not.normal <- rlnorm(100)
#' hist(not.normal)
#' hist(rank.normalize(not.normal))
#'
#' # Different function
#' hist(rank.normalize(not.normal, FUN = qexp))
#'
#' # Breaking ties
#' hist(rank.normalize(not.normal, ties.method = "random"))
#'
#' # Missing values
#' not.normal[10] <- NA
#' hist(rank.normalize(not.normal)) # Shouldn't fail
#' \dontrun{hist(rank.normalize(not.normal, na.action = na.fail))} # Should fail
#'
#' @import stats
#' @export
rank.normalize <- function(x, FUN=qnorm, ties.method = "average", na.action) {
	       if (missing(na.action)) {
	       	  na.action <- get(getOption("na.action"))
		  }
		  if(! is.function(na.action)) {
		       stop("'na.action' must be a function")
		       }
		       x <- na.action(x)
		       FUN(rank(x, ties.method = ties.method)/(length(x)+1))
}