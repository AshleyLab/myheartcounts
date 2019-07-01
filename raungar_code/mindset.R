load_libraries<-function(){
  library(ggfortify)
  library(ggplot2)
  library(reshape)
  library(FactoMineR)
  library(factoextra) 
  library(fmsb) #multicolinearity: VIF
  library(MASS)
  library(leaps)
  library(car) #levene test
  library("GGally")
  library(lm.beta)
  library(tidyverse)
  library(modelr)
  library(broom) 
  library(olsrr) #cooks test etc
  library(xavamess) #rank.normalize
  library(gbm)
  library(MLmetrics)
  library(e1071) #confusion matrix
  library(caret) #confusion matrix
  library(synapser)
  library(randomForest)
  library(Hmisc)
  
}
load_libraries


#####Load Variables
set.seed(1234)
load_illness_df<-function(){
  synLogin(email="raungar@stanford.edu", password="PASSWORD_HERE")
  illness_id<-"syn18143712"
  illness <- synTableQuery(paste0("SELECT * FROM ",illness_id))
  illness_df<-illness$asDataFrame()
  
  illness_df_qs_non_unique<-illness_df[!duplicated(illness_df$healthCode),]
  illness_df_qs_unique<-illness_df_qs_non_unique[!is.na(illness_df_qs_non_unique$healthCode),]
  illness_answers<-as.data.frame(lapply(illness_df_qs_unique[,15:34], function(x) sapply(strsplit(sapply(strsplit(x,"\\["),"[",2),"\\]"),"[[",1)))
  illness_df_qs<-sapply(illness_answers,as.numeric)
  rownames(illness_df_qs)<-illness_df_qs_unique$healthCode
  
  body_adversary_cols<-c(3,7,17,20)
  body_capable_cols<-c(4, 13, 15)
  body_responsive_cols<-c(1, 10, 19)
  illness_catastrophe_cols<-c(2, 11, 14)
  illness_manageable_cols<-c(6, 9, 16)
  illness_opportunity_cols<-c(5, 8, 12, 18)
  
  body_adversary<-rowMeans(illness_df_qs[,body_adversary_cols])
  body_capable<-rowMeans(illness_df_qs[,body_capable_cols])
  body_responsive<-rowMeans(illness_df_qs[,body_responsive_cols])
  illness_catastrophe<-rowMeans(illness_df_qs[,illness_catastrophe_cols])
  illness_manageable<-rowMeans(illness_df_qs[,illness_manageable_cols])
  illness_opportunity<-rowMeans(illness_df_qs[,illness_opportunity_cols])
  
  illness_df<-data.frame(body_adversary,body_capable,body_responsive,
                         illness_catastrophe, illness_manageable,illness_opportunity)
  
  return(illness_df)
  
}
load_covariates<-function(){
  covariate_file<-c("/Users/rachelungar/Documents/Stanford1.3/AshleyLab/Mindset/demographics_summary_all.tsv.gz")
  covariates<-read.table(gzfile(covariate_file),header=T,sep="\t")
  unique_covariates<-unique(covariates[,1:3])
  rownames(unique_covariates)<-unique_covariates$Subject
  return(unique_covariates)
}
load_phenotypes<-function(){
  pheno_file<-c("/Users/rachelungar/Documents/Stanford1.3/AshleyLab/Mindset/phenotypes_all.txt.gz")
  phenotypes<-read.table(gzfile(pheno_file),header=T,sep="\t")
  #unique_phenotypes$family_history_healthy=FALSE
  
  unique_phenotypes<-unique(phenotypes[,c(2,3,4,29,33)])
  unique_phenotypes$family_history_healthy<-sapply(unique_phenotypes$family_history, function(x){ if(x==3 && !is.na(x)){x=TRUE}else{x=FALSE}})
  unique_phenotypes$vascular_healthy<-sapply(unique_phenotypes$vascular, function(x){ if(x==7 && !is.na(x)){x=TRUE}else{x=FALSE}})
  unique_phenotypes$medications_to_treat_healthy<-sapply(unique_phenotypes$medications_to_treat, function(x){ if(x==4 && !is.na(x)){x=TRUE}else{x=FALSE}})
  unique_phenotypes$heart_disease_healthy <-sapply(unique_phenotypes$heart_disease, function(x){ if(x==10 && !is.na(x)){x=TRUE}else{x=FALSE}})
  
  rownames(unique_phenotypes)<-unique_phenotypes$IID
  return(unique_phenotypes)
}
load_steps_df<-function(){
  steps_file<-c("/Users/rachelungar/Documents/Stanford1.3/AshleyLab/Mindset/parsed_HealthKitData.steps.tsv")
  steps<-read.table(steps_file,header=T,sep="\t")
  aggregate_steps<-aggregate(steps$Value, list(steps$Subject), median)
  colnames(aggregate_steps)<-c("ID","Value")
  steps_reduced<-data.frame(aggregate_steps$Value)
  rownames(steps_reduced)<-aggregate_steps$ID
  colnames(steps_reduced)<-"Value"
  return(steps_reduced)
}
load_distance_df<-function(){
  distance_file<-c("/Users/rachelungar/Documents/Stanford1.3/AshleyLab/Mindset/parsed_HealthKitData.distance.tsv")
  distance<-read.table(distance_file,header=T,sep="\t")
  aggregate_distance<-aggregate(distance$Value, list(distance$Subject), median)
  colnames(aggregate_distance)<-c("ID","Value")
  distance_reduced<-data.frame(aggregate_distance$Value)
  rownames(distance_reduced)<-aggregate_distance$ID
  colnames(distance_reduced)<-"Value"
  return(distance_reduced)
}
load_device_df<-function(){
  device_file<-c("/Users/rachelungar/Documents/Stanford1.3/AshleyLab/Mindset/device_table.csv")
  device_table<-read.table(gzfile(device_file),header=T,sep=",")
  device_inter<-gsub("\\[|\\]", "", device_table$device) #grep(1,device_inter)
  device_TF<-data.frame(device_table$healthCode,grepl(1,device_inter))
  unique_device<-unique(device_TF)
  unique_device_no_mixedinfo<-unique_device[!duplicated(unique_device$device_table.healthCode),]
  rownames(unique_device_no_mixedinfo)<-unique_device_no_mixedinfo$device_table.healthCode
  return(unique_device_no_mixedinfo)
}
heatmap_corr<-function(cor_matrix){
  ggcor_matrix_melted<-melt(cor_matrix)
  gg_result<-ggplot(ggcor_matrix_melted, aes(X1,X2, fill=value))+
    xlab("")+
    ylab("")+
    scale_fill_gradient2(low = "blue", high = "red", mid = "white", 
                         midpoint = 0, limit = c(-1,1), space = "Lab", 
                         name="Correlation")+
    # geom_text(aes(X2, X1, label = value), color = "black", size = 4)+
    theme(axis.text.x = element_text(angle = 45,hjust=1))+
    geom_tile()+
    geom_text(aes(label = round(value, 3))) 
  
  return(gg_result)
}
get_interactions<-function(data_set){
  
  nb_test_interactions<-glm.nb(formula=round(Value)~body_adversary + body_capable + body_responsive+ 
                                 illness_catastrophe+illness_manageable+ illness_opportunity
                               +Sex+Age+(body_adversary + body_capable + body_responsive+ 
                                           illness_catastrophe+illness_manageable+ illness_opportunity
                                         +Sex+Age)^2, 
                               data=data_set,link=log)
  nb_test_interactions_res<-summary(nb_test_interactions)
  nb_test_interactions_res$coefficients<-cbind(as.data.frame(nb_test_interactions_res$coefficients),"padj"=p.adjust((nb_test_interactions_res$coefficients[,4]),method="bonferroni"))
  interaction_terms<-rownames(nb_test_interactions_res$coefficients[nb_test_interactions_res$coefficients[,5]<0.05,])
  return(interaction_terms)
  
  
}
get_sig_corr<-function(data_matrix){
  rcor_temp<-rcorr(as.matrix(data_matrix[,c(1:7)]))
  rcor_cols<-which(p.adjust(rcor_temp$P,method="bonferroni")<0.05)%%7
  rcor_rows<-ceiling(which(p.adjust(rcor_temp$P,method="bonferroni")<0.05)/7)
  rcor_df<-data.frame(rcor_rows,rcor_cols)
  terms<-data.frame(rownames(rcor_temp$r)[rcor_df$rcor_rows],
                    colnames(rcor_temp$r)[rcor_df$rcor_cols])
  return(paste(terms$rownames.rcor_temp.r..rcor_df.rcor_rows.,":",terms$colnames.rcor_temp.r..rcor_df.rcor_cols.))
}


