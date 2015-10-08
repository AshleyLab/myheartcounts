library(data.table)
library(ggplot2)
library(reshape2)

data=data.frame(read.table("steady",header=T,sep='\t'))
#T-test for Basis vs Gold Standard
bm=mean(na.omit(abs(data$Basis_HR-data$GoldStandard_HR)))
bstd=sqrt(var(na.omit(abs(data$Basis_HR-data$GoldStandard_HR))))
power_calcs_basis=c() 
for(i in 2:150)
{
a=power.t.test(n=i,delta=bm,sd=bstd,type="paired")
power_calcs_basis=c(power_calcs_basis,a$power)
}

#T-test for Fitbit vs Gold Standard 
bm=mean(na.omit(abs(data$Fitbit_HR-data$GoldStandard_HR)))
bstd=sqrt(var(na.omit(abs(data$Fitbit_HR-data$GoldStandard_HR))))
power_calcs_fitbit=c() 
for(i in 2:150)
{
  a=power.t.test(n=i,delta=bm,sd=bstd,type="paired")
  power_calcs_fitbit=c(power_calcs_fitbit,a$power)
}


#T-test for microsoft vs Gold Standard 
bm=mean(na.omit(abs(data$Microsoft_HR-data$GoldStandard_HR)))
bstd=sqrt(var(na.omit(abs(data$Microsoft_HR-data$GoldStandard_HR))))
power_calcs_microsoft=c() 
for(i in 2:150)
{
  a=power.t.test(n=i,delta=bm,sd=bstd,type="paired")
  power_calcs_microsoft=c(power_calcs_microsoft,a$power)
}


#T-test for Apple vs Gold Standard 
bm=mean(na.omit(abs(data$Apple_HR-data$GoldStandard_HR)))
bstd=sqrt(var(na.omit(abs(data$Apple_HR-data$GoldStandard_HR))))
power_calcs_Apple=c() 
for(i in 2:150)
{
  a=power.t.test(n=i,delta=bm,sd=bstd,type="paired")
  power_calcs_Apple=c(power_calcs_Apple,a$power)
}
samples=2:150
powers=data.frame(samples,power_calcs_basis,power_calcs_fitbit,power_calcs_microsoft,power_calcs_Apple)
names(powers)=c("N","Basis","Fitbit","Microsoft","Apple")
d=melt(powers,id="N")
p=ggplot(data=d,aes(x=N,y=value,colour=variable))+xlab("N Subjects")+ylab("Power of 2-Tailed Paired T-Test of Device vs. GS")+geom_line()+theme_bw(20)
p+geom_hline(aes(yintercept=0.95))
