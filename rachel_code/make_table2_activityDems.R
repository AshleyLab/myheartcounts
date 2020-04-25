# Rachel Goldfeder

##################################################
## Table 2: Activity Demographics
##################################################

# goal is to read in the data and get mean and SD for 
# 6MW, activity self reported data and, motion tracker data [active, stationary] 




load("Table2.RData")
all = data


### Data cleaning ###
all$Meters[all$Meters>2000] <- NA
all$Age[all$Age>100] <- NA
all$Vig_and_Moder[all$Vig_and_Moder>2000] <- NA
all$sleep_time[all$sleep_time>20] <- NA
all$Active[all$Active>.8] <- NA




males<- all[all$Sex=="Male" & !is.na(all$Sex),]
females<- all[all$Sex=="Female" & !is.na(all$Sex),]
age.lt.30<- all[all$Age<30 & !is.na(all$Age),]
age.30s<- all[all$Age<40 & all$Age>=30 & !is.na(all$Age),]
age.40s<- all[all$Age<50 & all$Age>=40 & !is.na(all$Age),]
age.50s<- all[all$Age<60 & all$Age>=50 & !is.na(all$Age),]
age.60s<- all[all$Age<70 & all$Age>=60 & !is.na(all$Age),]
age.gt.70<- all[all$Age>=70 & !is.na(all$Age),]


###################################
# Medians 
# Note - not in the paper
###################################

#number of steps

median(males$Steps, na.rm=T)
median(females$Steps, na.rm=T)
median(age.lt.30$Steps, na.rm=T)
median(age.30s$Steps, na.rm=T)
median(age.40s$Steps, na.rm=T)
median(age.50s$Steps, na.rm=T)
median(age.60s$Steps, na.rm=T)
median(age.gt.70$Steps, na.rm=T)

sd(males$Steps, na.rm=T)
sd(females$Steps, na.rm=T)
sd(age.lt.30$Steps, na.rm=T)
sd(age.30s$Steps, na.rm=T)
sd(age.40s$Steps, na.rm=T)
sd(age.50s$Steps, na.rm=T)
sd(age.60s$Steps, na.rm=T)
sd(age.gt.70$Steps, na.rm=T)


#distance

median(males$Meters, na.rm=T)
median(females$Meters, na.rm=T)
median(age.lt.30$Meters, na.rm=T)
median(age.30s$Meters, na.rm=T)
median(age.40s$Meters, na.rm=T)
median(age.50s$Meters, na.rm=T)
median(age.60s$Meters, na.rm=T)
median(age.gt.70$Meters, na.rm=T)

sd(males$Meters, na.rm=T)
sd(females$Meters, na.rm=T)
sd(age.lt.30$Meters, na.rm=T)
sd(age.30s$Meters, na.rm=T)
sd(age.40s$Meters, na.rm=T)
sd(age.50s$Meters, na.rm=T)
sd(age.60s$Meters, na.rm=T)
sd(age.gt.70$Meters, na.rm=T)


#active

median(males$Active, na.rm=T)
median(females$Active, na.rm=T)
median(age.lt.30$Active, na.rm=T)
median(age.30s$Active, na.rm=T)
median(age.40s$Active, na.rm=T)
median(age.50s$Active, na.rm=T)
median(age.60s$Active, na.rm=T)
median(age.gt.70$Active, na.rm=T)

sd(males$Active, na.rm=T)
sd(females$Active, na.rm=T)
sd(age.lt.30$Active, na.rm=T)
sd(age.30s$Active, na.rm=T)
sd(age.40s$Active, na.rm=T)
sd(age.50s$Active, na.rm=T)
sd(age.60s$Active, na.rm=T)
sd(age.gt.70$Active, na.rm=T)




#vig and moderate activity

median(males$Vig_and_Moder, na.rm=T)
median(females$Vig_and_Moder, na.rm=T)
median(age.lt.30$Vig_and_Moder, na.rm=T)
median(age.30s$Vig_and_Moder, na.rm=T)
median(age.40s$Vig_and_Moder, na.rm=T)
median(age.50s$Vig_and_Moder, na.rm=T)
median(age.60s$Vig_and_Moder, na.rm=T)
median(age.gt.70$Vig_and_Moder, na.rm=T)

sd(males$Vig_and_Moder, na.rm=T)
sd(females$Vig_and_Moder, na.rm=T)
sd(age.lt.30$Vig_and_Moder, na.rm=T)
sd(age.30s$Vig_and_Moder, na.rm=T)
sd(age.40s$Vig_and_Moder, na.rm=T)
sd(age.50s$Vig_and_Moder, na.rm=T)
sd(age.60s$Vig_and_Moder, na.rm=T)
sd(age.gt.70$Vig_and_Moder, na.rm=T)


# sleep

median(males$sleep_time, na.rm=T)
median(females$sleep_time, na.rm=T)
median(age.lt.30$sleep_time, na.rm=T)
median(age.30s$sleep_time, na.rm=T)
median(age.40s$sleep_time, na.rm=T)
median(age.50s$sleep_time, na.rm=T)
median(age.60s$sleep_time, na.rm=T)
median(age.gt.70$sleep_time, na.rm=T)

