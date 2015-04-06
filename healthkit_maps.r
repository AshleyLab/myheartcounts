### Script 2 for Parsing MHealth Data

require(synapseClient)
library(ggplot2)
library(reshape2)
synapseLogin()
setwd('/Users/Julian/Documents/AshleyLab/MHealth')

zip_codes = read.table("zips_expanded.txt", sep="\t")
names(zip_codes) = c("prefix", "state_code", "state")

projectId <- "syn3270436"
q <- synQuery(paste("SELECT id, name FROM table WHERE parentId=='", projectId, "'", sep=""))
q

satisfied <- synTableQuery('SELECT * FROM syn3420615')
satisfiedTable <- satisfied@values
diet <- synTableQuery("SELECT * FROM syn3420518")
dietTable <- diet@values
satisfied_wState <- merge(satisfiedTable, zip_codes, by.x="zip", by.y="prefix")
num_per_state = data.frame(table(satisfied_wState$state))
satisfaction_by_state = aggregate(satisfied_wState$satisfiedwith_life, list(satisfied_wState$state), mean, na.rm=T)

ggplot(data=to_order_color) + geom_bar(aes(x=Group.1,y=x), fill=to_order_color$color, col="black", stat="Identity") + theme_bw() + theme(axis.text.x=element_text(angle=90, hjust=1, vjust=0.5), axis.title.x=element_blank()) + labs(y="Satisfied with Life?", title="Satisfaction by State") + ylim(0,10)
ggsave("SatisfiedByState_barplot.pdf")

library(maps)
library(mapdata)
library(mapproj)
?map

library(RColorBrewer)

# ColorBrewerPalette
colors_for_satisfaction = brewer.pal(5, "Blues")

# Cut the states into buckets for colors
satisfaction_by_state$colorBuckets <- as.numeric(cut(satisfaction_by_state$x, c(0,6.7,6.9,7.1,7.3,10)))
satisfaction_by_state$colorBuckets <- as.numeric(cut(satisfaction_by_state$x, c(0,6.7,6.8,6.9,7,7.1,7.2,7.3,10)))

color_frame = data.frame(bucket= 1:length(colors_for_satisfaction),color=colors_for_satisfaction )
st.fips <- state.fips$fips[match(map("state", plot=F)$names, state.fips$polyname)]
satisfaction_by_state$state = tolower(satisfaction_by_state$Group.1)

## Change map names to bare states
maps_names_strip = data.frame(state=gsub(":.+", "", map("state", plot=F)$names), order=1:length(gsub(":.+", "", map("state", plot=F)$names)))
to_order = merge(maps_names_strip, satisfaction_by_state, by="state")
to_order_color = merge(to_order, color_frame, by.x="colorBuckets", by.y="bucket")
to_order_color = to_order_color[order(to_order_color$order),]


pdf("SatisfactionByState_Map_8colors.pdf", height=7, width=10)
map("state", fill=T, col=as.character(to_order_color$color))
legend("bottomright", legend=c("<6.7"," 6.7-6.8"," 6.8-6.9"," 6.9-7.0","7.0-7.1", "7.1-7.2", "7.2-7.3",">7.3" ), fill=as.character(color_frame$color))
title(main="Satisfaction by State")
dev.off()



pdf("SatisfactionByState_Map_5colors.pdf", height=7, width=10)
map("state", fill=T, col=as.character(to_order_color$color))
legend("bottomright", legend=c("<6.7"," 6.7-6.9","6.9-7.1", "7.1-7.3", ">7.3" ), fill=as.character(color_frame$color))
title(main="Satisfaction by State")
dev.off()

# Merge diet and satisfaction

diet_satisfy <- merge(dietTable, satisfiedTable, by="healthCode")
diet_satisfy_state <- merge(diet_satisfy, zip_codes, by.x="zip", by.y="prefix")

plot.heat <- function(counties.map,state.map,z,title=NULL,breaks=NULL,reverse=FALSE,cex.legend=1,bw=.2,col.vec=NULL,plot.legend=TRUE) {
	
  ### Heatmap plotting function from
  ### http://stackoverflow.com/questions/1260965/developing-geographic-thematic-maps-with-r
  ##Break down the value variable
  if (is.null(breaks)) {
    breaks=
      seq(
          floor(min(counties.map@data[,z],na.rm=TRUE)*10)/10
          ,
          ceiling(max(counties.map@data[,z],na.rm=TRUE)*10)/10
          ,.1)
  }
  counties.map@data$zCat <- cut(counties.map@data[,z],breaks,include.lowest=TRUE)
  cutpoints <- levels(counties.map@data$zCat)
  if (is.null(col.vec)) col.vec <- heat.colors(length(levels(counties.map@data$zCat)))
  if (reverse) {
    cutpointsColors <- rev(col.vec)
  } else {
    cutpointsColors <- col.vec
  }
  levels(counties.map@data$zCat) <- cutpointsColors
  plot(counties.map,border=gray(.8), lwd=bw,axes = FALSE, las = 1,col=as.character(counties.map@data$zCat))
  if (!is.null(state.map)) {
    plot(state.map,add=TRUE,lwd=1)
  }
  ##with(counties.map.c,text(x,y,name,cex=0.75))
  if (plot.legend) legend("bottomleft", cutpoints, fill = cutpointsColors,bty="n",title=title,cex=cex.legend)
  ##title("Cartogram")
}


## Let's try county maps

county_fips <- map("county")$names

## Rules for converting zip code prefixes to counties:

# 1. Each zip code 3 letter prefix will assign its average to all 5 number zip codes that it represents.
# 2. Each 5 letter zip code more correspond to one or more county codes. These are represented in the 
# census ZCTA to County ID file
# 3. Each county is assigned a weighted average of each zip codes average that is contained within
# the county based on the 2010 census population data. 
# 4. This means that we will use the POPPT column from the census zip code data for weighting (or 
# equivalently the countyPopPercentage)

map3DigitZipToCounty <- function(zip_vec, value_vec, census_table) {
	
	
	
	
	
	
}


 









## Library maptools
### THIS CODE DIDNT WORK AS EXPECTED, probably problem with .shp files 
library(maptools)
state.map <- readShapeSpatial("cb_2013_us_state_500k/cb_2013_us_state_500k.shp")
zip.map <- readShapeSpatial("ZipCodeShapeFiles/cb_2013_us_zcta510_500k.shp")
zip.map@data$noise <- rnorm(nrow(zip.map@data))
png("map_test.png", width=600)
plot.heat(zip.map, state.map, z="noise",breaks=c(-Inf,-2,-1,0,1,2,Inf))
dev.off()