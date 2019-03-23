rm(list=ls())
library(ggplot2)
library(fiftystater)
data("fifty_states")
data=read.table("23andme.us.tally.csv",header=TRUE,sep='\t')
p=ggplot(data,aes(map_id=State))+
  geom_map(aes(fill=Users),map=fifty_states)+
  expand_limits(x=fifty_states$long,y=fifty_states$lat)+
  coord_map()+
  scale_x_continuous(breaks = NULL) + 
  scale_y_continuous(breaks = NULL) +
  labs(x = "", y = "") +
  theme(legend.position = "bottom", 
        panel.background = element_blank())

#p
# add border boxes to AK/HI
p + fifty_states_inset_boxes() 