illness_df<-load_illness_df()
steps_df<-load_steps_df()
distance_df<-load_distance_df()
covariates_df<-load_covariates()
phenotypes_df<-load_phenotypes() #last number is "healthy"
device_df<-load_device_df()


#merge different dataframes
merged_illness_steps<-merge(illness_df,steps_df,by.x = "row.names",by.y = "row.names")
merged_illness_steps_cov<-merge(merged_illness_steps,covariates_df[,-1],by.x = "Row.names",by.y = "row.names")
merged_illness_steps_cov_device<-merge(merged_illness_steps_cov,device_df,by.x = "Row.names",by.y = "row.names")
merged_illness_steps_cov_device_pheno<-merge(merged_illness_steps_cov_device,phenotypes_df,by.x = "Row.names",by.y = "row.names")
illness_steps<-na.omit(merged_illness_steps_cov_device_pheno[,-c(1,11,13)])
colnames(illness_steps)[10]<-"fromPhone"
illness_steps<-illness_steps[illness_steps$fromPhone==TRUE,]
illness_steps$Age<-as.numeric(illness_steps$Age)
illness_steps$vascular<-as.factor(illness_steps$vascular)
illness_steps$Value_Normalized<-rank.normalize(illness_steps$Value)
illness_steps$Sex<-as.numeric(illness_steps$Sex)




