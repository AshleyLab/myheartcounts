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
census_table <- read.table("zcta_county_rel_10.txt", head=T)
# this table can be found at:
# https://www.census.gov/geo/maps-data/data/relationship.html

##3 Function for mapping values to counties
## Does take some time, however (minutes)
## Zip vector: vector of 3 digit zip does
## Value vec: vector of the desired value
## census_table: ZCTA to County Census relationship table (get the 2010 one)
## Link for census table: https://www.census.gov/geo/maps-data/data/relationship.html
map3DigitZipToCounty <- function(zip_vec, value_vec, census_table) {
  # Function to map zip code to county by the rules stated above
  
  zip_summary <- aggregate(value_vec, by=list(zip_vec), mean)
	names(zip_summary) <- c("zip3", "value")
  ## Now let's expand the zip code data 	
	new_zips <- data.frame(zip5 = unique(census_table$ZCTA5), value=NA)
  ## Loop through the whole data frame
  for (i in 1:length(new_zips$zip5)) {
    ## Loop over all unique zip codes in table
    thiszip3 = floor(new_zips$zip5[i]/100)
    thisvalue = zip_summary$value[zip_summary$zip3==thiszip3]
    if (length(thisvalue)==1) {
      new_zips$value[i] = thisvalue
    } 
   
    #print(i)
	}
  county_frame <- data.frame(countyCode = unique(census_table$GEOID), totalvalue=0, totalweight=0)
  for (j in 1:nrow(new_zips)) {
    ## Get the county code for this zip code
    counties = census_table$GEOID[census_table$ZCTA5==new_zips$zip5[j]]
    weights = census_table$COPOPPCT[census_table$ZCTA5==new_zips$zip5[j]]
    if (is.na(new_zips$value[j]) | new_zips$value[j]==0) {
      next
    }
    
    for (a in 1:length(counties)) {
      county_frame$totalvalue[county_frame$countyCode==counties[a]] = county_frame$totalvalue[county_frame$countyCode==counties[a]] + weights[a]*new_zips$value[j]
      county_frame$totalweight[county_frame$countyCode==counties[a]] = county_frame$totalweight[county_frame$countyCode==counties[a]] + weights[a]
    }
    
    if (j%%1000==0) {
      print(j)
    }
  }
  
  county_frame$value = county_frame$totalvalue/county_frame$totalweight
  county_frame$value[is.nan(county_frame$value)] = NA
  return(county_frame)
}

plotMapCounty <- function(countyData, color_scheme, valueToPlot, levels, nameCountyCode="County.Code", outline_state=TRUE, state_outline_width=2, county_outline_width=0.5) {
  mycolors = brewer.pal(length(levels) - 1, color_scheme)
  countyData$colors = mycolors[as.numeric(cut(countyData[[valueToPlot]], levels))]
  countyData$colors[is.na(countyData$colors)] = "grey"
  county_order =data.frame(polyname=map('county', plot=F)$names, order=1:length(map('county', plot=F)$names) ) 
  
  
  county_wFips = merge(countyData, county.fips, by.x=nameCountyCode, by.y="fips")
  county_merge = merge(county_wFips, county_order, by="polyname", all.y=TRUE)
  county_merge = county_merge[order(county_merge$order),]
  map('county', fill=T, col=as.character(county_merge$colors), lwd=county_outline_width)  
  if (outline_state) {
    map('state',col="black", lwd=state_outline_width,add=T, fill=F)
  }
  
}


county_satisfied <- map3DigitZipToCounty(satisfied_wState$zip, satisfied_wState$satisfiedwith_life, census_table)

countyColors6 = brewer.pal(6, "Blues")


### Now, convert county codes to county, state for maps
data(county.fips)
# Merge with the FIPs data to get names
county_average.fips = merge(county_satisfied, county.fips, by.x="countyCode", by.y="fips")
# Make 'levels' for the color codings
county_average.fips$buckets = as.numeric(cut(county_average.fips$value, c(0,6,6.5,6.7,6.9,7,7.1,7.3,7.5,8,10)))

# Color data by county 
rdbu_county = brewer.pal(10, "RdYlBu")
county_colors_rdbu = data.frame(buckets=c(1:10, NA), color=c(rdbu_county, "grey" ))
county_average.fips.color = merge(county_average.fips, county_colors_rdbu, by="buckets")
county_order =data.frame(polyname=map('county', plot=F)$names, order=1:length(map('county', plot=F)$names) ) 
county_average.fips.color_order = merge(county_average.fips.color, county_order, by="polyname")
county_average.fips.color_order = county_average.fips.color_order[order(county_average.fips.color_order$order),]

