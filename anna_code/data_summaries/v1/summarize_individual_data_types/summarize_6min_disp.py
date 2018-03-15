from Parameters import * 
from helpers import * 
from datetime import datetime
import os 
from os import listdir 
from os.path import isfile,join 
from dateutil.parser import parse
import json 
import pickle 
import sys 

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
                if f.endswith('.clean')==False: 
                        continue 
                else: 
                    inputfname=full_dir+'/'+f
                    data=open(inputfname).read() 
                    return data # slightly modified version does not call split lines because we want to preserve the json structure 
        return None 



#function to parse the table 'cardiovascular-6MWT Displacement Data-v1.tsv'
def parse_6min_disp(header,data):
        subject_dict=dict() 
        for line1 in data: 
                line1=line1.split('\t') 
                subject=line1[2] 
                blob=line1[8] 
                data=parse_blob(blob)
                if data==None: 
                        continue 
                json_object=json.loads(data) 
                num_entries=len(json_object) 
                if num_entries==0: 
                        continue 
                first_time_stamp=json_object[0].get('timestamp')
                first_time=parse(first_time_stamp) 
                last_time_stamp=json_object[-1].get('timestamp')
                last_time=parse(last_time_stamp) 
                granularity=(last_time-first_time)/num_entries
                if subject not in subject_dict: 
                        subject_dict[subject]=[num_entries,1,first_time,last_time,granularity] 
                else: 
                        subject_dict[subject][0]+=num_entries 
                        subject_dict[subject][1]+=1 
                        if first_time < subject_dict[subject][2]: 
                                subject_dict[subject][2]=first_time
                        elif last_time > subject_dict[subject][3]: 
                                subject_dict[subject][3]=last_time
        return subject_dict 


