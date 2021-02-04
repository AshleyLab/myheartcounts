#split samples into three parts:
#training, validation, and testing

rm(list=ls());
options("scipen"=1, "digits"=4, stringsAsFactors=FALSE);

################SET UP#################
#input
input_dat = "dat_sim.txt"
input_demo = "demo_sim.txt"
response_col = "professional-diagnosis"  #response name or No.
sample_col = "healthCode"  #sample name or No.
dat_header = T #if the dat file has a header

#output
response.level = c("Cont", "Case") #to output testing/validation data response as character levels to meet caret requirements
training_output  = "train.dat.rdata"
testing_output  = "testing.XY.rdata"
validation_output  = "validation.XY.rdata"
demo_output = "demo_sim_allocated.txt" # for output the sets

#percentage
training_perc = 0.7
validation_perc = 0.2
testing_perc = 0.1

#if imputation NA with random forest
if_imputation_na = T 
################SET UP#################

source("./split_samples_para.R")

library(PDdream)

demo = r.table(input_demo)
dat = r.table(input_dat,dat_header,1)

#imputation
if (sum(is.na(dat)) > 0 & if_imputation_na )  {
	#!!!rf_impute may change the row names
	#dat2 = rf_impute(dat, demo[,response_col], F)
	for(i in 1:ncol(dat)){
		dat[is.na(dat[,i]), i] <- mean(dat[,i], na.rm = TRUE);
	}
} else {
	dat2 = dat
}

#sorting demo as dat
s.i = match(rownames(dat), demo[,sample_col])
if (sum(is.na(s.i))>0) stop ("Demo not contain all samples names in dat")
demo = demo[s.i,]
#check data
if (length(setdiff(demo[,sample_col], rownames(dat))) != 0 & length(setdiff(rownames(dat), demo[,sample_col])) != 0) 
{
	stop ("Check data or demo files")
}

case.i = which(demo[,response_col])
cont.i = which(!demo[,response_col])
print (table(demo[,response_col]))

#for training
case.train.num = as.integer(length(case.i) * training_perc)
cont.train.num = as.integer(length(cont.i) * training_perc)

set.seed(123)
case.train.i = sample(case.i, case.train.num, replace=F)
set.seed(123)
cont.train.i = sample(cont.i, cont.train.num, replace=F)

#for validation
case.validation.num = as.integer(length(case.i) * validation_perc)
cont.validation.num = as.integer(length(cont.i) * validation_perc)

case.rem.i = setdiff(case.i, case.train.i)
cont.rem.i = setdiff(cont.i, cont.train.i)
length(case.rem.i)
length(cont.rem.i)

set.seed(123)
case.validation.i = sample(case.rem.i, case.validation.num, replace=F)
set.seed(123)
cont.validation.i = sample(cont.rem.i, cont.validation.num, replace=F)

case.rem2.i = setdiff(case.rem.i, case.validation.i)
cont.rem2.i = setdiff(cont.rem.i, cont.validation.i)
length(case.rem2.i)
length(cont.rem2.i)

#for testing
case.test.num = as.integer(length(case.i) * testing_perc)
cont.test.num = as.integer(length(cont.i) * testing_perc)

case.test.i = case.rem2.i
cont.test.i = cont.rem2.i

#dat output
dat$response = rep(NA, nrow(dat))
dat$response[c(case.train.i, case.validation.i, case.test.i)] = 2
dat$response[c(cont.train.i, cont.train.i, cont.validation.i, cont.test.i)] = 1
dat$response = as.factor(dat$response)
levels(dat$response) = response.level

train.dat <- dat[c(case.train.i, cont.train.i),]
validation_dat <- dat[c(case.validation.i, cont.validation.i),]
testing_dat <- dat[c(case.test.i, cont.test.i),]

#output rdata
save(train.dat, file=training_output)
Y = validation_dat$response
X = validation_dat[,-ncol(validation_dat)]
levels(Y) = response.level
save(X, Y, file=validation_output)
Y = testing_dat$response
X = testing_dat[,-ncol(testing_dat)]
levels(Y) = response.level
save(X, Y, file=testing_output)

demo$SampleSet = rep(NA, nrow(demo))
demo$SampleSet[case.train.i] = "case.train"
demo$SampleSet[cont.train.i] = "cont.train"
demo$SampleSet[case.validation.i] = "case.validation"
demo$SampleSet[cont.validation.i] = "cont.validation"
demo$SampleSet[case.test.i] = "case.test"
demo$SampleSet[cont.test.i] = "cont.test"

prop.table(table(demo$SampleSet))
#      case.test      case.train case.validation       cont.test      cont.train 
#        0.02378         0.16359         0.04684         0.07700         0.53584 
#cont.validation 
#        0.15295 

w.table(demo, demo_output, T, F)