sd(males$sleep_time, na.rm=T)
sd(females$sleep_time, na.rm=T)
sd(age.lt.30$sleep_time, na.rm=T)
sd(age.30s$sleep_time, na.rm=T)
sd(age.40s$sleep_time, na.rm=T)
sd(age.50s$sleep_time, na.rm=T)
sd(age.60s$sleep_time, na.rm=T)
sd(age.gt.70$sleep_time, na.rm=T)



###################################
# Means 
# In the paper
###################################

mean(males$Steps, na.rm=T)
mean(females$Steps, na.rm=T)
mean(age.lt.30$Steps, na.rm=T)
mean(age.30s$Steps, na.rm=T)
mean(age.40s$Steps, na.rm=T)
mean(age.50s$Steps, na.rm=T)
mean(age.60s$Steps, na.rm=T)
mean(age.gt.70$Steps, na.rm=T)

sd(males$Steps, na.rm=T)
sd(females$Steps, na.rm=T)
sd(age.lt.30$Steps, na.rm=T)
sd(age.30s$Steps, na.rm=T)
sd(age.40s$Steps, na.rm=T)
sd(age.50s$Steps, na.rm=T)
sd(age.60s$Steps, na.rm=T)
sd(age.gt.70$Steps, na.rm=T)


#distance

mean(males$Meters, na.rm=T)
mean(females$Meters, na.rm=T)
mean(age.lt.30$Meters, na.rm=T)
mean(age.30s$Meters, na.rm=T)
mean(age.40s$Meters, na.rm=T)
mean(age.50s$Meters, na.rm=T)
mean(age.60s$Meters, na.rm=T)
mean(age.gt.70$Meters, na.rm=T)

sd(males$Meters, na.rm=T)
sd(females$Meters, na.rm=T)
sd(age.lt.30$Meters, na.rm=T)
sd(age.30s$Meters, na.rm=T)
sd(age.40s$Meters, na.rm=T)
sd(age.50s$Meters, na.rm=T)
sd(age.60s$Meters, na.rm=T)
sd(age.gt.70$Meters, na.rm=T)


#active

mean(males$Active, na.rm=T)
mean(females$Active, na.rm=T)
mean(age.lt.30$Active, na.rm=T)
mean(age.30s$Active, na.rm=T)
mean(age.40s$Active, na.rm=T)
mean(age.50s$Active, na.rm=T)
mean(age.60s$Active, na.rm=T)
mean(age.gt.70$Active, na.rm=T)

sd(males$Active, na.rm=T)
sd(females$Active, na.rm=T)
sd(age.lt.30$Active, na.rm=T)
sd(age.30s$Active, na.rm=T)
sd(age.40s$Active, na.rm=T)
sd(age.50s$Active, na.rm=T)
sd(age.60s$Active, na.rm=T)
sd(age.gt.70$Active, na.rm=T)




#vig and moderate activity

mean(males$Vig_and_Moder, na.rm=T)
mean(females$Vig_and_Moder, na.rm=T)
mean(age.lt.30$Vig_and_Moder, na.rm=T)
mean(age.30s$Vig_and_Moder, na.rm=T)
mean(age.40s$Vig_and_Moder, na.rm=T)
mean(age.50s$Vig_and_Moder, na.rm=T)
mean(age.60s$Vig_and_Moder, na.rm=T)
mean(age.gt.70$Vig_and_Moder, na.rm=T)

sd(males$Vig_and_Moder, na.rm=T)
sd(females$Vig_and_Moder, na.rm=T)
sd(age.lt.30$Vig_and_Moder, na.rm=T)
sd(age.30s$Vig_and_Moder, na.rm=T)
sd(age.40s$Vig_and_Moder, na.rm=T)
sd(age.50s$Vig_and_Moder, na.rm=T)
sd(age.60s$Vig_and_Moder, na.rm=T)
sd(age.gt.70$Vig_and_Moder, na.rm=T)


# sleep

mean(males$sleep_time, na.rm=T)
mean(females$sleep_time, na.rm=T)
mean(age.lt.30$sleep_time, na.rm=T)
mean(age.30s$sleep_time, na.rm=T)
mean(age.40s$sleep_time, na.rm=T)
mean(age.50s$sleep_time, na.rm=T)
mean(age.60s$sleep_time, na.rm=T)
mean(age.gt.70$sleep_time, na.rm=T)

sd(males$sleep_time, na.rm=T)
sd(females$sleep_time, na.rm=T)
sd(age.lt.30$sleep_time, na.rm=T)
sd(age.30s$sleep_time, na.rm=T)
sd(age.40s$sleep_time, na.rm=T)
sd(age.50s$sleep_time, na.rm=T)
sd(age.60s$sleep_time, na.rm=T)
sd(age.gt.70$sleep_time, na.rm=T)












#N's
summary(males$Meters)
summary(males$sleep_time)
summary(males$Active)
summary(females$Meters)
summary(females$sleep)
summary(females$Active)
summary(age.lt.30$Meters)
summary(age.lt.30$sleep)
summary(age.lt.30$Active)
summary(age.30s$Meters)
summary(age.30s$sleep)
summary(age.30s$Active)
summary(age.40s$Meters)
summary(age.40s$sleep)
summary(age.40s$Active)
summary(age.50s$Meters)
summary(age.50s$sleep)
summary(age.50s$Active)
summary(age.60s$Meters)
summary(age.60s$sleep)
summary(age.60s$Active)
summary(age.gt.70$Meters)
summary(age.gt.70$sleep)
summary(age.gt.70$Active)