#### Data Exploration
illness_steps_for_cor<-illness_steps
illness_steps_for_cor$Sex<-as.numeric(illness_steps$Sex)
illness_steps_for_cor$family_history_healthy<-as.numeric(illness_steps_for_cor$family_history_healthy)
illness_steps_for_cor$vascular_healthy<-as.numeric(illness_steps_for_cor$vascular_healthy)
illness_steps_for_cor$medications_to_treat_healthy<-as.numeric(illness_steps_for_cor$medications_to_treat_healthy)
illness_steps_for_cor$heart_disease_healthy<-as.numeric(illness_steps_for_cor$heart_disease_healthy)
cor_illness_steps<-cor(illness_steps_for_cor[,c(1:9,15:18)])
cor_illness_steps_reduced<-cor(illness_steps_for_cor[,c(1:9,17)])



####Test for Variables to Include
#Principle Component Analysis
illness_steps_pca<-prcomp((cor_illness_steps_reduced))
prop_variance<-c(illness_steps_pca$sdev^2/sum(illness_steps_pca$sdev^2))
plot(cumsum(prop_variance), xlab = "Principal Component",
     ylab = "Cumulative Proportion of Variance Explained",
     type = "b")+abline(h=0.95)
illness_steps_pca2<-PCA(cor_illness_steps_reduced)
fviz_pca_contrib(illness_steps_pca2,choice="var",axes=1:5)
fviz_pca_var(illness_steps_pca2,col.var="contrib")+
  scale_color_gradient2(low="white", mid="blue", 
                        high="red", midpoint=(mean(illness_steps_pca2$var$contrib)+median(illness_steps_pca2$var$contrib))/2) + theme_minimal()
