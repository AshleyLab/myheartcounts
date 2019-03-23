rm(list=ls())
library(ggplot2)
library(fiftystater)
data("fifty_states")
data=read.table("v1.us.broadshare.tally",header=TRUE,sep='\t')
p1=ggplot(data,aes(map_id=State))+
  geom_map(aes(fill=Users),map=fifty_states)+
  expand_limits(x=fifty_states$long,y=fifty_states$lat)+
  coord_map()+
  scale_x_continuous(breaks = NULL) + 
  scale_y_continuous(breaks = NULL) +
  labs(x = "", y = "") +
  theme(legend.position = "bottom", 
        panel.background = element_blank())+
  fifty_states_inset_boxes()
p2=ggplot(data,aes(map_id=State))+
  geom_map(aes(fill=log10(Users/StatePop)),map=fifty_states)+
  expand_limits(x=fifty_states$long,y=fifty_states$lat)+
  coord_map()+
  scale_x_continuous(breaks = NULL) + 
  scale_y_continuous(breaks = NULL) +
  labs(x = "", y = "") +
  theme(legend.position = "bottom", 
        panel.background = element_blank())+
  fifty_states_inset_boxes()
