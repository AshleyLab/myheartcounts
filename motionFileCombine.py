### Get motion tracker fileIDs
### Combine the files that are from the same health code
### Output files named by HealthCode of the MotionTracker data

import argparse
import sys
import os


## Going to use os.system here which is insecure because it doesn't sanitize input. So
## please don't name files rm -rf /*

parser=argparse.ArgumentParser()
parser.add_argument("-t", help="Input Motion Tracker Table (from R data dump)")
parser.add_argument("-o", default="motion_output", help="Output directory name")
parser.add_argument("-f", default="", help="file prefix for the synapse cache of output files")

args = parser.parse_args()

# First, read in the motion tracker parser

# Dictionary: Keys = healthCodes, Values: list of fileIDs for t
health_codes_names = dict()

motion_table = open(args.t, "r")
header = motion_table.readline().strip().split()

hcode = header.index("healthCode")
fileid = header.index("data.csv")

for mline in motion_table:
	
	msplits = mline.strip().split()
	
	## Get hcode:
	thishcode = msplit[hcode]
	thisid = msplit[fileid]
	if thishcode in heatlh_codes_names:
		health_codes_names[thishcode].append(thisid)
	else:
		health_codes_names[thishcode]= [thisid]
		
### Ok now we have all the IDs for an individual, now we need the absolute file paths
### Then, once we have all of these, we can call 'cat' on this list to make one file. 

for mycode in health_codes_names.keys():
	
	hcodefiles = []
	for q in health_codes_names[mycode]:
		## What is this filepath? 
		## It seems that it is first the last 3 digits of the 'number', then the folder of the 'number'
		
		last3 = q[-3:]
		filepath = args.f + "/" last3 + "/" + q + "/"
		# now need to get the filename there
		files_in_here = os.listdir(filepath)
		
		# I think extend will break my strings? 
		for z in files_in_here:
			hcodefiles.append(filepath + z)
			
	## Ok now we have the absolute path to all the files, time to make a cat string:
	if (len(hcodefiles)==0):
		continue # sanity check
	catstring = " ".join(hcodefiles)
	outfile_name = args.o + "/" + mycode + "_motionTrackAll.csv"
	# Cat files together
	os.system("cat " + catstring + " > " + outfile_name)
	
	# Profit
	

	
		
		
		
		
		
	



	