#All variables should be included in model


#Which Model?
ggpair_res<-ggpairs(illness_steps[,c(1:9,17)])
##Response Variable
plot(hist(illness_steps$Value),main="Histogram of Step Count",xlab="Step Count")
##Test for a GLM: Either Poisson/Quasi-Poisson/Negative Binomial
###Poisson requires variance to equal the mean
dispersion<-var(illness_steps$Value)-mean(illness_steps$Value)
print(dispersion)
###Overdispersed, so must be Quasi-Poisson or Negative Binomial
###To determine, check goodness of fit
illness_steps_quasi<-glm(formula=round(Value) ~body_adversary + body_capable + body_responsive+ 
                             illness_catastrophe+illness_manageable+ illness_opportunity + 
                             Sex +Age+medications_to_treat_healthy,  data=illness_steps, family = quasipoisson)
illness_steps_negbin<-glm.nb(formula=round(Value) ~body_adversary + body_capable + body_responsive+ 
                                   illness_catastrophe+illness_manageable+ illness_opportunity+
                                   Sex +Age+medications_to_treat_healthy, data=illness_steps,link=log)
###deviance is a measure of how well the model fits the data - if the model
###fits well, the observed values will be close to their predicted means, 
###causing both of the terms in D to be small, and so the deviance to be small
###If p is NOT signficant, this model is a good fit
print(pchisq(illness_steps_quasi$deviance, df=illness_steps_quasi$df.residual, lower.tail=FALSE))
print(pchisq(illness_steps_negbin$deviance, df=illness_steps_negbin$df.residual, lower.tail=FALSE))
#So, We should use negative binomial

##linear relationship
####observed versus predicted values or a plot of residuals versus predicted values or residuals versus individual independent variables.
#### points should be symmetrically distributed around a diagonal line in the former plot or around horizontal line in the latter plot, with a roughly constant variance
plot(illness_steps_negbin)


##Multicollinearity (VIF)
###This can be performed on a linear model with the same results
illness_steps_lm<-lm(formula=round(Value) ~body_adversary + body_capable + body_responsive+ 
     illness_catastrophe+illness_manageable+ illness_opportunity + 
     Sex +Age+medications_to_treat_healthy,  data=illness_steps)
print(VIF(illness_steps_lm))
#VIF is less than three, passes Multicollinearity assumptions



#Variable reduction?
###These are not significantly different
illness_steps_negbin_step<-stepAIC(illness_steps_negbin,direction = "both")
illness_steps_negbin_step_res<-glm.nb(formula=round(Value) ~ body_responsive+ Sex +medications_to_treat_healthy, data=illness_steps,link=log)
print(anova(illness_steps_negbin_step_res,illness_steps_negbin))



#Interactions to include
ggpair_res<-ggpairs(illness_steps[,c(1:9)])
cor_illness_steps_plot<-heatmap_corr(cor_illness_steps_reduced)
print(cor_illness_steps_plot)

#Get all possible interactions
illness_steps_negbin_test_interactions<-glm.nb(formula=round(Value) ~(body_adversary + body_capable + body_responsive+ 
                                                                        illness_catastrophe+illness_manageable+ illness_opportunity
                                                                      +Sex+Age+medications_to_treat_healthy)^2, 
                                               data=illness_steps,link=log)
#Adjust p-value with most conservative test
illness_steps_negbin_test_interactions_res<-summary(illness_steps_negbin_test_interactions)
illness_steps_negbin_test_interactions_res$coefficients<-cbind(as.data.frame(illness_steps_negbin_test_interactions_res$coefficients),"padj"=p.adjust((illness_steps_negbin_test_interactions_res$coefficients[,4]),method="bonferroni"))
interaction_terms<-rownames(illness_steps_negbin_test_interactions_res$coefficients[illness_steps_negbin_test_interactions_res$coefficients[,5]<0.05,])
print(interaction_terms)

