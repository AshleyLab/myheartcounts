import sys 
from helpers import *
from os import listdir
from os.path import isfile, join
from dateutil.parser import parse
from datetime import * 
datadir="/srv/gsfs0/projects/ashley/common/myheart/grouped_timeseries/motiontracker/motionactivity/"
outdir="/srv/gsfs0/projects/ashley/common/myheart/grouped_timeseries/motiontracker_sampled/"
#dictionary of activity name to numerical identifier 
activity_names=dict() 
activity_names['not available']="0" 
activity_names['unknown']='0' 
activity_names['stationary']='1'
activity_names['walking']='2'
activity_names['running']='3' 
activity_names['automotive']='4'
activity_names['cycling']='5' 
######################################################

def main():
    print "datadir:"+str(datadir) 
    onlyfiles = [ f for f in listdir(datadir) if isfile(join(datadir,f)) ]
    c=0
    total=str(len(onlyfiles))
    for f in onlyfiles[int(sys.argv[1]):int(sys.argv[2])+1]:
        #if the file has already been sampled from the motiontracker data, continue 
        filetocheck=outdir+f
        if isfile(filetocheck): 
            print "exists!:"+str(f) 
            continue 
        print "new:"+str(f) 
        data=split_lines(datadir+f)
        subject=f.split('.')[0]
        #print str(subject) 
        c+=1
        #print str(c) 
        weekday_records=dict()
        weekend_records=dict()
        last_non_zero=None 
        for line in data:
            line=line.split('\t')
            #print str(line) 
            time=parse(line[0])
            #back-propagate to get rid of 0 (represents unknown value) 
            if len(line)<3: 
                continue 
            val=activity_names[line[1]]            
            if val!="0":
                last_non_zero=val
            elif last_non_zero!=None:
                val=last_non_zero
            else:
                print "dropping 0 at beginning of file!"
                continue
            line[1]=val 
            day_index=date.weekday(time)
            day_only=str(datetime(time.year,time.month,time.day))
            if day_index < 5: #WEEKDAY! 
                if day_index not in weekday_records:
                    weekday_records[day_index]=dict()
                if day_only not in weekday_records[day_index]:
                    weekday_records[day_index][day_only]=['\t'.join(line)] 
                else:
                    weekday_records[day_index][day_only].append('\t'.join(line))
            else:#WEEKEND!
                if day_index not in weekend_records:
                    weekend_records[day_index]=dict()
                if day_only not in weekend_records[day_index]:
                    weekend_records[day_index][day_only]=['\t'.join(line)]
                else:
                    weekend_records[day_index][day_only].append('\t'.join(line))
        ##############################################################
        #print "weekday_records:"+str(weekday_records)
        #print "weekend_records:"+str(weekend_records) 
        if (1 in weekday_records) and (2 in weekday_records): 
            #use Tues-Wed transition
            #print "1 and 2 found!" 
            best_1=get_day_most_values(weekday_records[1])
            best_2=get_day_most_values(weekday_records[2])
            #print str(best_1)
            #print str(best_2) 
        elif (2 in weekday_records) and (3 in weekday_records):
            #use Wed-Thurs transition
            #print "2 and 3 found" 
            best_1=get_day_most_values(weekday_records[2])
            best_2=get_day_most_values(weekday_records[3])
        elif (0 in weekday_records) and (1 in weekday_records):
            #print "0 and 1 found!" 
            #use Mon-Tues transition 
            best_1=get_day_most_values(weekday_records[0])
            best_2=get_day_most_values(weekday_records[1])
        elif (3 in weekday_records) and (4 in weekday_records):
            #print "3 and 4 found" 
            #use Thurs-Friday transition
            best_1=get_day_most_values(weekday_records[3])
            best_2=get_day_most_values(weekday_records[4])
        else:
            #print "no consecutive transition!!"
            #No consecutive weekday transition
            continue 
        best_weekday=best_1+best_2
        if(5 in weekend_records) and (6 in weekend_records):
            print "5 and 6 found!" 
            best_1=get_day_most_values(weekend_records[5])
            best_2=get_day_most_values(weekend_records[6])
        #write outputs
        best_weekend=best_1+best_2
        outf=open(outdir+"weekday/"+subject+".tsv","w")
        outf.write("\n".join(best_weekday))
        outf=open(outdir+"weekend/"+subject+".tsv","w")
        outf.write("\n".join(best_weekend))
            
if __name__=="__main__":
    main() 

