# Follows Dy & Broadley, Feature Selection for Unsupervised Learning: http://www.jmlr.org/papers/volume5/dy04a/dy04a.pdf
library(doMPI)
library(foreach)
source('helpers.R')
source('feature_select_helpers.R')
load("6minwalk_merged_df") 
print('loaded data') 
# REMOVE NA ROWS FOR KMEANS CLUSTERING 
data<-na.omit(merged_df)
print('got rid of na') 
ncolumns=ncol(data)
cnames = names(data)
#0) Remove any features with less than 2 unique values 
toremove=c() 
for(i in 1:ncolumns)
{
  if (length(unique(data[,i]))<2)
    toremove<-c(toremove,i)
}
data<-data[,-toremove]
ncolumns=ncol(data)
cnames = names(data)

#1) identify any correlated features 
feature_groups<-get_high_cor_features(merged_df)
print('got feature cor') 

#2) first pass of k-means clustering for individual features 
cl<-startMPIcluster(verbose=TRUE,maxcores=100)

print("made cluster") 
registerDoMPI(cl)
print("registered") 

results <- foreach( i = 1:ncolumns ) %dopar% {
  cursubset <- subset(data, select = c(i))
  iter_k_means(cursubset)
}
print("done with parallel step")

#generate a hash of feature name to ssq & k 
feat_hash<-hash() 
for(i in 1:length(results))
{
  feat_hash[cnames[i]]=results[[i]]
}
print("got results") 
print(feat_hash)
save(feat_hash,file="6minwalk_feat_hash")
#load("feat_hash")

#3) #Determine the best feature from each group of highly correlated features 
first_pass_results<-first_pass_filter(feat_hash,feature_groups)
use=first_pass_results[[1]] 


#4) Add the feature with the best in cluster/between cluster ratio 
bestfeature=first_pass_results[[2]] 
bestfeature_k=first_pass_results[[3]] 
min_ssq=first_pass_results[[4]]
 
 subsets_feat<-hash() 
 subsets_feat[1]=c(bestfeature)
 subsets_k<-hash() 
 subsets_k[1]<-bestfeature_k
 subsets_ratio_ssq<-hash()
 subsets_ratio_ssq[1]<-min_ssq
 data<-data[,use]
 ncolumns=ncol(data)
 cnames = names(data)
# 
 use=setdiff(use,bestfeature)
# 
 print("got features to use!")
# 
# #5) Iterate for remaining feature subsets 
iter=1 
while(length(use)>1)
{
  curfeatures=values(subsets_feat[as.character(iter)])
  print(paste("curfeatures",curfeatures))
  iter=iter+1
  print(paste("iteration",iter,sep=""))
  #add remaining features individually to the current subset 
  results <- foreach( i = 1:length(use) ) %dopar% 
  #results <- foreach( i = 1:2 ) %dopar% 
  {
    cursubset <- subset(data, select = c(curfeatures,use[i]))
    iter_k_means(cursubset)
  }
  print("DONE WITH ITERATION!!")
  feat_hash<-hash() 
  for(i in 1:length(results))
  {
    feat_hash[use[i]]=results[[i]]
  }
  print("done with parallel step")
  #find the feature that gives the best ssq ratio 
  fhv<-values(feat_hash)[1,]
  best_index<-which(fhv %in% min(fhv))
  best_feature=keys(feat_hash)[best_index]
  new_min_ssq=values(feat_hash[best_feature])[1]
  new_k=values(feat_hash[best_feature])[2]
  subsets_feat[iter]=c(best_feature,curfeatures)
  subsets_k[iter]=new_k 
  subsets_ratio_ssq[iter]=new_min_ssq
  print(paste("best_feature",best_feature))
  use=setdiff(use,best_feature)
}
save(subsets_feat,subsets_k,subsets_ratio_ssq,file="6minwalk_feature_selection_results.out")
#load("feature_selection_results.out")
#6) Compare across different feature subsets with the cross-projection method 
subset_keys=keys(subsets_feat)
#initialize by assuming 2nd feature subset is best -- 1st subset is trivial max/min! 
bestkey="2"
best_feat_set=subsets_feat[[bestkey]]
best_feat_k=subsets_k[[bestkey]]
best_fit=kmeans(data[,best_feat_set],best_feat_k,nstart=5)
subset_keys=setdiff(subset_keys,c(bestkey,"1"))
for(key in subset_keys)
{
  new_feat_set=subsets_feat[[key]] 
  new_feat_k=subsets_k[[key]]
  new_fit=kmeans(data[,new_feat_set],new_feat_k,nstart=5)
  #compare to current best with cross-projection method
  comparison=cross_projection(bestkey,best_feat_set,best_fit$centers,best_fit$cluster,key,new_feat_set,new_fit$centers,new_fit$cluster,data)
  s1_c1_df=comparison[1] 
  s2_c2_df=comparison[2]
  if(s1_c1_df<s2_c2_df)
    bestkey=bestkey
  else
    bestkey=key
  print(paste("best key",bestkey))
  best_feat_set=subsets_feat[[bestkey]]
  best_feat_k=subsets_k[[bestkey]]
  best_fit=kmeans(data[,best_feat_set],best_feat_k,nstart=5)
}

#7) Finished! Store the information about the best feature subset & number of clusters 
save(best_feat_set,best_feat_k,best_fit,file="6minwalk_feature_selection_results.bin")

closeCluster(cl)
mpi.finalize()