from Parameters import * 
from helpers import * 
from datetime import datetime
import os 
from os import listdir 
from os.path import isfile,join 
from dateutil.parser import parse

#reads in a datafile and splits by line 
#replace '\r\n' with '\n' for Linux & Windows compatible newline characters 
def split_lines(fname): 
	data=open(fname,'r').read().replace('\r\n','\n').split('\n')
	if '' in data:
		data.remove('') 

        return data

#reads in a blob file specified with hash notation in a table file 
def parse_blob(blob_hash): 
        top_dir=blob_hash[-3::].lstrip('0') 
        if top_dir=="": 
                top_dir='0' 
        full_dir=synapse_dir+top_dir+'/'+blob_hash
        csv_files=[f for f in listdir(full_dir) if isfile(join(full_dir,f))]
        for f in csv_files: 
                if f.startswith('.'): 
                        continue 
                if f.endswith('clean')==False: 
                        continue 
                else: 
                        #print str(f) 
                        split_data=split_lines(full_dir+'/'+f)
                        return split_data 
#function to parse the file "cardiovascular-motionTracker-v1.tsv"
def parse_motion_tracker(header,data): 
        subject_dict=dict() 
        counter=0 
        for line1 in data[1::]: 
                counter+=1 
                if counter%1000==0: 
                        print "COUNTER:"+str(counter) 
                line1=line1.split('\t') 
                subject=line1[2] 
                blob=line1[8] 
                if blob=="NA": 
                        continue 
                if blob in bad_blobs: 
                        continue 
                data1=parse_blob(blob)
                if data1==None: 
                        print str(blob) 
                        continue 
                while '' in data1: 
                        data1.remove('') 
                num_entries=len(data1)-1
                if num_entries==0: 
                        continue #EMPTY BLOB FILE, IGNORE 
                #try: 
                activities=[] 
                for line in data1[1::]: 
                        line=line.split(',') 
                        if len(line)<2: 
                                continue 
                        activities.append(line[1])
                unknowns=activities.count('unknown') 
                try:
                        first_time_stamp=data1[1].split(',')[0].replace('amZ','').replace('pmZ','') 
                        first_time=parse(first_time_stamp) 
                except: 
                        print str(blob) 
                        
                last_time_stamp=None 
                last_time=None 
                if len(data1)>2:
                        last_time_stamp=data1[-1].split(',')[0].replace('amZ','').replace('pmZ','') 
                        try:
                                last_time=parse(last_time_stamp) 
                        except: 
                                print str(blob) 
                                print str(last_time_stamp) 
                if first_time==None or last_time==None: 
                        print str(blob) # THIS IS A BAD BLOB, WE WANT TO RECORD IT 
                        continue 
                try:
                        if first_time==last_time: 
                                granularity="NA" 
                        else: 
                                granularity=(last_time-first_time).total_seconds()/float(num_entries) 
                except: 
                        print str(blob)+" trying to compare timestamps with offset to those without offset:"+str(first_time_stamp) +" vs "+str(last_time_stamp) 
                        granularity="NA" 
                        continue 
                if subject not in subject_dict: 
                        subject_dict[subject]=[num_entries,unknowns,1,first_time_stamp,last_time_stamp,first_time,last_time,granularity] 
                else: 
                        subject_dict[subject][0]+=num_entries 
                        subject_dict[subject][1]+=unknowns 
                        subject_dict[subject][2]+=1 
                        if first_time < subject_dict[subject][5]: 
                                subject_dict[subject][3]=first_time_stamp 
                                subject_dict[subject][5]=first_time 
                        elif last_time > subject_dict[subject][6]: 
                                subject_dict[subject][4]=last_time_stamp 
                                subject_dict[subject][6]=last_time 
                #except: 
                #         print str(blob) 
                #         continue 
        return subject_dict 

def main():
        from Parameters import * 
	if table_dir.endswith('/')==False: 
		table_dir=table_dir+'/' 
	if synapse_dir.endswith('/')==False: 
		synapse_dir=synapse_dir+'/' 
	table_files=[f for f in listdir(table_dir) if isfile(join(table_dir,f))] 
	#create a dictionary : category --> subject --> [# entries, #unknown,  #sessions, start time, end time,granularity, session length]
	subject_dict=dict()
        subjects=set([])
        all_categories=[]
        survey_dict=dict() #all data from survey tables 
	#iterate through all table files and summarize the metadata  
	for t in table_files:
                if t.startswith('.'): 
                        continue 
                if t.endswith('metadata.tsv'): 
                        continue
                if t in exclude_list:
                        continue
                if t in demographics: 
                        continue 
                print "TABLE:"+str(t)  
                data=split_lines(table_dir+t)
                prefix=t.split('.')[0] 
                header=['']+data[0].split('\t')
                if len(header)<9:
                        continue 
                if header[8]=="data": 
                        header[8]=prefix 
                for c in header[8::]:
                        if c not in subject_dict:
                                all_categories.append(c)
                if t=='cardiovascular-motionTracker-v1.tsv': 
                        motion_track_dict=parse_motion_tracker(header,data[1::])
                        print str(motion_track_dict) 
                else: 
                        continue 
        #GET LIST OF ALL KNOWN SUBJECTS!!
        subjects=open('/home/annashch/intermediate_results/subjects.txt','r').read().split('\n') 
        subjects.remove('') 
        #WRITE ALL THE OUTPUT FILES 
        #############################################
        #############################################
        #MOTION TRACKER FILE# 
        outf=open('/home/annashch/motiontracker.tsv','w') 
        groups=['MotionTrackStartTime','MotionTrackEndTime','MotionTrackNumEntries','MotionTrackSessions','MotionTrackUnknowns','MotionTrackGranularity'] 
        outf.write('Subject') 
        for g in groups: 
                outf.write('\t'+g) 
        outf.write('\n') 
        for s in subjects: 
                outf.write(s) 
                if s not in motion_track_dict: 
                        outf.write('\tNA\tNA\t0\t0\t0\tNA') 
                else: 
                        outf.write('\t'+str(motion_track_dict[s][3])+'\t'+str(motion_track_dict[s][4])+'\t'+str(motion_track_dict[s][0])+'\t'+str(motion_track_dict[s][2])+'\t'+str(motion_track_dict[s][1])+'\t'+str(motion_track_dict[s][7]))
                outf.write('\n') 
if __name__=="__main__": 
	main() 
