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
parser.add_argument("-b", default="", help="Output the BIG table of minute delimited data")
parser.add_argument("-test", default=0, help="Should I only do the first 100 as a test")
parser.add_argument("-s", default=24*3600, help="Max number of seconds between intervals")

args = parser.parse_args()
csvs = list()
big=0
test = int(args.test)
if (test):
	print "Test mode active, will only output first 100 records"
if (args.b != ""):
	print "Will output the BIG TABLE, this takes increase memory and runtime"
	big = 1
	

# Open up all the files
try:
	filelistfile = open(args.f, "r")
	if (args.t != ""):
		timeout = open(args.t, "w")
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
	if (len(str(year)) < 4): # its the Y2K problem all over again!
		year = year + 2000
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
	
## Need a function to discretize the data by minute, and return that information
## Rounds a datetime to a specific minute
## Going to take the 'closest' activity for each minute in the data 
def roundTime(dt=None, roundTo=60):
   """Round a datetime object to any time laps in seconds
   dt : datetime.datetime object, default now.
   roundTo : Closest number of seconds to round to, default 1 minute.
   Author: Thierry Husson 2012 - Use it as you want but don't blame me.
   From: http://stackoverflow.com/questions/3463930/how-to-round-the-minute-of-a-datetime-object-python
   """
   if dt == None : dt = datetime.datetime.now()
   seconds = (dt - dt.min).seconds
   # // is a floor division, not a comment on following line:
   rounding = (seconds+roundTo/2) // roundTo * roundTo
   return dt + datetime.timedelta(0,rounding-seconds,-dt.microsecond)

def buildTimeSeries(timesort, thistimes):
	""" 
	Function that takes a sorted list of times
	rounds everything to the nearest minute, and then
	it will assign the most common 'activity' to that minute
	"""
	timehash = dict()
	for t in range(0,len(timesort)):
	
		## Remove the out of range times 
		if (timesort[t] < datetime.datetime(2015, 3,1,1,1,1)): # If the year isn't in 2015, something went wrong
			continue
		
		time_round = roundTime(timesort[t])
		## Next, get the current activity
		thisact = thistimes[timesort[t]][0]
		if time_round in timehash and thisact != 0:
			timehash[time_round].append(thisact)
		else:
			timehash[time_round] = [thisact]
	return(timehash)

def most_common(lst):
    return max(set(lst), key=lst.count)


# Now lets import and parse the individual data

# Grab for individuals: total time in each activity type, total time with high confidence, time total, time unknown
# Let's make this a list of lists for each individual
indList = list() 
allrecords = dict()
all_times = set()
# This is a summary of the number of people doing a specific activity at any given
# minutes throughout the day. It will be indexed by the 'minute' and return a 
# vector containing the number of individuals walking, stationary, etc. 
# The vector will be as follows:
# [ missing, act1, act2, act3, act4, act5, total_nonMissing, total]
time_summary = dict()

all_inds = dict()
## Let's loop through each individuals data
i = 0
for c in csvs:
	#print c
	
	## Make sure this is set to the correct REGEX
	recordmatch = re.search(r'(.+).tsv$', c)
	