#paste(interaction_terms,collapse=" + ")
illness_steps_negbin_with_interactions<-glm.nb(formula=round(Value) ~body_adversary + body_capable + body_responsive+ 
                                 illness_catastrophe+illness_manageable+ illness_opportunity
                               +Sex+Age+medications_to_treat_healthy+
                                 body_capable:body_responsive + body_capable:medications_to_treat_healthy + 
                                 body_responsive:illness_catastrophe + body_responsive:Age + illness_catastrophe:Sex, 
        data=illness_steps,link=log)
illness_steps_negbin_with_interactions_plus<
##Are these models different? Yes.
anova(illness_steps_negbin_with_interactions,illness_steps_negbin)

illness_steps_negbin_with_interactions_step<-stepAIC(illness_steps_negbin_with_interactions)
illness_steps_negbin_with_interactions_step_res<-glm.nb(round(Value) ~ body_responsive + illness_catastrophe + Sex + medications_to_treat_healthy+
  Age + body_responsive:Age + illness_catastrophe:Sex+body_capable:body_responsive + body_capable:medications_to_treat_healthy + 
    body_responsive:illness_catastrophe + body_responsive:Age + illness_catastrophe:Sex, 
  data=illness_steps,link=log)
illness_steps_negbin_with_interactions_plus<-glm.nb(round(Value) ~ body_responsive + illness_catastrophe + Sex + 
                                                      Age + body_responsive:Age + illness_catastrophe:Sex+body_capable:body_responsive + body_capable:medications_to_treat_healthy + 
                                                      body_responsive:illness_catastrophe + body_responsive:Age + illness_catastrophe:Sex+body_responsive:Sex, 
                                                    data=illness_steps,link=log)
  

#Are these models different? No.
anova(illness_steps_negbin_with_interactions_step_res,illness_steps_negbin_with_interactions)



illness_steps_basemodel_interactions<-glm.nb(formula=round(Value) ~body_adversary + body_capable + body_responsive+illness_catastrophe+illness_manageable+ illness_opportunity +Sex+Age+medications_to_treat_healthy+body_responsive:Age + illness_catastrophe:Sex+body_capable:body_responsive + body_capable:medications_to_treat_healthy + 
                                               body_responsive:illness_catastrophe + body_responsive:Age + illness_catastrophe:Sex, 
                                             data=illness_steps,link=log)
summary(illness_steps_basemodel_interactions)





# Machine Learning Approach
## Random Forest



lm_for_ML<-lm(formula=Value_Normalized~body_adversary + body_capable + body_responsive+ 
                illness_catastrophe+illness_manageable+ illness_opportunity+
                Sex +Age + medications_to_treat_healthy +
                body_capable:body_responsive + body_capable:medications_to_treat_healthy + 
                body_responsive:illness_catastrophe + body_responsive:Age + illness_catastrophe:Sex,
              data=illness_steps)
lm_for_ML_step<-stepAIC(lm_for_ML)
lm_for_ML_step_res<-lm(formula = Value_Normalized ~ body_capable + body_responsive + 
                         illness_catastrophe + Sex + Age + medications_to_treat_healthy + 
                         body_capable:medications_to_treat_healthy + body_responsive:Age + 
                         illness_catastrophe:Sex, data = illness_steps)
full_eq_ML<-lm(formula=Value_Normalized~body_adversary + body_capable + body_responsive+ 
                 illness_catastrophe+illness_manageable+ illness_opportunity+
                 Sex +Age + medications_to_treat_healthy +
                 body_capable:medications_to_treat_healthy + body_responsive:Age + 
                 illness_catastrophe:Sex, data = illness_steps)
print(anova(lm_for_ML_step_res,lm_for_ML))
print(anova(lm_for_ML_step_res,full_eq_ML))
print(anova(lm_for_ML,full_eq_ML))