#function to parse the table 'cardiovascular-6MinuteWalkTest-v2.tsv'
def parse_6min_walk(header,data): 
        #store entries, sessions, first, last
        pedometer_dict=dict() 
        acceleration_walk_dict=dict() 
        deviceMotion_walk_dict=dict() 
        hr_dict_walk=dict() 
        acceleration_rest_dict=dict() 
        deviceMotion_rest_dict=dict() 
        hr_dict_rest=dict() 
        counter=0
        for line1 in data:
                counter+=1 
                if counter%100==0: 
                        print str(counter) 
                line1=line1.split('\t') 
                subject=line1[2] 
                #get all 7 blobs 
                ped_blob=line1[8]
                accel_walk_blob=line1[9] 
                dev_mo_walk_blob=line1[10] 
                hr_walk_blob=line1[11]
                accel_rest_blob=line1[12] 
                dev_mo_rest_blob=line1[13] 
                hr_rest_blob=line1[14] 
                #PEDOMETER BLOB 
                try: 
                    if ped_blob!="NA": 
                            data1=parse_blob(ped_blob)
                            json_object=json.loads(data1)
                            #print str(json_object) 
                            num_entries=len(json_object) 
                            if num_entries ==0: 
                                    raise Exception()
                            first_time=parse(json_object[-1].get('startDate'))
                            last_time=parse(json_object[-1].get('endDate')) 
                            if subject not in pedometer_dict: 
                                    pedometer_dict[subject]=[num_entries,1,first_time,last_time]
                            else: 
                                    pedometer_dict[subject][0]+=num_entries 
                                    pedometer_dict[subject][1]+=1 
                                    if first_time < pedometer_dict[subject][2]: 
                                            pedometer_dict[subject][2]=first_time
                                    elif last_time > pedometer_dict[subject][3]: 
                                            pedometer_dict[subject][3]=last_time
                except: 
                        #print "did not parse blob:"+str(ped_blob) 
                        pass

                try:
                    if hr_walk_blob!="NA": 
                            data1=parse_blob(hr_walk_blob)
                            #print str(data1) 
                            json_object=json.loads(data1) 
                            num_entries=len(json_object) 
                            if num_entries==0: 
                                    raise Exception() 
                            if subject not in hr_dict_walk: 
                                    hr_dict_walk[subject]=[num_entries,1] 
                            else: 
                                    hr_dict_walk[subject][0]+=num_entries 
                                    hr_dict_walk[subject][1]+=1 
                except: 
                        #print "did not parse blob:"+str(hr_walk_blob) 
                        pass
                try:
                    if hr_rest_blob!="NA": 
                            data1=parse_blob(hr_rest_blob)
                            json_object=json.loads(data1) 
                            num_entries=len(json_object) 
                            if num_entries==0: 
                                    raise Exception() 
                            if subject not in hr_dict_rest: 
                                    hr_dict_rest[subject]=[num_entries,1] 
                            else: 
                                    hr_dict_rest[subject][0]+=num_entries 
                                    hr_dict_rest[subject][1]+=1 
                except: 
                        #print "did not parse blob:"+str(hr_rest_blob) 
                        pass
                try:
                    if accel_walk_blob!="NA": 
                            data1=parse_blob(accel_walk_blob)
                            json_object=json.loads(data1) 
                            num_entries=len(json_object) 
                            if num_entries==0: 
                                    raise Exception() 
                            first_time=json_object[0].get('timestamp')
                            last_time=json_object[-1].get('timestamp') 
                            if subject not in acceleration_walk_dict: 
                                    acceleration_walk_dict[subject]=[num_entries,1,first_time,last_time]
                            else: 
                                    acceleration_walk_dict[subject][0]+=num_entries 
                                    acceleration_walk_dict[subject][1]+=1 
                                    if first_time < acceleration_walk_dict[subject][2]: 
                                            acceleration_walk_dict[subject][2]=first_time
                                    elif last_time > acceleration_walk_dict[subject][3]: 
                                            acceleration_walk_dict[subject][3]=last_time
                except: 
                        #print "did not parse blob:"+str(accel_walk_blob) 
                        pass
                try:
                    if accel_rest_blob!="NA": 
                            data1=parse_blob(accel_rest_blob)
                            json_object=json.loads(data1) 
                            num_entries=len(json_object) 
                            if num_entries==0: 
                                    raise Exception() 
                            first_time=json_object[0].get('timestamp')
                            last_time=json_object[-1].get('timestamp') 
                            if subject not in acceleration_rest_dict: 
                                    acceleration_rest_dict[subject]=[num_entries,1,first_time,last_time]
                            else: 
                                    acceleration_rest_dict[subject][0]+=num_entries 
                                    acceleration_rest_dict[subject][1]+=1 
                                    if first_time < acceleration_rest_dict[subject][2]: 
                                            acceleration_rest_dict[subject][2]=first_time
                                    elif last_time > acceleration_rest_dict[subject][3]: 
                                            acceleration_rest_dict[subject][3]=last_time
                except: 
                        #print "did not parse blob:"+str(accel_rest_blob) 
                        pass
                try:
                    if dev_mo_walk_blob!="NA": 
                            data1=parse_blob(dev_mo_walk_blob)
                            json_object=json.loads(data1) 
                            num_entries=len(json_object) 
                            if num_entries==0: 
                                    raise Exception() 
                            first_time=json_object[0].get('timestamp')
                            last_time=json_object[-1].get('timestamp') 
                            if subject not in deviceMotion_walk_dict: 
                                    deviceMotion_walk_dict[subject]=[num_entries,1,first_time,last_time]
                            else: 
                                    deviceMotion_walk_dict[subject][0]+=num_entries 
                                    deviceMotion_walk_dict[subject][1]+=1 
                                    if first_time < deviceMotion_walk_dict[subject][2]: 
                                            deviceMotion_walk_dict[subject][2]=first_time
                                    elif last_time > deviceMotion_walk_dict[subject][3]: 
                                            deviceMotion_walk_dict[subject][3]=last_time
                except: 
                        #print "did not parse blob:"+str(dev_mo_walk_blob) 
                        pass
                try: 
                    if dev_mo_rest_blob!="NA": 
                            data1=parse_blob(dev_mo_rest_blob)
                            json_object=json.loads(data1) 
                            num_entries=len(json_object) 
                            if num_entries==0: 
                                    raise Exception() 
                            first_time=json_object[0].get('timestamp')
                            last_time=json_object[-1].get('timestamp') 
                            if subject not in deviceMotion_rest_dict: 
                                    deviceMotion_rest_dict[subject]=[num_entries,1,first_time,last_time]
                            else: 
                                    deviceMotion_rest_dict[subject][0]+=num_entries 
                                    deviceMotion_rest_dict[subject][1]+=1 
                                    if first_time < deviceMotion_rest_dict[subject][2]: 
                                            deviceMotion_rest_dict[subject][2]=first_time
                                    elif last_time > deviceMotion_rest_dict[subject][3]: 
                                            deviceMotion_rest_dict[subject][3]=last_time
                except: 
                        #print "did not parse blob:"+str(dev_mo_rest_blob)                 
                        pass
        return pedometer_dict,acceleration_walk_dict,deviceMotion_walk_dict,hr_dict_walk,acceleration_rest_dict,deviceMotion_rest_dict,hr_dict_rest
                        
                
        
 
