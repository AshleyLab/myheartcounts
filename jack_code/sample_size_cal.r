#R Sample size calculation for TRANSFORM-HF
library(pwr)
pwr.t.test(d=(500/1000),power=0.8,sig.level=0.05,type="two.sample")