## Satisfaction by County
png("SatisfactionByCounty.png", width=2000, height=1600)
happy_levels = c(0,6,6.5,6.7,6.9,7,7.1,7.3,7.5,8,10)
plotMapCounty(county_satisfied, "RdYlBu", "value", happy_levels, "countyCode")
legend('bottomright', legend = c("<6","6 - 6.5","6.5 - 6.7","6.7 - 6.9","6.9 - 7","7 - 7.1","7.2 - 7.3","7.3 - 7.5","7.5 - 8", ">8"), fill=as.character(rdbu_county), cex=3)
title(main="Life Satisfaction by County", cex.main=5)
dev.off()


### Diet by County

diet_satisfy <- merge(dietTable, satisfiedTable, by="healthCode")
diet_satisfy_state <- merge(diet_satisfy, zip_codes, by.x="zip", by.y="prefix")

veggies_use <- subset(diet_satisfy_state, vegetable < 20 & fruit<20)

veggies_county <- map3DigitZipToCounty(veggies_use$zip, veggies_use$vegetable+veggies_use$fruit, census_table)


# Merge diet and satisfaction

ggplot(aes(x=vegetable, y=satisfiedwith_life), data=veggies_use) + geom_point(alpha=0.02, size=8) + theme_bw()

ggplot(aes(x=satisfiedwith_life, y=fruit), data=veggies_use) + geom_point(alpha=0.02, size=8) + theme_bw()

ggplot(aes(x=satisfiedwith_life, y=sugar_drinks), data=veggies_use) + geom_point(alpha=0.02, size=8) + theme_bw()
summary(lm(satisfiedwith_life~sugar_drinks, data=veggies_use))
summary(lm(satisfiedwith_life~vegetable, data=veggies_use))
summary(lm(satisfiedwith_life~vegetable+sugar_drinks+fish+grains, data=veggies_use))

### Risk survey data and state-specific + county specific cardio risk

## How are the users percieving risk vs. actual county risk?

# Cardio data acquired from:
# http://wonder.cdc.gov/controller/datarequest/D76;jsessionid=17B32B4DC511755A8637230350CA6A59
# Search: ICD 113 codes, select only circulatory diseases (I00 - I99)
# Going to use the term ("Major Cardiovascular Disease")

mymap = c("[1]"=1, "[2]"=2, "[3]"=3, "[4]"=4, "[5]"=5)
satisfiedTable$numRisk1 = unname(mymap[satisfiedTable$riskfactors1])
satisfiedTable$numRisk2 = unname(mymap[satisfiedTable$riskfactors2])
satisfiedTable$numRisk3 = unname(mymap[satisfiedTable$riskfactors3])
satisfiedTable$numRisk4 = unname(mymap[satisfiedTable$riskfactors4])

percievedRisk <- data.frame(risk1=satisfiedTable$numRisk1, risk2=satisfiedTable$numRisk2, risk3=satisfiedTable$numRisk3, risk4=satisfiedTable$numRisk4 )
cor_risk = cor(percievedRisk, use="pairwise")

countyRisk_avg1 = map3DigitZipToCounty(satisfiedTable$zip, satisfiedTable$numRisk1, census_table)
countyRisk_avg2 = map3DigitZipToCounty(satisfiedTable$zip, satisfiedTable$numRisk2, census_table)
countyRisk_avg3 = map3DigitZipToCounty(satisfiedTable$zip, satisfiedTable$numRisk3, census_table)
countyRisk_avg4 = map3DigitZipToCounty(satisfiedTable$zip, satisfiedTable$numRisk4, census_table)

countyRisk_avg1$risk1 = countyRisk_avg1$value
countyRisk_avg1$risk2 = countyRisk_avg2$value
countyRisk_avg1$risk3 = countyRisk_avg3$value
countyRisk_avg1$risk4 = countyRisk_avg4$value

countyAllDeaths = read.table("CardioDeath/Underlying Cause of Death, 1999-2013_county.txt", sep="\t", head=T)
# Subset to the code:  Major cardiovascular diseases (I00-I78)
county_cardio = subset(countyAllDeaths, ICD.10.113.Cause.List.Code=="GR113-053")
county_cardio$Crude.Rate[county_cardio$Crude.Rate=="Unreliable"] = NA
county_cardio$Crude.Rate = as.numeric(as.character(county_cardio$Crude.Rate))
## Merge with countyRisk perception:
countyRisk_wRate = merge(county_cardio, countyRisk_avg1, by.x="County.Code", by.y="countyCode")

## Now, let's see the correlation:
summary(lm(risk1 ~ Crude.Rate, data=countyRisk_wRate))
summary(lm(risk2 ~ Crude.Rate, data=countyRisk_wRate))
summary(lm(risk3 ~ Crude.Rate, data=countyRisk_wRate))
summary(lm(risk4 ~ Crude.Rate, data=countyRisk_wRate))




