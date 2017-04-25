#reads in a datafile and splits by line 
#replace '\r\n' with '\n' for Linux & Windows compatible newline characters 
datadir="/srv/gsfs0/projects/ashley/common/myheart/grouped_timeseries/motiontracker/motiontracker/"
outdir="/srv/gsfs0/projects/ashley/common/myheart/grouped_timeseries/motiontracker_sampled/"

def split_lines(fname): 
	data=open(fname,'r').read().replace('\r\n','\n').split('\n')
	while '' in data:
		data.remove('') 
        return data

def get_day_most_values(day_values):
	most_val_day=None 
	max_ent=0 
	for day in day_values: 
		numentries=len(day_values[day])
		if numentries> max_ent: 
			max_ent=numentries 
			most_val_day=day 
	#print str(day_values[most_val_day])
	return day_values[most_val_day] 
			 
