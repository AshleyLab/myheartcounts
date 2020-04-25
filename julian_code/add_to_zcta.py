## Calculate Percent of 3 digit zip prefixes that is in each ZCTA

import sys

zcta = open(sys.argv[1], "r")
zcta_lines = zcta.readlines()
### Let's get total population
zip_total = dict()
header_line = zcta_lines[0].strip().split(",")
zpop = header_line.index("ZPOP")
zip5 = header_line.index("ZCTA5")
for zline in zcta_lines[1:len(zcta_lines)]:
	zsplits = zline.strip().split(",")
	zip3 = zsplits[zip5][0:3]
	if zip3 in zip_total:
		zip_total[zip3] += int(zsplits[zpop])
	else:
		zip_total[zip3] =  int(zsplits[zpop])
	

print zcta_lines[0].strip() + ",Z3PCT"
for zline in zcta_lines[1:len(zcta_lines)]:
	zsplits = zline.strip().split(",")
	zip3 = zsplits[zip5][0:3]
	thiszpop = int(zsplits[zpop])
	if (zip_total[zip3]==0):
		print zline.strip() + ",100"
		continue 
	zper = round(float(thiszpop)/float(zip_total[zip3]), 4)*100
	print zline.strip() + "," + str(zper)

