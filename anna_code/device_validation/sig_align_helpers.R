cor.cross.sweep <-function(x0,y0)
{
  best_offset=0 
  best_cor=0 
  for(oset in -10:10)
  {
    try({
    cur_cor=cor.cross(x0,y0,i=oset)
    print(paste(oset,":",cur_cor))
    if(cur_cor > best_cor)
    {
      best_cor=cur_cor
      best_offset=oset 
    }
    })
    
  }
  return(best_offset)
}

cor.cross <- function(x0, y0, i=0) {
  #
  # Sample autocorrelation at (integral) lag `i`:
  # Positive `i` compares future values of `x` to present values of `y`';
  # negative `i` compares past values of `x` to present values of `y`.
  #
  if (i < 0) {x<-y0; y<-x0; i<- -i}
  else {x<-x0; y<-y0}
  n <- length(x)
  cor(x[(i+1):n], y[1:(n-i)], use="complete.obs")
}

resample <- function(x,t) {
  #
  # Resample time series `x`, assumed to have unit time intervals, at time `t`.
  # Uses quadratic interpolation.
  #
  n <- length(x)
  if (n < 3) stop("First argument to resample is too short; need 3 elements.")
  i <- median(c(2, floor(t+1/2), n-1)) # Clamp `i` to the range 2..n-1
  u <- t-i
  x[i-1]*u*(u-1)/2 - x[i]*(u+1)*(u-1) + x[i+1]*u*(u+1)/2
}

normalize <- function(x) {
  #
  # Normalize vector `x` to the range 0..1.
  #
  x.max <- max(x); x.min <- min(x); dx <- x.max - x.min
  if (dx==0) dx <- 1
  (x-x.min) / dx
}