#	recordmatch = re.search(r'/(.+)\.data.csv$', c)

	
	#print recordmatch
	recordID = recordmatch.group(1)
	thisfile = open(c, "r")
	if (i % 100 == 0):
		print "Analyzing record number: " + str(i) + " out of " + str(len(csvs))
	i +=1
	if (test == 1 and i > 100):
		break
	# Initialize data, we will record times in seconds for ease:
	# first element is ID, second through sixth will be times in each activity, 7th: high conf time, 8: total time, 9: unknown time
	thisrecord = [recordID, 0, 0,0,0,0, 0, 0, 0, "", ""]
	head = thisfile.readline()
	thistimes = dict()
	for line in thisfile:
		splits = line.strip().split("\t")
		if not line.startswith("2015"):
			continue	
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
	if (len(timesort) < 2):
		continue
	#print(max(timesort))
	thisrecord[9] = max(timesort)
	#print(min(timesort))
	thisrecord[10] = min(timesort)
	# This is going to lop off the last timepoint, but whatever?
	for t in range(0,len(timesort)-1):
	
		## I am debating hard-coding 2015 as the year, but we will see...
		if (timesort[t] < datetime.datetime(2015, 1,1,1,1,1)): # If the year isn't in 2015, something went wrong
			continue
		## Thisact = the activity number associated with the current entry
		thisact = thistimes[timesort[t]][0]
		second_diff = (timesort[t+1] - timesort[t]).total_seconds()
		# This gets the total number of seconds that this activity is performed at

		# If it is longer then this time, I don't believe it:
		if (second_diff > int(args.s)):
			continue

		if thisact != 0: # If not unknown, add to summary counts
		
			thisrecord[thisact] +=  second_diff # This gets the seconds
			thisrecord[6] += second_diff
			thisrecord[7] += second_diff
		else:
			thisrecord[7] += second_diff
			thisrecord[8] += second_diff
	
	## Add this record to the dictionary containing all the data for output
	allrecords[thisrecord[0]] = thisrecord

	## Now lets build the time series data:
	thistimehash = buildTimeSeries(timesort, thistimes)
	if (big == 1):
		all_inds[thisrecord[0]] = thistimehash
	for th in thistimehash.keys():
		all_times.add(th)
		if th in time_summary:
			## Find the common activity for the individual at this minute:
			thisact = most_common(thistimehash[th])
		
			## Increment the proper list indexes in the time summary hash
			time_summary[th][thisact] += 1
			time_summary[th][7] += 1
			if thisact != 0:
				time_summary[th][6] += 1
		else:
			# If not in the time summary hash, add it to the hash and do the same procedure
			thisact = most_common(thistimehash[th])
			time_summary[th] = [0]*8
			time_summary[th][thisact] += 1
			time_summary[th][7] += 1
			if thisact != 0:
				time_summary[th][6] += 1
	



### Write output to file
print "Writing Individual Summary data..."
indout.write("\t".join(["healthCode", "SecStationary", "SecWalking", "SecRunning", "SecAutomotive", 
"SecCycling", "SecTotal", "SecTotUnk", "SecUnk", "MaxTime", "MinTime"]) + "\n") 
for r in allrecords.keys():
	indout.write("\t".join(map(str, allrecords[r])) + "\n")

## Write time series data to file
timeout.write("\t".join(["timeID", "Year", "Month", "Day", "Hour", "Minute", "NumUnk", "NumStationary", "NumWalking", "NumRunning", "NumAutomotive", "NumCycling", "NumTotal", "NumTotalUnk"]) + "\n")
times = time_summary.keys()
times.sort()
lastq = times[1]
print "Writing time summary data..."
for q in times:

	while ( (q - lastq).total_seconds() > 61 ):
		new_time = lastq + datetime.timedelta(seconds=60)
		time_list = [new_time.year, new_time.month, new_time.day, new_time.hour, new_time.minute]
		timeout.write(str(new_time) + "\t" + "\t".join(map(str, time_list)) + "\t" + "\t".join(["NA"]*8) + "\n")
		lastq=new_time

	time_list = [q.year, q.month, q.day, q.hour, q.minute]
	timeout.write(str(q) + "\t" + "\t".join(map(str, time_list)) + "\t" + "\t".join(map(str, time_summary[q])) + "\n")
 	lastq = q

	# Profit

# Quit if we aren't outputting the big table
if (big != 1):
	sys.exit()

## Ok, now we need to output the table

big_table = open(args.b, "w")
# Loop through all the possible times:

timelist = list(all_times)
timelist.sort()

## What is the header line for this file?
big_header = ["timeID", "Year", "Month", "Day", "Hour", "Minute"]
inds_in_order = list()
for thisperson in all_inds.keys():
	big_header.append(thisperson)
	inds_in_order.append(thisperson)

print "Writing the big table..."

# Write header row
big_table.write("\t".join(map(str, big_header)) + "\n")

# Each subsequent row represents a time
for t in timelist:
	# For each time:
	bigLineOut = [t, t.year, t.month, t.day, t.hour, t.minute]
	
	for happyperson in inds_in_order:
	# For each individual:
	# Also don't worry about my new variable names
	
		if t in all_inds[happyperson]:
			bigLineOut.append(most_common(all_inds[happyperson][t]))
		# Does this time exist in hash? 
		# Yes: write activity at this time
		# No: write NA
		else:
			bigLineOut.append("NA")
	
	big_table.write("\t".join(map(str,bigLineOut)) + "\n")
	

			
			
	
	