def main():
        from Parameters import * 
	if table_dir.endswith('/')==False: 
		table_dir=table_dir+'/'
        table_dir="/home/annashch/6minwalktables/" 
	if synapse_dir.endswith('/')==False: 
		synapse_dir=synapse_dir+'/' 
	table_files=[f for f in listdir(table_dir) if isfile(join(table_dir,f))] 
	#create a dictionary : category --> subject --> [# entries, #unknown,  #sessions, start time, end time,granularity, session length]
	subject_dict=dict()
        subjects=set([])
        all_categories=[]
        survey_dict=dict() #all data from survey tables 
	#iterate through all table files and summarize the metadata
        #table_files=['walk.small'] 
        allowed=[sys.argv[1],'cardiovascular-6MWT Displacement Data-v1.tsv' ] 
	for t in allowed:
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
                if t==sys.argv[1]:  
                        pedometer_dict,acceleration_walk_dict,deviceMotion_walk_dict,hr_dict_walk,acceleration_rest_dict,deviceMotion_rest_dict,hr_dict_rest=parse_6min_walk(header,data[1::])
                        #store in pickle for debug
                        '''
                        outf_p=open('pedometer.pickle','w') 
                        pickle.dump(pedometer_dict,outf_p) 
                        outf_aw=open('acceleration_walk.pickle','w') 
                        pickle.dump(acceleration_walk_dict,outf_aw) 
                        outf_ar=open('acceleration_rest.pickle','w') 
                        pickle.dump(acceleration_rest_dict,outf_ar) 
                        outf_dw=open('device_walk.pickle','w') 
                        pickle.dump(deviceMotion_walk_dict,outf_dw) 
                        outf_dr=open('device_rest.pickle','w') 
                        pickle.dump(deviceMotion_rest_dict,outf_dr) 
                        outf_hr_w=open('hr_w.pickle','w') 
                        pickle.dump(hr_dict_walk,outf_hr_w) 
                        outf_hr_r=open('hr_r.pickle','w') 
                        pickle.dump(hr_dict_rest,outf_hr_r) 
                        '''
                elif t=='cardiovascular-6MWT Displacement Data-v1.tsv': 
                        d6min_disp_dict=parse_6min_disp(header,data[1::])
                        '''
                        outf_disp=open('displacement_6min.pickle','w') 
                        pickle.dump(d6min_disp_dict,outf_disp) 
                        '''
                else: 
                        continue 
        #GET LIST OF ALL KNOWN SUBJECTS!!
        subjects=open('/home/annashch/intermediate_results/subjects.txt','r').read().split('\n') 
        subjects.remove('') 
        #WRITE ALL THE OUTPUT FILES 
        #############################################
        #6 MINUTE WALK TEST#
        outf=open('/home/annashch/6min_walk.tsv'+sys.argv[1],'w') 
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
                        outf.write('\t'+str(d6min_disp_dict[s][2])+'\t'+str(d6min_disp_dict[s][3])+'\t'+str(d6min_disp_dict[s][0])+'\t'+str(d6min_disp_dict[s][1])+'\t'+str(d6min_disp_dict[s][4]))
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
                outf.write('\n') 
if __name__=="__main__": 
	main() 