sample <- sample.int(n = nrow(illness_steps), size = floor(.75*nrow(illness_steps)), replace = F)
train <- illness_steps[sample, ]
test  <- illness_steps[-sample, ]
shrinkage_vals<-c(0.1,0.01,0.001,0.0001)
tree_vector<-c(100,200,500,1000)
#shrinkage_vals<-0.01
#tree_vector<-100
first_loop=TRUE
for(tree_n in tree_vector){
  inc_mse_df<-data.frame(colnames(illness_steps[,c(2,3,4,8,9,17)]))
  MSE_result<-data.frame("")
  
  for(val in shrinkage_vals){
    #, interaction=
    illness_steps_rf_norm<-randomForest(formula= Value_Normalized ~ body_capable + body_responsive + 
                                          illness_catastrophe + Sex + Age + medications_to_treat_healthy + 
                                          body_capable:medications_to_treat_healthy + body_responsive:Age + 
                                          illness_catastrophe:Sex,
                                        data=train,importance=T,shrinkage=val,interaction=3,n.tree=tree_n)
    # print(paste0("VAL: ",val))
    # print(importance(illness_steps_rf_norm))
    if(first_loop==TRUE){
      plot(illness_steps_rf_norm,main=val)
    }
    inc_mse_df<-cbind(inc_mse_df,importance(illness_steps_rf_norm)[,1])
    illness_steps_predicted<-predict(illness_steps_rf_norm,newdata = test,n.trees=tree_n)
    mse_illness_steps_MSE<-(sum((illness_steps_predicted - test$Value_Normalized)^2)/length(illness_steps_predicted))
    MSE_result<-cbind(MSE_result,mse_illness_steps_MSE)
  }
  
  inc_mse_df_complete<-inc_mse_df[,-1]
  MSE_result_complete<-MSE_result[,-1]
  colnames(inc_mse_df_complete)<-paste0("tree=",tree_n,",shrinkage=",shrinkage_vals)
  colnames(MSE_result_complete)<-paste0("tree=",tree_n,",shrinkage=",shrinkage_vals)
  print(MSE_result_complete)
  
  #print(mse_illness_steps_MSE)
  colnames(inc_mse_df_complete)<-shrinkage_vals
  melted_mse<-melt(as.matrix(inc_mse_df_complete))
  this_plot<-ggplot(melted_mse,aes(x=X1,y=value,color=as.factor(X2),  group=as.factor(X2)))+
    geom_point()+
    theme(axis.text.x = element_text(angle = 45, hjust = 1))+
    labs(x="",y="%MSE",colour = "Shrinkage")+
    ggtitle(paste0("%MSE vs. Shrinkage for n.tree=",tree_n))+
    geom_line(inherit.aes = T)
  print(this_plot)
  first_loop=FALSE
}
####
# Value_Normalized ~ body_capable + body_responsive + 
#   illness_catastrophe + Sex + Age + medications_to_treat_healthy + 
#   body_capable:medications_to_treat_healthy + body_responsive:Age + 
#   illness_catastrophe:Sex,


illness_steps_rf_norm<-randomForest(formula=  Value_Normalized~body_adversary + body_capable + body_responsive+ 
                                      illness_catastrophe+illness_manageable+ illness_opportunity+
                                      Sex +Age + medications_to_treat_healthy +
                                      body_capable:medications_to_treat_healthy + body_responsive:Age + 
                                      illness_catastrophe:Sex,
                                    data=train,importance=T,shrinkage=0.01,interaction=3,n.tree=100)
illness_steps_gbm_norm<-gbm(formula= Value_Normalized~body_adversary + body_capable + body_responsive+ 
                              illness_catastrophe+illness_manageable+ illness_opportunity+
                              Sex +Age + medications_to_treat_healthy +
                              body_capable:medications_to_treat_healthy + body_responsive:Age + 
                              illness_catastrophe:Sex,
                                    data=train,interaction=3)
