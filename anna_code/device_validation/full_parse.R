library(XML)

#READ IN GOLD STANDARD DATA 

#READ IN BASIS DATA 

#READ IN APPLE DATA
apple_hr=c() 
apple_energy=c() 
apple_steps=c() 
apple_startDate=c() 
apple_endDate=c() 
#build apple data frame 
apple_xml=xmlToList(xmlParse("export.xml"))
for(i in 1:length(apple_xml))
{
print(i)
}