## Fix three digit zip code

import sys

zipin = open(sys.argv[1], "r")


zip_Frame = dict()
for zline in zipin:
	zsplits = zline.strip().split(",")
	zrange = map(int,zsplits[0].split("-"))
	
	this_range = range(zrange[0], zrange[1] +1) 	
	for k in this_range:
		zip_Frame[k] = zsplits[1] + "\t" + zsplits[2]
	
	
myzips = zip_Frame.keys()
myzips.sort()
for q in myzips:
	print(str(q) + "\t" + str(zip_Frame[q]))
	
