rm(list=ls())
library(pwr)
N=1000
alpha=0.05 
method="paired"
effects=seq(0,1,0.01)
powers=seq(0.06,0.99,0.01)
power_results=c() 
effect_results=c() 
for (e in effects){
  cur_power=pwr.t.test(n=N,d=e,sig.level=alpha,type=method)
  effect_results=append(effect_results,e)
  power_results=append(power_results,cur_power$power)
}
  
for (p in powers){
  cur_effect=pwr.t.test(n=N,sig.level=alpha,power=p,type=method)
  effect_results=append(effect_results,cur_effect$d)
  power_results=append(power_results,p)
}

df=data.frame(effect_results,power_results)
names(df)=c("Effect","Power")
attach(df)
df<-df[order(Effect),]
df=df[1:106,]
library(ggplot2)
p=ggplot(df,aes(x=Effect,y=Power))+
  geom_line()+
  ggtitle("power vs effect for N=1000 subjects, paired T-test")+
  theme_bw(20)

