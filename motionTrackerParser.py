### Motion Tracker Parser ###
# Aim:
# Read in motion tracker files
# Output motion tracker summary table and other useful tables

# Two output tables:
# Table 1: Activity by Person
# Table 2: Activity by Time


# Input is going to be a file containing a list of motion tracker .csv files to parse together

import argparse
import sys 
import re
import datetime

# Every time I use this package I think of Monty Python's Argument Clinic
# Will you have the 5 minute argument, the 15 minute argument, or the 30 minute special argument?
parser=argparse.ArgumentParser()
parser.add_argument("-f", help="List of Motion Tracker .csv files to parse")
parser.add_argument("-o", default="", help="Output table of individual delimited data")
parser.add_argument("-t", default="", help="Output table of time delimited data")

args = parser.parse_args()
csvs = list()

# Open up all the files
try:
	filelistfile = open(args.f, "r")
	#if (args.t != ""):
	#	timeout = open(args.t, "w")
	if (args.o != ""):
		indout = open(args.o, "w")
except IOError as e:
	print "Could not open specified files:"
	print "I/O error({0}): {1}".format(e.errno, e.strerror)
	sys.exit(0)	

# This may be redundant but eh
for k in filelistfile:
	csvs.append(k.strip())

def timeStringParse(timestring): 
	"""
	The goal of this function is to parse the time strings from a line in the csv file.
	It will return a list with the following information:
	[Year, Month, Day, Hours, Minutes, Seconds], TimeZone, TimeZoneHours, TimeZone+-
	"""
	regexphell = re.match(r'(\d+)-(\d\d)-(\d\d)T(\d\d):(\d\d):(\d\d)([-+])(\d\d):(00)', timestring)
	if (not regexphell):
		return(None)
	year = int(regexphell.group(1))
	month= int(regexphell.group(2))
	day = int(regexphell.group(3))
	hours = int(regexphell.group(4))
	minutes = int(regexphell.group(5))
	seconds = int(regexphell.group(6))
	thistime = datetime.datetime(year, month, day, hours, minutes, seconds)
	tz = regexphell.group(7) + regexphell.group(8)
	tzh = int(regexphell.group(8))
	tzpm = regexphell.group(7)
	return([thistime, tz, tzh, tzpm])
	

# Now lets import and parse the individual data

# Grab for individuals: total time in each activity type, total time with high confidence, time total, time unknown
# Let's make this a list of lists for each individual
indList = list() 
allrecords = dict()
for c in csvs:
	print c
	recordmatch = re.search(r'/(.+)\.data\.csv$', c)
	#print recordmatch
	recordID = recordmatch.group(1)
	thisfile = open(c, "r")
	# Initialize data, we will record times in seconds for ease:
	# first element is ID, second through sixth will be times in each activity, 7th: high conf time, 8: total time, 9: unknown time
	thisrecord = [recordID, 0, 0,0,0,0, 0, 0, 0]
	head = thisfile.readline()
	thistimes = dict()
	for line in thisfile:
		splits = line.strip().split(",")
		
		# Some lines were weird and contained only a 0, so skip those
		if len(splits) < 5:
			continue
		# Ok now for the fun part
		# We can't assume that the data is in order, so we will need to devise some way to order the data.
		# Can sort the date using the built-in datetime functions
		#print splits[0]
		timeparse = timeStringParse(splits[0])
		if (timeparse==None):
			continue
		# Only keep high and medium confidence intervals:
		if (splits[3]!="low"):
			activity = int(splits[2])
		else:
			activity = 0
		thistimes[timeparse[0]] = [activity, timeparse[1], timeparse[2], timeparse[3]]
	
	## Ok we have read the entire file at this point, and saved data into the thistimes dictionary
	## Now, we need to sort by time, get the time deltas, and add that to the summary:
	
	timesort = sorted(thistimes.keys())
	
	# This is going to lop off the last timepoint, but whatever?
	for t in range(0,len(timesort)-1):
		thisact = thistimes[timesort[t]][0]
		if thisact != 0:
			thisrecord[thisact] += (timesort[t+1] - timesort[t]).total_seconds()
			thisrecord[6] += (timesort[t+1] - timesort[t]).total_seconds()
			thisrecord[7] += (timesort[t+1] - timesort[t]).total_seconds()
		else:
			thisrecord[7] += (timesort[t+1] - timesort[t]).total_seconds()
			thisrecord[8] += (timesort[t+1] - timesort[t]).total_seconds()
	
	allrecords[thisrecord[0]] = thisrecord



### Write output to file
indout.write("\t".join(["recordId", "SecStationary", "SecWalking", "SecRunning", "SecAutomotive", 
"SecCycling", "SecTotal", "SecTotUnk", "SecUnk"]) + "\n") 
for r in allrecords.keys():
	indout.write("\t".join(map(str, allrecords[r])) + "\n")