full_eq_ML<-lm(formula=Value_Normalized~body_adversary + body_capable + body_responsive+ 
                 illness_catastrophe+illness_manageable+ illness_opportunity+
                 Sex +Age + medications_to_treat_healthy +
                 body_capable:medications_to_treat_healthy + body_responsive:Age + 
                 illness_catastrophe:Sex, data = train)
lasso_normalized_run1<-cv.glmnet(y=train$Value_Normalized,
                                 x=train[,c("body_adversary","body_capable","body_responsive", 
                                          "illness_catastrophe","illness_manageable","illness_opportunity")]
                                  )
illness_steps_lasso<-glmregNB(round(Value)~body_adversary + body_capable + body_responsive+ 
                      illness_catastrophe+illness_manageable+ illness_opportunity+
                      Sex +Age + medications_to_treat_healthy,data=train)

gbm_predicted<-predict(illness_steps_gbm_norm,newdata = test,n.trees = 100)
lm_predicted<-predict(full_eq_ML,test)
rf_predicted<-predict(illness_steps_rf_norm,newdata = test,n.trees=100)
lasso_prediction<-predict(illness_steps_lasso,newdata=test)

predictions<-data.frame("names"=names(rf_predicted),"lm"=as.numeric(lm_predicted),
                   "rf"=as.numeric(rf_predicted),"gbm"=as.numeric(gbm_predicted),
                   "actual"=as.numeric(test$Value_Normalized))
predictions_mse<-cbind("names"=predictions$names,(predictions[,2:4]-predictions$actual)^2)
melted_predictions<-melt(predictions)
melted_predictions_mse<-melt(predictions_mse)
ggplot(melted_predictions,aes(x=names, y=value,color=variable,group=variable))+
  geom_line()+
  ylab("Normalized Steps")+
  ggtitle("Actual vs. Prediction Normalized Values")+
  geom_point()
print(colSums((predictions[,2:4]-predictions$actual)^2))
ggplot(melted_predictions_mse,aes(x=names, y=value,color=variable,group=variable))+
  geom_line()+
  ylab("(observed-actual)^2")+
  ggtitle("Actual vs. Prediction Normalized Values Squared Error")+
geom_point()



### rerun for illness_steps_sick
illness_steps_sick<-illness_steps[illness_steps$medications_to_treat_healthy==FALSE,]
illness_steps_sick_ggpair<-ggpairs(illness_steps_sick[,c(1:9,17)])
#summary statistics sick only
print(illness_steps_sick_ggpair)
illness_steps_healthy<-illness_steps[illness_steps$medications_to_treat_healthy==TRUE,]
illness_steps_healthy_ggpair<-ggpairs(illness_steps_healthy[,c(1:9,17)])
#summary statistics healthy only
print(illness_steps_healthy_ggpair)

print(hist(illness_steps_sick$Value,main="Steps Sick Only",xlab="steps"))
print(hist(illness_steps_healthy$Value,main="Steps Healthy Only",xlab="steps"))
#VIF sick and healthy
print(VIF(illness_steps_healthy_nb))
print(VIF(illness_steps_sick_nb))

illness_steps_sick_nb<-glm.nb(round(Value) ~ body_adversary + body_capable + body_responsive+ 
                                illness_catastrophe+illness_manageable+ illness_opportunity+
                                Sex +Age, 
                              data=illness_steps_sick,link=log)
illness_steps_sick_nb_reduced<-glm.nb(formula = round(Value) ~ body_adversary + Sex, data = illness_steps_sick, 
                                      init.theta = 2.485931594, link = log)

illness_steps_healthy_nb<-glm.nb(round(Value) ~ body_adversary + body_capable + body_responsive+ 
                                   illness_catastrophe+illness_manageable+ illness_opportunity+
                                   Sex +Age, 
                                 data=illness_steps_healthy,link=log)
illness_steps_healthy_nb_reduced<-glm.nb(formula = round(Value) ~ body_adversary + body_responsive + 
                                           illness_catastrophe + Sex, data = illness_steps_healthy, 
                                         init.theta = 2.655737737, link = log)


