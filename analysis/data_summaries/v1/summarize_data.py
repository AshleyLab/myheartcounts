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
                else: 
                        return split_lines(full_dir+'/'+f) 


#function to parse survey data files 
def parse_survey(header,data): 
        csv_dict=dict() 
        for f in header[8::]: 
                csv_dict[f]=dict() 
        for line in data: 
                line=line.split('\t') 
                subject=line[0] 
                timestamp=line[5] 
                parsed_time=parse(timestamp) 
                for i in range(8,len(line)):
                        feature=header[i] 
                        value=line[i] 
                        if (value!="NA") and (value!=""): 
                                if subject not in csv_dict[feature]: 
                                        csv_dict[feature][subject]=[timestamp,timestamp,parsed_time,parsed_time,1] 
                                else: 
                                        if parsed_time < csv_dict[feature][subject][2]: 
                                                csv_dict[feature][subject][2]=parsed_time 
                                                csv_dict[feature][sbuejct][0]=timestamp 
                                        elif parsed_time > csv_dict[feature][subject][3]: 
                                                csv_dict[feature][subject][3]=parsed_time 
                                                csv_dict[feature][subject][1]=timestamp 
                                        csv_dict[feature][subject][4]+=1 
        return csv_dict 

#function to parse the file "cardiovascular-HealthKitDataCollector-v1.tsv" 
def parse_health_kit_data_collector(header,data): 
        feature_dict=dict() 
        for line1 in data: 
                line1=line1.split('\t') 
                subject=line1[0] 
                blob=line1[8] 
                data=parse_blob(blob)
                accounted_for=dict() 
                for line in data: 
                        line=line.split(',') 
                        if line[0]=="datetime": 
                                continue 
                        timestamp=line[0] 
                        parsed_time=parse(timestamp) 
                        feature=line[1] 
                        if feature not in feature_dict: 
                                feature_dict[feature]=dict() 
                        if subject not in feature_dict[feature]: 
                                feature_dict[feature][subject]=[timestamp,timestamp,parsed_time,parsed_time,1,1] 
                                accounted_for[tuple([feature,subject])]=1 
                        else: 
                                if parsed_time < feature_dict[feature][subject][2]: 
                                        feature_dict[feature][subject][2]=parsed_time 
                                        feature_dict[feature][sbuejct][0]=timestamp 
                                elif parsed_time > feature_dict[feature][subject][3]: 
                                        feature_dict[feature][subject][3]=parsed_time 
                                        feature_dict[feature][subject][1]=timestamp 
                                feature_dict[feature][subject][4]+=1 
                                if tuple([feature,subject]) not in accounted_for: 
                                        feature_dict[feature][subject][5]+=1 
                                        accounted_for[tuple([feature,subject])]=1 
        return feature_dict 


#function to parse the file "cardiovascular-motionTracker-v1.tsv"
def parse_motion_tracker(header,data): 
        subject_dict=dict() 
        counter=0 
        for line1 in data[1::]: 
                counter+=1 
                if counter%100==0: 
                        print "COUNTER:"+str(counter) 
                line1=line1.split('\t') 
                subject=line1[0] 
                blob=line1[8] 
                if blob=="NA": 
                        continue 
                if blob in bad_blobs: 
                        continue 
                data1=parse_blob(blob)
                while '' in data1: 
                        data1.remove('') 
                num_entries=len(data1)-1
                if num_entries==0: 
                        continue #EMPTY BLOB FILE, IGNORE 
                try: 
                    activities=[] 
                    for line in data1[1::]: 
                            line=line.split(',') 
                            if len(line)<2: 
                                    continue 
                            activities.append(line[1])
                    unknowns=activities.count('unknown') 
                    first_time_stamp=None 
                    first_time=None 
                    last_time_stamp=None 
                    last_time=None
                    last_row=len(data)-1 
                    while last_time==None:
                            try: 
                                    last_time_stamp=data1[last_row].split(',')[0].replace('amZ','').replace(' pmZ','') 
                                    last_time=parse(last_time_stamp) 
                            except: 
                                    last_row-=1 
                                    if last_row < 0: 
                                            break ;
                    first_row=1 
                    while first_time==None: 
                            try: 
                                    first_time_stamp=data1[first_row].split(',')[0].replace(' amZ','').replace(' pmZ','')  
                                    first_time=parse(first_time_stamp)

                            except:  
                                    first_row+=1 
                                    if first_row > len(data1):                                         
                                            break 
                    if first_time==None or last_time==None: 
                            print str(blob) # THIS IS A BAD BLOB, WE WANT TO RECORD IT 
                            continue 
                    if first_time==last_time: 
                            granularity="NA" 
                    else: 
                            granularity=(last_time-first_time).total_seconds() /float(num_entries) 
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
                                    subject_dict[subject][6]=last_Time 
                except: 
                        print str(blob) 
                        continue 
        return subject_dict 

