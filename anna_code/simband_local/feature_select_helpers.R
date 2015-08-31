library(hash)
source("helpers.R") 
#Helper functions for feature seletion

#Sb--> How scattered the cluster means are from the total mean 
Sb<-function(s,membership,df)
{
  data=df[,s]
  totalmean=colMeans(data)
  nclusters=length(unique(membership))
  distance=0 
  for(i in 1:nclusters)
  {
    
    subjects_current=names(membership[which(membership %in% i)])
    feat_vals_current=data[subjects_current,]
    #get the cluster means! 
    cm_current=colMeans(feat_vals_current)
    distance=distance+sqrt(sum((cm_current-totalmean)^2))
  }
  print(paste("Sb:",distance/nclusters))
  return(distance/nclusters)
  
}

#Sw--> How scattered the samples are from their cluster means 
Sw<-function(s,membership,df)
{
  data=df[,s]
  nclusters=length(unique(membership))
  distance=0 
  for(i in 1:nclusters)
  {
    
    subjects_current=names(membership[which(membership %in% i)])
    feat_vals_current=data[subjects_current,]
    #get the cluster means! 
    cm_current=colMeans(feat_vals_current)
    distance=distance+sqrt(sum((feat_vals_current-cm_current)^2))
  }
  print(paste("Sw:",distance/nrow(df)))
  return(distance/nrow(df))
}

#Normalize Sw/Sb by cross-projection for two different feature subsets 
cross_projection<-function(key1,s1,c1,membership1, key2, s2,c2,membership2,df)
{ 
  s1_c1_df=(Sw(s1,membership1,df)/Sb(s1,membership1,df))*(Sw(s2,membership1,df)/Sb(s2,membership1,df))
  s2_c2_df=(Sw(s2,membership2,df)/Sb(s2,membership2,df))*(Sw(s1,membership2,df)/Sb(s1,membership2,df))
  #return subset with smaller normalized ratio 
  print(paste("s1_c1_df",s1_c1_df))
  print(paste("s2_c2_df",s2_c2_df))
  return(c(s1_c1_df,s2_c2_df))
}

get_high_cor_features<-function(df)
{
  corvals=cor(df)
  rows=nrow(corvals)
  dfnames=names(df)
  groups<-hash() 
  for(i in 1:rows)
  {
    curname=dfnames[i]
    highcornames=dfnames[which(corvals[i,] > 0.95)]
    highcornames=highcornames[! highcornames %in% curname]
    if(length(highcornames)>0)
    {
      groups[curname]=highcornames 
    }
  }
  return(groups)
}


first_pass_filter<-function(feat_hash,feat_groups)
{
  analyzed=hash()
  use=c()
  ignore=c() 
  
  bestfeat=NULL 
  bestfeatk=NULL
  min_ssq_ratio=1 
  
  for(feat in keys(feat_hash))
  {
    if (!(feat %in% keys(analyzed) ))
    {
      if(feat %in% keys(feature_groups))
      {
        tocheck=c(feat,values(feature_groups[feat]))
        #remove any features that are already in our ignore list 
        tocheck=setdiff(tocheck,ignore)
        checkvals=values(feat_hash[tocheck])[1,]
        best_index=which(checkvals %in% min(checkvals))
        best_feat_group=tocheck[best_index]
        use=c(use,best_feat_group)
        if (values(feat_hash[best_feat_group])[1] < min_ssq_ratio)
        {
          bestfeat=best_feat_group 
          bestfeatk=values(feat_hash[best_feat_group])[2]
          min_ssq_ratio=values(feat_hash[best_feat_group])[1]
        }
        for(f in tocheck)
        {
          analyzed[f]=TRUE 
          if (!(f %in% best_feat_group))
          {
            ignore=c(ignore,f)
          }
        }
        
      }
      else
      {
        featvals=values(feat_hash[feat])
        ssq_ratio=featvals[1]
        if (ssq_ratio<min_ssq_ratio)
        {
          bestfeat=feat
          bestfeatk=featvals[2] 
          min_ssq_ratio=ssq_ratio
          
        }
        analyzed[feat]=TRUE
        use=c(use,feat)
        
      }
    }
  }
  #cleanup anything that's both in the "use" and "ignore list" --> move to ignore list 
  use=setdiff(use,ignore)
  #cleanup duclicates
  use=unique(use)
  ignore=unique(ignore)
  return(list(use,bestfeat,bestfeatk,min_ssq_ratio))
}

#perform k-means clustering and sweep across a range of k-values to pick the one where 
#the BIC has a drop of <10% from the prior value of K 
iter_k_means<-function(data)
{ 
  #print("one round")
  #get the relevant columns for the k-means clustering 
  #data <- subset(data, select = c(columns))
  maxk=min(14,nrow(unique(data)))
  bicval <- (nrow(data)-1)*sum(apply(data,2,var))
  for(i in 2:maxk)
  {
    km<-kmeans(data,i,nstart=5)
    newbic=kmeansBIC(km) 
    diff=(newbic-bicval)/bicval 
    if (diff > -0.10)
    {
      #stop with this value of k 
      #incluster ssq/ betweencluster ssq
      ssq_ratio=km$tot.withinss/km$betweenss 
      return(c(ssq_ratio,i)) 
    }
    else
    {
      bicval=newbic 
    }
  }
  ssq_ratio=km$tot.withinss/km$betweenss 
  return(c(ssq_ratio,i)) 
}