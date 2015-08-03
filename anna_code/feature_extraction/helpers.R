#cdf 

cdf<-function(x)
{
  x<-x/sum(x)
  cdfval=c()  
  total_sum=0 
  for(i in 1:length(x))
  {
    total_sum=total_sum+x[i] 
    cdfval=c(cdfval,total_sum)
  }
  return(cdfval)
}

#sum of squares 
ss<-function(x)
{
  sum(x^2)
}

#normalization /srv/gsfs0/projects/ashley/common/simband
normalize<-function(x)
{
(x-min(x))/(max(x)-min(x))
}

#takes a difference between the last and first timestamp and divides by the number of samples to estimate the sampleing frequency
get_fs<-function(x)
{
  if(typeof(x)=="double")
  {
    delta<-x[length(x)]-x[1]
  }
  else
  {
    #convert from string to timestamp
    last <- strptime(x[length(x)],"%Y-%m-%dT%H:%M:%S")
    first<-strptime(x[1],"%Y-%m-%dT%H:%M:%S")
    delta<-as.numeric(difftime(last,first,units="secs"))
  }
  fs=length(x)/delta
  return(c(fs=fs,delta=delta)) 
}

#MMAV--modified mean absolute value 
get_mmav<-function(x)
{
  N=length(x)
  mmav=0 
  for(i in 1:N)
  {
    if(i<0.25*N)
    {
      Wn=0.5
    }
    else if(i>0.75*N)
    {
      Wn=0.05
    }
    else
    {
      Wn=1
    }
    mmav=mmav+Wn*abs(x[i])
  }
  mmav=mmav/N
  return(mmav)
}

get_zero_crossing<-function(x)
{
  lowgroup=x[1:length(x)-1]
  highgroup=x[2:length(x)]
  product=sign(lowgroup*highgroup)
  positive=which(product %in% 1)
  product[positive]=0 
  delta=sign(lowgroup-highgroup)
  negative=which(delta %in% -1)
  delta[negative]=0 
  zero_val=abs(sum(product*delta))
  return(zero_val)
}