#function to parse the table 'cardiovascular-6MWT Displacement Data-v1.tsv'
def parse_6min_disp(header,data):
        subject_dict=dict() 
        for line1 in data: 
                line1=line1.split('\t') 
                subject=line1[0] 
                blob=line1[8] 
                data=parse_blob(blob)[0]
                num_entries=data.count('}') 
                data=data.split('{') 
                first_time_stamp=data[1].split(',')[-1].split(':')[1].split('\"')[1] 
                last_time_stamp=data[-11].split(',')[-1].split(':')[1].split('\"')[1] 
                first_time=parse(first_time_stamp) 
                last_time=parse(last_time_stamp) 
                granularity=(last_time-first_time).total_seconds()/float(num_entries)
                if subject not in subject_dict: 
                        subject_dict[subject]=[num_entries,1,first_time_stamp,last_time_stamp,first_time,last_time,granularity] 
                else: 
                        subject_dict[subject][0]+=num_entries 
                        subject_dict[subject][1]+=1 
                        if first_time < subject_dict[subject][4]: 
                                subject_dict[subject][2]=first_time_stamp 
                                subject_dict[subject][4]=first_time 
                        elif last_time > subject_dict[subject][5]: 
                                subject_dict[subject][3]=last_time_stamp 
                                subject_dict[subject][5]=last_Time 
        return subject_dict 


