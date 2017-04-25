import sys 
from helpers import *
from os import listdir
from os.path import isfile, join
from dateutil.parser import parse
from datetime import * 
datadir="/srv/gsfs0/projects/ashley/common/myheart/grouped_timeseries/motiontracker/motiontracker/"
#outdir="/srv/gsfs0/projects/ashley/common/myheart/grouped_timeseries/motiontracker_sampled/"

######################################################

def main():
    outf=open("/srv/gsfs0/projects/ashley/common/myheart/results/feature_dataframes/activity_proportions_full.tsv"+"_HIGHCONF_"+sys.argv[1]+"_"+sys.argv[2],'w')    
    outf.write("Subject\tUnknownWeekend\tUnknownWeekday\tUnknownTotal\tStationaryWeekend\tStationaryWeekday\tStationaryTotal\tAutomotiveWeekend\tAutomotiveWeekday\tAutomotiveTotal\tWalkingWeekend\tWalkingWeekday\tWalkingTotal\tCyclingWeekend\tCyclingWeekday\tCyclingTotal\tRunningWeekend\tRunningWeekday\tRunningTotal\tTotalWeekendEntries\tTotalWeekdayEntries\tTotalEntries\tDuration\n")
    print "datadir:"+str(datadir) 
    onlyfiles = [ f for f in listdir(datadir) if isfile(join(datadir,f)) ]
    total=str(len(onlyfiles))
    unknown_weekday=dict()
    unknown_weekend=dict() 
    unknown_total=dict() 

    weekday_records=dict()
    weekend_records=dict()
    total_records=dict() 
    
    for f in onlyfiles[int(sys.argv[1]):int(sys.argv[2])+1]:
        print str(f) 
        data=split_lines(datadir+f)
        subject=f.split('.')[0]
        unknown_weekday[subject]=0 
        unknown_weekend[subject]=0 
        unknown_total[subject]=0 
        weekday_records[subject]=dict() 
        weekend_records[subject]=dict() 
        total_records[subject]=dict() 
        total_entries=len(data) 
        total_weekend_entries=0 
        total_weekday_entries=0 
        #get the duration in seconds 
        try:
            startTime=parse(data[0].split('\t')[0])
            gotEnd=False
            endIndex=-1 
            while (not gotEnd): 
                try:
                    endTime=parse(data[endIndex].split('\t')[0]) 
                    gotEnd=True 
                except: 
                    endIndex=endIndex-1 
            duration=(endTime-startTime).total_seconds() 
        except: 
            continue 
        last_non_zero=None 
        for line in data:
            line=line.split('\t')
            if len(line)<5: 
                continue
            try:
                time=parse(line[0])
            except: 
                continue 
            val=line[2]
            conf=line[4] 
            if conf!="2": 
                continue 
            if val!="0":
                last_non_zero=val
                masked=val 
            elif last_non_zero!=None:
                masked=last_non_zero
            else:
                print "dropping 0 at beginning of file!"
                continue
            day_index=date.weekday(time)
            day_only=str(datetime(time.year,time.month,time.day))
            if day_index < 5: #WEEKDAY! 
                total_weekday_entries+=1 
                if val=="0": 
                    unknown_weekday[subject]+=1 
                if masked not in weekday_records[subject]: 
                    weekday_records[subject][masked]=1
                else: 
                    weekday_records[subject][masked]+=1 
                
            else:#WEEKEND!
                total_weekend_entries+=1 
                if val=="0": 
                    unknown_weekend[subject]+=1 
                if masked not in weekend_records[subject]: 
                    weekend_records[subject][masked]=1 
                else: 
                    weekend_records[subject][masked]+=1 
            #TOTAL DAYS,  NOT SPLITTING BY WEEKDAY OR WEEKEND 
            if val=="0": 
                unknown_total[subject]+=1
            if masked not in total_records[subject]: 
                total_records[subject][masked]=1
            else: 
                total_records[subject][masked]+=1 
        #GET THE FRACTIONS
        if total_entries==0: 
            continue 
        total_fract_unknown=round(float(unknown_total[subject])/total_entries,2)
        weekend_fract_unknown=0 
        if total_weekend_entries >0: 
            weekend_fract_unknown=round(float(unknown_weekend[subject])/total_weekend_entries,2) 
        weekday_fract_unknown=0 
        if total_weekday_entries>0: 
            weekday_fract_unknown=round(float(unknown_weekday[subject])/total_weekday_entries,2)
        
        total_fract_stationary=0 
        weekday_fract_stationary=0 
        weekend_fract_stationary=0 
        if '1' in total_records[subject]: 
            total_fract_stationary=round(float(total_records[subject]['1'])/total_entries,2)
        if ('1' in weekend_records[subject]) and (total_weekend_entries>0): 
            weekend_fract_stationary=round(float(weekend_records[subject]['1'])/total_weekend_entries,2)
        if ('1' in weekday_records[subject]) and (total_weekday_entries>0): 
            weekday_fract_stationary=round(float(weekday_records[subject]['1'])/total_weekday_entries,2) 
        
        total_fract_automotive=0 
        weekend_fract_automotive=0 
        weekday_fract_automotive=0 
        if '4' in total_records[subject]: 
            total_fract_automotive=round(float(total_records[subject]['4'])/total_entries,2)
        if ('4' in weekend_records[subject]) and (total_weekend_entries>0): 
            weekend_fract_automotive=round(float(weekend_records[subject]['4'])/total_weekend_entries,2) 
        if ('4' in weekday_records[subject]) and (total_weekday_entries>0): 
            weekday_fract_automotive=round(float(weekday_records[subject]['4'])/total_weekday_entries,2) 
        
        total_fract_walking=0 
        weekend_fract_walking=0 
        weekday_fract_walking=0 
        if '2' in total_records[subject]: 
            total_fract_walking=round(float(total_records[subject]['2'])/total_entries,2) 
        if ('2' in weekend_records[subject]) and (total_weekend_entries>0): 
            weekend_fract_walking=round(float(weekend_records[subject]['2'])/total_weekend_entries,2)
        if ('2' in weekday_records[subject]) and (total_weekday_entries>0): 
            weekday_fract_walking=round(float(weekday_records[subject]['2'])/total_weekday_entries,2) 
        
        total_fract_running=0 
        weekend_fract_running=0 
        weekday_fract_running=0 
        if '3' in total_records[subject]: 
            total_fract_running=round(float(total_records[subject]['3'])/total_entries,2) 
        if ('3' in weekend_records[subject]) and (total_weekend_entries>0): 
            weekend_fract_running=round(float(weekend_records[subject]['3'])/total_weekend_entries,2)
        if ('3' in weekday_records[subject]) and (total_weekday_entries >0): 
            weekday_fract_running=round(float(weekday_records[subject]['3'])/total_weekday_entries,2) 
        
        total_fract_cycling=0 
        weekend_fract_cycling=0 
        weekday_fract_cycling=0 
        if '5' in total_records[subject]: 
            total_fract_cycling=round(float(total_records[subject]['5'])/total_entries,2) 
        if ('5' in weekend_records[subject]) and (total_weekend_entries >0): 
            weekend_fract_cycling=round(float(weekend_records[subject]['5'])/total_weekend_entries,2) 
        if ('5' in weekday_records[subject]) and (total_weekday_entries>0): 
            weekday_fract_cycling=round(float(weekday_records[subject]['5'])/total_weekday_entries,2) 
        
        #WRITE TO THE OUTPUT FILE 
        outf.write(subject+'\t'+str(weekend_fract_unknown)+'\t'+str(weekday_fract_unknown)+'\t'+str(total_fract_unknown)+'\t'+str(weekend_fract_stationary)+'\t'+str(weekday_fract_stationary)+'\t'+str(total_fract_stationary)+'\t'+str(weekend_fract_automotive)+'\t'+str(weekday_fract_automotive)+'\t'+str(total_fract_automotive)+'\t'+str(weekend_fract_walking)+'\t'+str(weekday_fract_walking)+'\t'+str(total_fract_walking)+'\t'+str(weekend_fract_cycling)+'\t'+str(weekday_fract_cycling)+'\t'+str(total_fract_cycling)+'\t'+str(weekend_fract_running)+'\t'+str(weekday_fract_running)+'\t'+str(total_fract_running)+"\t"+str(total_weekend_entries)+'\t'+str(total_weekday_entries)+'\t'+str(total_entries)+'\t'+str(duration)+'\n')  
if __name__=="__main__":
    main() 

