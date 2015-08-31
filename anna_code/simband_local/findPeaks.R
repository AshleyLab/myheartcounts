findPeaks<-function (x, thresh = 0) 
{
    pks <- which(diff(sign(diff(x, na.pad = FALSE)), na.pad = FALSE) < 
        0) + 2
    if (!missing(thresh)) {
        if (sign(thresh) < 0) 
            thresh <- -thresh
        pks[x[pks - 1] - coredata(x[pks]) > thresh]
    }
    else pks
}