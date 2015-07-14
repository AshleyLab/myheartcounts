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



#function to parse the file "cardiovascular-HealthKitDataCollector-v1.tsv" 
def parse_health_kit_data_collector(header,data): 
        feature_dict=dict() 
        counter=0 
        for line1 in data: 
                counter+=1 
                if counter%1000==0: 
                        print "COUNTER:"+str(counter) 
                line1=line1.split('\t') 
                subject=line1[2] 
                blob=line1[8] 
                data1=parse_blob(blob)
                accounted_for=dict() 
                for line in data1: 
                        line=line.split(',') 
                        if line[0]=="datetime": 
                                continue 
                        timestamp=line[0] 
                        try:
                                parsed_time=parse(timestamp)
                        except: 
                                continue 
                        feature=line[1] 
                        if feature not in feature_dict: 
                                feature_dict[feature]=dict() 
                        if subject not in feature_dict[feature]: 
                                feature_dict[feature][subject]=[timestamp,timestamp,parsed_time,parsed_time,1,1] 
                                accounted_for[tuple([feature,subject])]=1 
                        else: 
                                if parsed_time < feature_dict[feature][subject][2]: 
                                        feature_dict[feature][subject][2]=parsed_time 
                                        feature_dict[feature][subject][0]=timestamp 
                                elif parsed_time > feature_dict[feature][subject][3]: 
                                        feature_dict[feature][subject][3]=parsed_time 
                                        feature_dict[feature][subject][1]=timestamp 
                                feature_dict[feature][subject][4]+=1 
                                if tuple([feature,subject]) not in accounted_for: 
                                        feature_dict[feature][subject][5]+=1 
                                        accounted_for[tuple([feature,subject])]=1 
        return feature_dict 

        
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
                if t=='cardiovascular-HealthKitDataCollector-v1.tsv': 
                        health_kit_dict=parse_health_kit_data_collector(header,data[1::])
                else: 
                        continue 
        #GET LIST OF ALL KNOWN SUBJECTS!!
        subjects=open('/home/annashch/intermediate_results/subjects.txt','r').read().split('\n') 
        subjects.remove('') 
        #WRITE ALL THE OUTPUT FILES 
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
                        if s not in health_kit_dict[f]: 
                                outf.write('\tNA\tNA\t0\t0') 
                        else: 
                                outf.write('\t'+str(health_kit_dict[f][s][0])+'\t'+str(health_kit_dict[f][s][1])+'\t'+str(health_kit_dict[f][s][4])+'\t'+str(health_kit_dict[f][s][5]))
                outf.write('\n') 
     
if __name__=="__main__": 
	main() 