sig_cor_sick<-get_sig_corr(illness_steps_sick)
sig_cor_healthy<-get_sig_corr(illness_steps_healthy)

illness_steps_sick_nb_int<-glm.nb(round(Value) ~ body_adversary + body_capable + body_responsive+ 
                                illness_catastrophe+illness_manageable+ illness_opportunity+
                                Sex +Age+
                                body_capable:illness_manageable+
                                illness_catastrophe:illness_manageable,
                              data=illness_steps_sick,link=log)
illness_steps_sick_nb_int_reduced<-glm.nb(formula = round(Value) ~ illness_catastrophe + illness_manageable + 
                                            Sex + illness_catastrophe:illness_manageable, data = illness_steps_sick, 
                                          init.theta = 2.636441194, link = log)

illness_steps_healthy_nb_int<-glm.nb(round(Value) ~ body_adversary + body_capable + body_responsive+ 
                                   illness_catastrophe+illness_manageable+ illness_opportunity+
                                   Sex +Age+
                                     body_adversary:illness_catastrophe+body_adversary:illness_manageable + 
                                   body_capable:illness_catastrophe+body_capable:illness_manageable+
                                     illness_catastrophe:illness_manageable  +  
                                     illness_manageable:illness_opportunity,
                                 data=illness_steps_healthy,link=log)
illness_steps_healthy_nb_int_p0.01<-glm.nb(round(Value) ~ body_adversary + body_capable + body_responsive+ 
                                       illness_catastrophe+illness_manageable+ illness_opportunity+
                                       Sex +Age+
                                       body_adversary:illness_catastrophe+body_adversary:illness_manageable +
                                       illness_manageable:illness_opportunity,
                                     data=illness_steps_healthy,link=log)
illness_steps_healthy_nb_int_p0.01_step<-glm.nb(formula = round(Value) ~ body_adversary + body_responsive + 
         illness_catastrophe + Sex, data = illness_steps_healthy, 
       init.theta = 2.655737737, link = log)



ggplot(illness_steps_sick,aes(x=body_responsive,y=Value,col=illness_catastrophe))+
  scale_color_gradient(low="blue", high="red")+
  scale_y_continuous(name="Steps")+
  ggtitle("Steps vs. Body Responsive Nonhealthy")+
  geom_point()


ggplot(illness_steps,aes(x=body_responsive,y=round(Value),
                         color=interaction(heart_disease_healthy,as.factor(Sex)),
                         na.rm = TRUE))+
 # scale_color_gradient(low="blue", high="red")+
  scale_y_continuous(name="Steps")+
  scale_x_continuous(name="Body Responsive Score")+
  ggtitle("Steps vs. Body Responsive")+
  labs(col="Healthy:Sex")+
  scale_color_manual(values=c("#8e3977","#ed90d4","#69bfe5","#39748e"),labels=c("Nonhealthy/F","Healthy/F","Healthy/M","Nonhealthy/M"))+
  geom_point()+ stat_smooth(method =MASS::glm.nb)


ggplot(illness_steps_healthy,aes(x=illness_catastrophe,y=round(Value),
                         color=as.factor(Sex),
                         na.rm = TRUE))+
  #scale_color_gradient(low="blue", high="red")+
  scale_y_continuous(name="Steps")+
  scale_x_continuous(name="Illness Catastrophe Score")+
  ggtitle("Steps vs. Illness Catastrophe Healthy")+
  labs(col="Sex")+
# scale_color_manual(values=c("#8e3977","#39748e"),labels=c("F","M"))+
  scale_color_manual(values=c("#ed90d4","#69bfe5"),labels=c("F","M"))+
  # scale_color_manual(values=c("#8e3977","#ed90d4","#39748e","#69bfe5"),labels=c("Nonhealthy/F","Healthy/F","Nonhealthy/M","Healthy/M"))+
  geom_point()+ stat_smooth(method =MASS::glm.nb)
