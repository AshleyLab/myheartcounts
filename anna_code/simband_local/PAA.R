PAA<-function (x, w) 
{ 
    if ((w - floor(w)) > 0) {
        stop("w (number of frames) must be an integer")
    }
    n <- length(x)
    if (w > n) {
        stop("cannot have more parts than the length of the series")
    }
    PAA <- rep(0, w)
    d = n/w
    breakpoints <- seq(0, n, d)
    for (i in 1:w) {
        init <- breakpoints[i] + 1
        end <- breakpoints[i + 1]
        frac_first <- ceiling(init) - init
        frac_end <- end - floor(end)
        interv = floor(init):ceiling(end)
        sec <- x[interv]
        if (frac_first > 0) {
            sec[1] = sec[1] * frac_first
        }
        if (frac_end > 0) {
            sec[length(sec)] = sec[length(sec)] * frac_end
        }
        PAA[i] = sum(sec)/d
    }
    PAA
}