# objective function, spline interpolation of the sample spectrum
f <- function(x, q, d) spline(q, d, xout = x)$y
    x <- sp$freq
    y <- log(sp$spec)
    nb <- 10 # choose number of intervals
    iv <- embed(seq(floor(min(x)), ceiling(max(x)), len = nb), 2)[,c(2,1)]
    # make overlapping intervals to avoid problems if the peak is close to
    # the ends of the intervals (two modes could be found in each interval)
    iv[-1,1] <- iv[-nrow(iv),2] - 2
    # The function "f" is maximized at each of these intervals
    iv
    #            [,1]      [,2]
    # [1,]  0.0000000 0.6666667
    # [2,] -1.3333333 1.3333333
    # [3,] -0.6666667 2.0000000
    # [4,]  0.0000000 2.6666667
    # [5,]  0.6666667 3.3333333
    # [6,]  1.3333333 4.0000000
    # [7,]  2.0000000 4.6666667
    # [8,]  2.6666667 5.3333333
    # [9,]  3.3333333 6.0000000
    # choose thresholds for the gradient and Hessian to accept
    # the solution is a local maximum
    gr.thr <- 0.001
    hes.thr <- 0.03

require("numDeriv")
vals <- matrix(nrow = nrow(iv), ncol = 3)
grd <- hes <- rep(NA, nrow(vals))
for (j in seq(1, nrow(iv)))
{
  opt <- optimize(f = f, maximum = TRUE, interval = iv[j,], q = x, d = y)
    vals[j,1] <- opt$max
          vals[j,3] <- exp(opt$obj)
	    grd[j] <- grad(func = f, x = vals[j,1], q = x, d = y)
	      hes[j] <- hessian(func = f, x = vals[j,1], q = x, d = y)
	        if (abs(grd[j]) < gr.thr && abs(hes[j]) > hes.thr)
		    vals[j,2] <- 1
		    }
		    # it is convenient to round the located peaks in order to avoid
		    # several local maxima that essentially the same point
		    vals[,1] <- round(vals[,1], 2)
		    if (anyNA(vals[,2])) {
		      peaks <- unique(vals[-which(is.na(vals[,2])),1])
		      } else
		        peaks <- unique(vals[,1])