ggplot(aes(x=Crude.Rate, y=risk1), data=countyRisk_wRate) + geom_point() + theme_bw() + labs(y="Average Percieved Risk Respone 1 (1 = low, 5 = high)", x= "CDC Crude Rate of Deaths by Cardio Disease")
ggsave("RiskCounty_q1.pdf", height=6,width=5)
ggplot(aes(x=Crude.Rate, y=risk2), data=countyRisk_wRate) + geom_point() + theme_bw() + labs(y="Average Percieved Risk Respone 2 (1 = low, 5 = high)", x= "CDC Crude Rate of Deaths by Cardio Disease")
ggsave("RiskCounty_q2.pdf", height=6,width=5)
ggplot(aes(x=Crude.Rate, y=risk3), data=countyRisk_wRate) + geom_point() + theme_bw() + labs(y="Average Percieved Risk Respone 3 (1 = low, 5 = high)", x= "CDC Crude Rate of Deaths by Cardio Disease")
ggsave("RiskCounty_q3.pdf", height=6,width=5)
ggplot(aes(x=Crude.Rate, y=risk4), data=countyRisk_wRate) + geom_point() + theme_bw() + labs(y="Average Percieved Risk Respone 4 (1 = low, 5 = high)", x= "CDC Crude Rate of Deaths by Cardio Disease")
ggsave("RiskCounty_q4.pdf", height=6,width=5)

## Get z-scores for each counties risk and z scores for cardiac risk

zscore = function(values) {
  return((values - mean(values, na.rm=T))/sd(values, na.rm=T))
  
} 

countyRisk_wRate$z1 = zscore(countyRisk_wRate$risk1)
countyRisk_wRate$z2 = zscore(countyRisk_wRate$risk2)
countyRisk_wRate$z3 = zscore(countyRisk_wRate$risk3)
countyRisk_wRate$z4 = zscore(countyRisk_wRate$risk4)
countyRisk_wRate$zRate = zscore(countyRisk_wRate$Crude.Rate)

## Counties with the largest deviation in Z-scores
### CHECK THE SIGN ON THIS DEVIATION
countyRisk_wRate$zdev1 = -(countyRisk_wRate$z1 - countyRisk_wRate$zRate)
countyRisk_wRate$zdev2 = -(countyRisk_wRate$z2 - countyRisk_wRate$zRate)
countyRisk_wRate$zdev3 = -(countyRisk_wRate$z3 - countyRisk_wRate$zRate)
countyRisk_wRate$zdev4 = -(countyRisk_wRate$z4 - countyRisk_wRate$zRate)


#levels = c(-10, -4, -2, 0, 2, 4, 10)
levels = c(-10, -4,-2, -1, 0, 1, 2,4, 10)
plotMapCounty(countyRisk_wRate, "RdBu", "zRate", levels)



png("RiskPerc1_vsCardioDeathRate_county.png", height=1600, width=2000)
plotMapCounty(countyRisk_wRate, "RdBu", "zdev1", levels)
title(main="Over the next 10 years how likely do you think it is that you personally will have a heart attack, stroke, or die due to cardiovascular disease? vs. CardioDeaths", cex=5)
legend("bottomright", legend = c("< -4", "-4 to -2", "-2 to 0", "0 to 2", "2 to 4", ">4"), fill=as.character(brewer.pal(length(levels)-1,"RdBu") ), title="Diff in Z score between\nrisk perception and cardio deaths", cex=2.5, box.lwd=0 )
dev.off()
plotMapCounty(countyRisk_wRate, "RdBu", "zdev2", levels)

plotMapCounty(countyRisk_wRate, "RdBu", "zdev3", levels)

plotMapCounty(countyRisk_wRate, "RdBu", "zdev4", levels)

## Let's get the total number of individuals per county:
## Aggregate by 3 digit zip
people_per_code = data.frame(table(satisfied_wState$zip))
names(people_per_code) = c("Zip3", "NumInds")
ggplot(data=people_per_code) + geom_histogram(aes(x=NumInds), binwidth=2) + theme_bw() + labs(x="Number of Individuals", y="Numer of Zip Code Prefixes")
ggsave("HistogramOfIndividualsPerZipCode.pdf", height=6, width=8)
write.table(people_per_code[order(people_per_code$NumInds, decreasing=T),], "IndividualsPerZip3Code.txt", sep="\t", row.names=F, quote=F )

countyInds = map3DigitZipToCounty(people_per_code$Zip3, people_per_code$NumInds, census_table)

ind_levels <- c(0.5,10,25,50,100,200,1000)
png("TotalIndsByCounty.png", height=1600, width=2000)
plotMapCounty(countyInds, "Blues", "value", ind_levels, nameCountyCode="countyCode")
map('state',col="black", lwd=2,add=T, fill=F)
title(main="Number of Individuals per County", cex.main=4)
legend("bottomright", legend=c("None", "1 to 10", "10 to 25", "25 to 50", "50 to 100", "100 to 200", ">200"), fill=c("grey",brewer.pal(length(ind_levels)-1, "Blues")), cex=3, box.lwd=0)
dev.off()