#function to parse the table 'cardiovascular-6MinuteWalkTest-v2.tsv'
def parse_6min_walk(header,data): 
        #store entries, sessions, first, last
        pedometer_dict=dict() 
        acceleration_walk_dict=dict() 
        deviceMotion_walk_dict=dict() 
        hr_dict_walk=dict() 
        acceleration_rest_dict=dict() 
        deviceMoton_rest_dict=dict() 
        hr_dict_rest=dict() 
        
        for line1 in data: 
                line1=line1.split('\t') 
                subject=line1[0] 
                #get all 7 blobs 
                ped_blob=line1[8]
                accel_walk_blob=line1[9] 
                dev_mo_walk_blob=line1[10] 
                hr_walk_blob=line1[11]
                accel_rest_blob=line1[12] 
                dev_mo_rest_blob=line1[13] 
                hr_rest_blob=line1[14] 
                if ped_blob!="NA": 
                        data1=parse_blob(ped_blob)[0] 
                        num_entries=data1.count('}') 
                        entry=data1.split('{')[-1].split(',')
                        first_time_stamp=entry[3].split(':')[1].split('\"')[1] 
                        last_time_stamp=entry[3].split(':')[1].split('\"')[1] 
                        first_time=parse(first_time_stamp) 
                        last_time=parse(last_time_stamp) 
                        if subject not in pedometer_dict: 
                                pedometer_dict[subject]=[num_entries,1,first_time_stamp,last_time_stamp,first_time,last_time]
                        else: 
                                pedometer_dict[subject][0]+=num_entries 
                                pedometer_dict[subject][1]+=1 
                                if first_time < pedometer_dict[subject][4]: 
                                        pedometer_dict[subject][2]=first_time_stamp 
                                        pedometer_dict[subject][4]=first_time 
                                elif last_time > pedometer_dict[subject][5]: 
                                        pedometer_dict[subject][3]=last_time_stamp 
                                        pedometer_dict[subject][5]=last_Time 
                if hr_walk_blob!="NA": 
                        data1=parse_blob(hr_walk_blob)[0] 
                        num_entries=data1.count('}') 
                        if subject not in hr_dict_walk: 
                                hr_dict_walk[subject]=[num_entries,1] 
                        else: 
                                hr_dict_walk[subject][0]+=num_entries 
                                hr_dict_walk[subject][1]+=1 
                if hr_rest_blob!="NA": 
                        data1=parse_blob(hr_rest_blob)[0] 
                        num_entries=data1.count('}') 
                        if subject not in hr_dict_rest: 
                                hr_dict_rest[subject]=[num_entries,1] 
                        else: 
                                hr_dict_rest[subject][0]+=num_entries 
                                hr_dict_rest[subject][1]+=1 
 
                if accel_walk_blob!="NA": 
                        data1=parse_blob(accel_walk_blob)[0] 
                        num_entries=data1.count('}') 
                        data1=data1.split('{') 
                        first_time_stamp=data1[1].split(',')[3].split(':')[1].split('\"')[1] 
                        first_time=parse(first_time_stamp) 
                        last_time_stamp=data1[-1].split(',')[2].split(':')[1].split('\"')[1] 
                        last_time=parse(first_time_stamp) 
                        if subject not in acceleration_walk_dict: 
                                acceleration_walk_dict[subject]=[num_entries,1,first_time_stamp,last_time_stamp,first_time,last_time]
                        else: 
                                acceleration_walk_dict[subject][0]+=num_entries 
                                acceleration_walk_dict[subject][1]+=1 
                                if first_time < acceleration_walk_dict[subject][4]: 
                                        acceleration_walk_dict[subject][2]=first_time_stamp 
                                        acceleration_walk_dict[subject][4]=first_time 
                                elif last_time > acceleration_walk_dict[subject][5]: 
                                        acceleration_walk_dict[subject][3]=last_time_stamp 
                                        acceleration_walk_dict[subject][5]=last_Time 

                if accel_rest_blob!="NA": 
                        data1=parse_blob(accel_rest_blob)[0] 
                        num_entries=data1.count('}') 
                        data1=data1.split('{') 
                        first_time_stamp=data1[1].split(',')[3].split(':')[1].split('\"')[1] 
                        first_time=parse(first_time_stamp) 
                        last_time_stamp=data1[-1].split(',')[2].split(':')[1].split('\"')[1] 
                        last_time=parse(first_time_stamp) 
                        if subject not in acceleration_rest_dict: 
                                acceleration_rest_dict[subject]=[num_entries,1,first_time_stamp,last_time_stamp,first_time,last_time]
                        else: 
                                acceleration_rest_dict[subject][0]+=num_entries 
                                acceleration_rest_dict[subject][1]+=1 
                                if first_time < acceleration_rest_dict[subject][4]: 
                                        acceleration_rest_dict[subject][2]=first_time_stamp 
                                        acceleration_rest_dict[subject][4]=first_time 
                                elif last_time > acceleration_rest_dict[subject][5]: 
                                        acceleration_rest_dict[subject][3]=last_time_stamp 
                                        acceleration_rest_dict[subject][5]=last_Time 

                if dev_mo_walk_blob!="NA": 
                        data1=parse_blob(dev_mo_walk_blob)[0] 
                        num_entries=data1.count('}') 
                        data1=data1.split('{') 
                        first_time_stamp=data1[1].split(',')[3].split(':')[1].split('\"')[1] 
                        first_time=parse(first_time_stamp) 
                        last_time_stamp=data1[-1].split(',')[2].split(':')[1].split('\"')[1] 
                        last_time=parse(first_time_stamp) 
                        if subject not in deviceMotion_walk_dict: 
                                deviceMotion_walk_dict[subject]=[num_entries,1,first_time_stamp,last_time_stamp,first_time,last_time]
                        else: 
                                deviceMotion_walk_dict[subject][0]+=num_entries 
                                deviceMotion_walk_dict[subject][1]+=1 
                                if first_time < deviceMotion_walk_dict[subject][4]: 
                                        deviceMotion_walk_dict[subject][2]=first_time_stamp 
                                        deviceMotion_walk_dict[subject][4]=first_time 
                                elif last_time > deviceMotion_walk_dict[subject][5]: 
                                        deviceMotion_walk_dict[subject][3]=last_time_stamp 
                                        deviceMotion_walk_dict[subject][5]=last_Time 

                if dev_mo_rest_blob!="NA": 
                        data1=parse_blob(deve_mo_rest_blob)[0] 
                        num_entries=data1.count('}') 
                        data1=data1.split('{') 
                        first_time_stamp=data1[1].split(',')[3].split(':')[1].split('\"')[1] 
                        first_time=parse(first_time_stamp) 
                        last_time_stamp=data1[-1].split(',')[2].split(':')[1].split('\"')[1] 
                        last_time=parse(first_time_stamp) 
                        if subject not in deviceMotion_rest_dict: 
                                deviceMotion_rest_dict[subject]=[num_entries,1,first_time_stamp,last_time_stamp,first_time,last_time]
                        else: 
                                deviceMotion_rest_dict[subject][0]+=num_entries 
                                deviceMotion_rest_dict[subject][1]+=1 
                                if first_time < deviceMotion_rest_dict[subject][4]: 
                                        deviceMotion_rest_dict[subject][2]=first_time_stamp 
                                        deviceMotion_rest_dict[subject][4]=first_time 
                                elif last_time > deviceMotion_rest_dict[subject][5]: 
                                        deviceMotion_rest_dict[subject][3]=last_time_stamp 
                                        deviceMotion_rest_dict[subject][5]=last_Time 
                
        return pedometer_dict,acceleration_walk_dict,deviceMotion_walk_dict,hr_dict_walk,acceleration_rest_dict,deviceMoton_rest_dict,hr_dict_rest
                        
                
        
 
