library(tidyverse)
par(mfrow=c(1,1))
data = read_csv('/Users/nicolemoyen/Dropbox/Stanford/AshleyLab/6mwt/cleaned_6mwt.csv')
dim(data)



Age2 = cut(Age, breaks=6)
Age2

data2 = filter(data,Age>17 & Age<91)
data3 = filter(data2, delta_100<300 &  min_gait_speed>0.1 & NonIdentifiableDemographics.json.patientWeightPounds<400 & height >0.5)


data4 = filter(data2, CVdis_dummy != 'NaN')
cor(max_med,Age, use='complete.obs')
cor(median_gait_speed,height,use='complete.obs')
ggplot(data2, aes(Age2, median_gait_speed, color=Age2)) + geom_boxplot()+ geom_jitter(alpha=0.3)
ggplot(data4, aes(CVdis_dummy, median_gait_speed)) + geom_boxplot()+ geom_jitter(col='purple',alpha=0.5)
attach(data)
cor(total_dist,max_gait_speed, use='complete.obs')
dim(data4)
?filter
dim(data2)
boxplot(median_gait_speed)
boxplot(NonIdentifiableDemographics.json.patientWeightPounds)
cor(median_gait_speed,CVdis_dummy,use='complete.obs')
cor(max_gait_speed,height,use='complete.obs')

dim(data2)
names(data2)
boxplot(new.df)
new.df = select(data3, median_gait_speed,max_gait_speed,gs_100,delta_100,max_med,min_gait_speed,min_med,max_min_diff,total_dist,height,chestPain_True,CVdis_dummy,hrtCond_True,
                physCap_True,chPnLstMo_True,joints_True,dizzy_True,RxDrugs_True,vas_dummy,meds_dummy,chestPain_True,famhist_dummy,Female, Age)

wout.gait = select(data3, height,chestPain_True,CVdis_dummy,hrtCond_True,physCap_True,chPnLstMo_True,joints_True,dizzy_True,RxDrugs_True,vas_dummy,meds_dummy,chestPain_True,famhist_dummy,Female, Age)
dim(new.df)
pairs(new.df)
cor.matrix = cor(new.df,method='pearson',use='complete.obs')
(cor.matrix)
round(cor.matrix,2)
summary(new.df)
library(corrplot)
attach(new.df)
plot(min_gait_speed,Age, xlim=c(0.1,2))
par(mfrow=c(1,1))
dim(new.df)
cor.plot = corrplot(cor.matrix, type='upper',order='original',tl.col='black',tl.srt=45)
boxplot(new.df['height'])
plot(Age~max_min_diff)

sixwalk = filter(data2, Age>=40 & Age<=80 & total_dist>100)
dim(sixwalk)
attach(sixwalk)
age.cut = cut(Age, breaks=4)
age.cut
ggplot(sixwalk, aes(age.cut,median_gait_speed, color=age.cut)) + geom_boxplot()+ geom_jitter(alpha=0.3)
ggplot(sixwalk, aes(age.cut,CVdis_dummy, color=age.cut)) + geom_boxplot()+ geom_jitter(alpha=0.3)

attach(sixwalk)
summary(total_dist)

cor(Age,total_dist)
plot(age.cut, CVdis_dummy)
attach(sixwalk)
par(mfrow=c(1,1))
boxplot(total_dist)
summary(total_dist)
sd(total_dist)
dim(sixwalk)

plot(vas_dummy,total_dist)
#bwd regression 
library(leaps)
dim(new.df)
attach(new.df)
length(CVdis_dummy)
train = sample(length(CVdis_dummy),(length(CVdis_dummy)/2))
length(train)
test = -train
train.set = new.df[train, ]
test.set = new.df[test, ]
dim(train.set)
boxplot(total_dist)
dim(wout.gait)
bwd.fit = regsubsets(total_dist~ . , data = new.df, nvmax=8, method = 'backward')

sum.bwd = summary(bwd.fit)
par(mfrow = c(1,3))
plot(sum.bwd$bic,  ylab = 'bic', xlab = '# of variables', type ='b')
plot(sum.bwd$cp, ylab = 'cp', xlab = '# of variables', type = 'b')
plot(sum.bwd$adjr2, ylab = 'adjusted r2', xlab = '# of variables', type = 'b')
length(height)
length(median_gait_speed)
coef(bwd.fit, id=2)

lm.dist = lm(total_dist~ Age + height, data = new.df)
summary(lm.dist)


summary(Age)
.rs.restartR()
summary(sixwalk['CVdis_dummy'])
sixwalk.CV = filter(CVdis_dummy == 0 & CVdis_dummy ==1)
lm.fit = glm(total_dist ~ ., data=sixwalk, family = 'binomial')
?predict
lm.probs = predict(lm.fit,type='response')
mean(lm.probs)
lm.pred=rep(1,(length(CVdis_dummy)/2))
lm.pred[lm.probs>0.5]=0
table(lm.pred,CVdis_dummy)

summary(lm.fit)

plot(max_med, CVdis_dummy)


#cross-validation
library(boot)
lm.fit = lm(total_dist~ .,data = sixwalk)
summary(lm.fit)
cv.glm = cv.glm(data = new.df, glmfit = lm.fit, K = 9)$delta
cv.glm




#creating dummy variables for all conditions listed below to run in logistic regression; if subject doesn't have that condition, they will be assigned a 0, if subject has any of the other conditions they will get a 1. 
"0_0	family_history	 
Do you have a family history of early heart disease?	FALSE	TRUE	
integer 	1=Father or brother; 2=Mother or sister; 3=None of the above

1_0	medications_to_treat	
Do you take medications to treat the following risk factors (indicate all that apply)	FALSE	TRUE	
Integer 	1=To treat and lower cholesterol; 2=To treat hypertension and lower blood pressure; 
3=To treat diabetes/pre-diabetes and lower blood sugar; 4=None of the above

2_0	heart_disease	Have you been diagnosed with any of the below diseases?	FALSE	TRUE
Integer	 1=Heart Attack/Myocardial Infarction ; 2=Heart Bypass Surgery; 3=Coronary Blockage/Stenosis; 4=Coronary Stent/Angioplasty; 
5=Angina (heart chest pains); 6=High Coronary Calcium Score; 7=Heart Failure or CHF; 8=Atrial fibrillation (Afib);
9=Congenital Heart Defect; 10=None of the above

3_0	vascular	Which vascular disease diagnosis have you received?	FALSE	TRUE	
integer	1=Stroke; 2=Transient Ischemic Attack (TIA); 3=Carotid Artery Blockage/Stenosis; 4=Carotid Artery Surgery or Stent; 
5=Peripheral Vascular Disease (Blockage/Stenosis, Surgery, or Stent);6=Abdominal Aortic Aneurysm; 7=None of the above
"
