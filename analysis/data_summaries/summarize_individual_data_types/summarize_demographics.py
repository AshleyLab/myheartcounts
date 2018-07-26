from Parameters import * 
from helpers import * 
from datetime import datetime
import os 
from os import listdir 
from os.path import isfile,join 
from dateutil.parser import parse

def parse_csv(data):
        print "parsing CSV"
        while '' in data:
                data.remove('') 
        #print str(data)
        entries=0
        timestart=0
        timeend=0
        lastentry=None
        granularity=[] 
        unknowns=0
        if len(data)>1:
                print "newline separate format" 
                #the '\n' delimiter is correct
                entries=len(data)-1 #subtract one to account for header
                firsttime=data[1].split(',')[0].replace(' amZ','-05:00').replace(' pmZ','-05:00')
                firsttime=firsttime.lstrip('0') 
                firsttime=parse(firsttime) 
                timestart=(firsttime-parse('2000-01-01T00:00:00-05:00')).total_seconds()
                lasttime=data[-1].split(',')[0].replace(' amZ','-05:00').replace(' pmZ','-05:00')
                lasttime=lasttime.lstrip('0')
                lasttime=parse(lasttime)
                timeend=(lasttime-parse('2000-01-01T00:00:00-05:00')).total_seconds()
                for line in data[1::]:
                        line=line.split(',')
                        if len(line)==1:
                                continue 
                        if line[1]=="unknown":
                                unknowns+=1
                        curtime=line[0].replace(' amZ','-05:00').replace(' pmZ','-05:00')
                        curtime=curtime.lstrip('0')
                        #print str(curtime)
                        curtime=parse(curtime) 
                        if lastentry!=None:
                                try:
                                        granularity.append((curtime-lastentry).total_seconds())
                                except:
                                        lastentry=curtime
                                        
                        lastentry=curtime 
        elif data[0].__contains__('{'):
                #this is a json file, use ',' as the delimiter rather than '\n'
                print "json format" 
                data=data[0]
                data=data.replace('}','')
                data=data.replace('[','')
                data=data.replace(']','')
                data=data.split('{')
                entries=len(data)
                timestart=float(data[0].split(',')[1].split(':')[1])
                timeend=float(data[1].split(',')[1].split(':')[1]) 
                for line in data:
                        curtime=float(line.slpit(',')[1].split(':')[1])
                        if lastentry!=None:
                                granularity.append((curtime-lastentry).total_seconds())
                        lastentry=curtime 
        timespan=timeend-timestart
        granularity=sum(granularity)/float(len(granularity))
        return entries,timespan,granularity,unknowns 

def isHash(value):
        if len(value)!=7:
                return False 
        if value.isdigit():
                return True
        return False 

def write_output(subjects,subject_dict,subject_dict_dem,all_dem_categories,all_categories):
        outf=open(outputf_name,'w')
        dem_categories=all_dem_categories
        categories=all_categories
        metrics=['_entries','_unknowns','_sessions','_duration(s)','_granularity(s)','_session_length(s)']
        #Write the output header file 
        outf.write('healthCode')
        outf.write('\t'+'\t'.join(dem_categories))
        print str(dem_categories['heartAgeDataTotalCholesterol'])
        for c in categories:
                for m in metrics:
                        outf.write('\t'+c+m) 
        outf.write('\n')

        for s in subjects:
                outf.write(s)
                for dem in dem_categories:
                        if s in subject_dict_dem[dem]:
                                outf.write('\t'+','.join(subject_dict_dem[dem][s]))
                        else:
                                outf.write('\t')
                for c in categories:
                        if s in subject_dict[c]:
                                #get the mean granularity and session length 
                                granularity=subject_dict[c][s][5]
                                session_length=subject_dict[c][s][6]
                                mean_granularity=sum(granularity)/float(len(granularity))
                                mean_session_length=sum(session_length)/float(len(session_length))
                                duration=subject_dict[c][s][4]- subject_dict[c][s][3]
                                other_entries=subject_dict[c][s][0:3]
                                outf.write('\t'+'\t'.join([str(i) for i in other_entries])+'\t'+str(duration)+'\t'+str(mean_granularity)+'\t'+str(mean_session_length))
                outf.write('\n')
                
        
 
