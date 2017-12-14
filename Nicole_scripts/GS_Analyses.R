library(tidyverse)
library(kernlab)
library(ISLR)
library(tree)
library(leaps)
library(randomForest)
library(gbm)
library(e1071)
library(boot)


anthro =read.csv('/Users/nicolemoyen/Dropbox/Stanford/AshleyLab/6mwt/Final_csvs/anthropometric_final.csv')
names(anthro)

df.use = select(anthro, "chestPain_True", "chPnLstMo_True",  "physCap_True", "hrtCond_True", "RxDrugs_True" ,"dizzy_True" , "joints_True" , "ethnicity" ,"race", "education",
                "vas_dummy","famhist_dummy","CVdis_dummy","meds_dummy","Sex_Male", "Age" , "Ancestry","height")

df.CV = select(anthro, "chestPain_True", "chPnLstMo_True",  "physCap_True", "hrtCond_True", "RxDrugs_True" ,"dizzy_True" , "joints_True" ,
                "vas_dummy","famhist_dummy","CVdis_dummy","meds_dummy","Sex_Male", "Age" ,"height")

df.new = na.omit(df.use)
df.new
dim(df.new)
attach(df.new)


pairs(df.new)
train = sample(1:nrow(df.use),nrow(df.use)/2)
train.df = df.new[train, ]
test.df = df.new[-train, ]

log.reg = glm(CVdis_dummy~ ., data = df.new,subset=train, family='binomial')
summary(log.reg)

set.seed(14)
cv.error = rep(0,10)

glm.fit = glm(CVdis_dummy~ ., data=df.CV, family='binomial')
cv.error = cv.glm(df.CV, glm.fit)
cv.error$delta

cor.matrix = cor(df.CV,method='pearson',use='complete.obs')
(cor.matrix)
round(cor.matrix,2)
library(corrplot)
cor.plot = corrplot(cor.matrix, type='upper',order='original',tl.col='black',tl.srt=45)

lm.CV = lm(CVdis_dummy~ ., data=df.new, subset=train)
summary(lm.CV)
plot(lm.CV)


#bringing in gait speed csv

df.gait = read.csv('/Users/nicolemoyen/Dropbox/Stanford/AshleyLab/6mwt/Final_csvs/overall_gs.csv')
dim(df.gait)
names(df.gait)
attach(df.gait)
df.gait2= filter(df.gait, median_gait_speed>=0.5, min_gait_speed>0.3,delta_100<300, gs_100>=0.5, height>1.0)
dim(df.gait2)
par(mfrow=c(1,3))
attach(df.gait2)
boxplot(median_gait_speed)
boxplot(min_gait_speed)
boxplot(max_gait_speed)
boxplot(delta_100)
boxplot(gs_100)
boxplot(height)
names(df.gait2)
attach(df.gait2)
gait.use = select(df.gait, "chestPain_True","chPnLstMo_True","physCap_True","hrtCond_True","RxDrugs_True", "dizzy_True",
                  "joints_True", "vas_dummy", "famhist_dummy","CVdis_dummy","meds_dummy","Sex_Male","Age", "height","delta_100" ,
                  "max_gait_speed", "total_dist",'median_gait_speed')
pairs(gait.use)
cor(total_dist,median_gait_speed)

gait.subset = select(gait.use, "chestPain_True","chPnLstMo_True","physCap_True","hrtCond_True","RxDrugs_True", "dizzy_True",
                     "joints_True", "vas_dummy", "famhist_dummy","CVdis_dummy","meds_dummy","Sex_Male","Age", "height")

lm.CVdis = lm(min_med~ ., data=gait.subset)
summary(lm.CVdis)
plot(lm.CV)

attach(gait.use)
cor.matrix2 = cor(gait.use2,method='pearson',use='complete.obs')
cor(delta_100,Age, use='complete.obs')
(cor.matrix2)
round(cor.matrix2,2)
par(mfrow=c(1,1))
dim(cor.matrix)
cor.plot2 = corrplot(cor.matrix2, type='upper',order='original',tl.col='black',tl.srt=45)
dim(gait.use)
#trying backward regressions for subset
library(leaps)
train.gs = sample(1:nrow(gait.use), nrow(gait.use)/2)
gs.trainset = gait.use[train.gs,]
test.gs = gait.use[-train.gs, ]
test = -train.gs
attach(gait.use)
CVdis_dummy

bwd.fit = regsubsets(total_dist~ ., data =gs.trainset, nvmax = 16, method='backward')
summary(bwd.fit)

par(mfrow = c(1,3))
plot(summary(bwd.fit)$bic,  ylab = 'bic', xlab = '# of variables', type ='b')
plot(summary(bwd.fit)$cp, ylab = 'cp', xlab = '# of variables', type = 'b')
plot(summary(bwd.fit)$adjr2, ylab = 'adjusted r2', xlab = '# of variables', type = 'b')

summary(bwd.fit)$adjr2
summary(bwd.fit, id=7)
coef(bwd.fit, id=6)


predict = predict(fit.gam, test.set)
mean(predict)

set.seed(14)
cv.err = rep(0,10)
for (i in 1:10){
  dist.fit = glm(total_dist~ famhist_dummy[i]+CVdis_dummy[i]+Sex_Male[i]+chestPain_True[i]+physCap_True[i]+chPnLstMo_True[i], data=gait.use)
  cv.err[i] = cv.glm(gait.use, dist.fit, K=10)$delta[1]

}

gait.use2 = filter(gait.use, delta_100<500)
dim(gait.use2)
attach(gait.use2)
boxplot(delta_100)

#cv glm
set.seed(23)
cv.error.maxgs = rep(0,10)
for (i in 1:10) {
  glm.maxgs = glm(max_gait_speed~ (height+Age+chPnLstMo_True+dizzy_True+famhist_dummy+meds_dummy,i), data =gait.use)
  cv.error.maxgs[i] = cv.glm(gait.use, glm.maxgs, K=10)
}

CV.lin = glm(CVdis_dummy~ delta_100+total_dist+Age, data=gait.use, family='binomial')
summary(CV.lin)
?na.omit
CV= na.omit(CVdis_dummy)
length(CV)
CV
hist(CVdis_dummy)

attach(gait.use2)
CVdis_dummy

boxplot(total_dist)
hist(vas_dummy)
vas_dummy
summary(vas_dummy)
summary(CVdis_dummy)
dim(gait.use2)