def main():
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
                #determine which format the file is in, and correspondingly how it should be parsed 
                if t in csv_formats: #survey file 
                        tmp_dict=parse_survery(header,data[1::])
                        for feature in tmp_dict: 
                                survey_dict[feature]=tmp_dict[feature] 

                elif t=='cardiovascular-HealthKitWorkoutCollector-v1.tsv': 
                        health_kit_dict=parse_health_kit_data_collector(header,data[1::])
                elif t=='cardiovascular-motionTracker-v1.tsv': 
                        motion_track_dict=parse_motion_tracker(header,data[1::])
                elif t=='cardiovascular-6MinuteWalkTest-v2.tsv': 
                        pedometer_dict,acceleration_walk_dict,deviceMotion_walk_dict,hr_dict_walk,acceleration_rest_dict,deviceMoton_rest_dict,hr_dict_rest=parse_6min_disp(header,data[1::])
                elif t=='cardiovascular-6MWT Displacement Data-v1.tsv': 
                        d6min_disp_dict=parse_6min_disp(header,data[1::]) 
                else: 
                        print "SHOULD NOT BE HERE!!:"+t
        #GET LIST OF ALL KNOWN SUBJECTS!!
        subjects=open('/home/annashch/intermediate_results/subjects.txt','r').read().split('\n') 
        subjects.remove('') 
        #WRITE ALL THE OUTPUT FILES 
        #############################################
        #SURVEY FILE# 
        outf=open('/home/annashch/survey.tsv','w') 
        features=survey_dict.keys() 
        groups=['_StartTime','_EndTime','_NumEntries'] 
        outf.write('Subject') 
        for f in features: 
                for g in groups: 
                        outf.write('\t'+f+g) 
        outf.write('\n') 
        for s in subjects: 
                outf.write(s) 
                for f in features: 
                        if s not in survey_dict[feature]: 
                                outf.write('\tNA\tNA\t0') 
                        else: 
                                outf.write('\t'+survey_dict[feature][s][0]+'\t'+survey_dict[feature][s][1]+'\t'+str(survey_dict[feature][s][4]))
                outf.write('\n') 
        #############################################
        #HEALTH KIT FILE# #
        outf=open('/home/annashch/healthkit.tsv','w') 
        features=health_kit_dict.keys() 
        groups=['_StartTime','_EndTime','_NumEntries','_Sessions'] 
        outf.write('Subject') 
        for f in features: 
                for g in groups: 
                        outf.write('\t'+f+g) 
        outf.write('\n') 
        for s in subjects: 
                outf.write(s) 
                for f in features: 
                        if s not in health_kit_dict[feature]: 
                                outf.write('\tNA\tNA\t0\t0') 
                        else: 
                                outf.write('\t'+str(health_kit_dict[feature][subject][0])+'\t'+str(health_kit_dict[feature][subject][1])+'\t'+str(health_kit_dict[feature][subject][3])+'\t'+str(health_kit_dict[feature][subject][4]))
                outf.write('\n') 
        #############################################
        #MOTION TRACKER FILE# 
        outf=open('/home/annashch/motiontracker.tsv','w') 
        groups=['StartTime','EndTime','NumEntries','Sessions','Unknowns','Granularity'] 
        outf.write('Subject') 
        for g in groups: 
                outf.write('\t'+g) 
        outf.write('\n') 
        for s in subjects: 
                if s not in motion_track_dict: 
                        outf.write('\tNA\tNA\t0\t0\t0\tNA') 
                else: 
                        outf.write('\t'+str(motion_track_dict[subject][3])+'\t'+str(motion_track_dict[subject][4])+'\t'+str(motion_track_dict[subject][0])+'\t'+str(motion_track_dict[subject][2])+'\t'+str(motion_track_dict[subject][1])+'\t'+str(motion_track_dict[subject][7]))
                outf.write('\n') 
        #############################################
        #6 MINUTE WALK TEST#
        outf=open('/home/annashch/6min_walk.tsv','w') 
        outf.write('Subject\tDisplacement_StartTime\tDisplacement_EndTime\tDisplacement_Entries\tDisplacement_Sessions\tDisplacement_Granularity\t')
        outf.write('Pedometer_StartTime\tPedometer_EndTime\tPedometer_Entries\tPedometer_Sessions\t')
        outf.write('AccelerationWalk_StartTime\tAccelerationWalk_EndTime\tAccelerationWalk_Entries\tAccelerationWalk_Sessions\t')
        outf.write('AccelerationRest_StartTime\tAccelerationRest_EndTime\tAccelerationRest_Entries\tAccelerationRest_Sessions\t') 
        outf.write('HRWalk_Entries\tHRWalk_Sessions\t') 
        outf.write('HRRest_Entries\tHRRest_Sessions\t') 
        outf.write('deviceMotionWalk_StartTime\tdeviceMotionWalk_EndTime\tdeviceMotionWalk_Entries\tdeviceMotionWalk_Sessions\t') 
        outf.write('deviceMotionRest_StartTime\tdeviceMotionRest_EndTime\tdeviceMotionRest_Entries\tdeviceMotionRest_Sessions\n')
        for s in subjects: 
                outf.write(s) 
                if s in d6min_disp_dict:
                        outf.write('\t'+str(d6min_disp_dict[s][2])+'\t'+str(d6min_disp_dict[s][3])+'\t'+str(d6min_disp_dict[s][0])+'\t'+str(d6min_disp_dict[s][1])+'\t'+str(d6min_disp_dict[s][6]))
                else: 
                        outf.write('\tNA\tNA\t0\t0\tNA') 
                if s in pedometer_dict: 
                        outf.write('\t'+str(pedometer_dict[s][2])+'\t'+str(pedometer_dict[s][3])+'\t'+str(pedometer_dict[s][0])+'\t'+str(pedometer_dict[s][1]))
                else: 
                        outf.write('\tNA\tNA\t0\t0') 
                if s in acceleration_walk_dict: 
                        outf.write('\t'+str(acceleration_walk_dict[s][2])+'\t'+str(acceleration_walk_dict[s][3])+'\t'+str(acceleration_walk_dict[s][0])+'\t'+str(acceleration_walk_dict[s][1]))
                else: 
                        outf.write('\tNA\tNA\t0\t0') 
                if s in acceleration_rest_dict: 
                        outf.write('\t'+str(acceleration_rest_dict[s][2])+'\t'+str(acceleration_rest_dict[s][3])+'\t'+str(acceleration_rest_dict[s][0])+'\t'+str(acceleration_rest_dict[s][1]))
                else: 
                        outf.write('\tNA\tNA\t0\t0') 
                if s in hr_dict_walk: 
                        outf.write('\t'+str(hr_dict_walk[s][0])+'\t'+str(hr_dict_walk[s][1]))
                else: 
                        outf.write('\t0\t0') 
                if s in hr_dict_rest: 
                        outf.write('\t'+str(hr_dict_rest[s][0])+'\t'+str(hr_dict_rest[s][1]))
                else: 
                        outf.write('\t0\t0') 
                if s in deviceMotion_walk_dict: 
                        outf.write('\t'+str(deviceMotion_walk_dict[s][2])+'\t'+str(deviceMotion_walk_dict[s][3])+'\t'+str(deviceMotion_walk_dict[s][0])+'\t'+str(deviceMotion_walk_dict[s][1]))
                else: 
                        outf.write('\tNA\tNA\t0\t0') 
                if s in deviceMotion_rest_dict: 
                        outf.write('\t'+str(deviceMotion_rest_dict[s][2])+'\t'+str(deviceMotion_rest_dict[s][3])+'\t'+str(deviceMotion_rest_dict[s][0])+'\t'+str(deviceMotion_rest_dict[s][1]))
                else: 
                        outf.write('\tNA\tNA\t0\t0')                                                 
if __name__=="__main__": 
	main() 