def main():
        from Parameters import * 
        missingf=open(missingf_name,'w') 
	if table_dir.endswith('/')==False: 
		table_dir=table_dir+'/' 
	if synapse_dir.endswith('/')==False: 
		synapse_dir=synapse_dir+'/' 
	table_files=[f for f in listdir(table_dir) if isfile(join(table_dir,f))] 
        #print "TABLE FILES:"+str(table_files) 
	#create a dictionary : category --> subject --> [# entries, #unknown,  #sessions, start time, end time,granularity, session length]
	subject_dict=dict()
        subject_dict_dem=dict()
        subjects=set([])
        all_dem_categories=[]
        all_categories=[]
	#iterate through all table files and summarize the metadata  
	for t in table_files:
		if t.startswith('.'): 
			continue 
		if t.endswith('metadata.tsv'): 
			continue
                if t in exclude_list:
                        continue 
		print "TABLE:"+str(t)  
		data=split_lines(table_dir+t)
		#print "DATA:"+str(data) 
		if len(data)<2: 
			continue #skip empty table files
                prefix=t.split('.')[0] 
                header=['']+data[0].split('\t')
                if len(header)<9:
                        continue 
		if header[8]=="data": 
			header[8]=prefix 
                isDemographic=False
                if t in demographics:
                        cur_dict=subject_dict_dem
                        isDemographic=True 
                else:
                        continue 
                        cur_dict=subject_dict
                print "isDemographic:"+str(isDemographic) 
                for c in header[8::]:
                        if c not in cur_dict:
                                if isDemographic:
                                        all_dem_categories.append(c)
                                else:
                                        all_categories.append(c) 
                                cur_dict[c]=dict()
                for line in data[1::]:
                        line=line.split('\t')
			#print "line:"+str(line) 
                        healthCode=line[2]
			#print "healthCode:"+str(healthCode) 
                        subjects.add(healthCode) 
                        #get the time entry in seconds since 1-1-2000
                        createdOn=parse(line[5])
                        createdOnSeconds=(createdOn-parse('2000-01-01T00:00:00')).total_seconds()

                        for i in range(8,len(line)):
                                c=header[i]
                                value=line[i]
                                if healthCode not in cur_dict[c]:
                                        if isDemographic:
                                                cur_dict[c][healthCode]=[value]
                                        else:
                                                cur_dict[c][healthCode]=[0,0,1,createdOnSeconds,createdOnSeconds,[],[]] #entries, unknown, sessions, min time, max time, granularity,session length
                                else:
                                        if isDemographic:
                                                cur_dict[c][healthCode].append(value)
                                        else:
                                                cur_dict[c][healthCode][2]+=1
                                                if createdOnSeconds < cur_dict[c][healthCode][3]:
                                                        cur_dict[c][healthCode][3]=createdOnSeconds
                                                elif createdOnSeconds > cur_dict[c][healthCode][4]:
                                                        cur_dict[c][healthCode][4]=createdOnSeconds
                                if isHash(value):
                                        csv_top=value[-3::].lstrip('0')
                                        csv_dir=synapse_dir+csv_top+'/'+value
                                        #if the file  does not exist, add it to the missing list !!!
                                        if os.path.exists(csv_dir)==False:
                                                missingf.write(csv_dir)
                                                continue 

                                        csv_files=[f for f in listdir(csv_dir) if isfile(join(csv_dir,f))]
                                        for f in csv_files:
                                                if f.startswith('.'):
                                                        continue 
                                                data=split_lines(csv_dir+'/'+f)
                                                print "reading in file:"+str(csv_dir+'/'+f) 
                                                entries,timespan,granularity,unknowns=parse_csv(data)
                                                cur_dict[c][healthCode][0]+=entries
                                                cur_dict[c][healthCode][1]+=unknowns
                                                cur_dict[c][healthCode][5].append(granularity)
                                                cur_dict[c][healthCode][6].append(timespan)
                        if isDemographic:
                                subject_dict_dem=cur_dict
                        else:
                                subject_dict=cur_dict
        write_output(subjects,subject_dict,subject_dict_dem,all_dem_categories,all_categories) 

if __name__=="__main__": 
	main() 
