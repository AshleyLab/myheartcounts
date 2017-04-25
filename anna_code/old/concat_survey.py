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
                subject=line[2] 
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
                                                csv_dict[feature][subject][0]=timestamp 
                                        elif parsed_time > csv_dict[feature][subject][3]: 
                                                csv_dict[feature][subject][3]=parsed_time 
                                                csv_dict[feature][subject][1]=timestamp 
                                        csv_dict[feature][subject][4]+=1 
        return csv_dict 

                        
                
        
 
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
                        tmp_dict=parse_survey(header,data[1::])
                        for feature in tmp_dict: 
                                survey_dict[feature]=tmp_dict[feature] 
		else:
			continue 
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
                        if s not in survey_dict[f]: 
                                outf.write('\tNA\tNA\t0') 
                        else: 
                                outf.write('\t'+survey_dict[f][s][0]+'\t'+survey_dict[f][s][1]+'\t'+str(survey_dict[f][s][4]))
                outf.write('\n') 
        
if __name__=="__main__": 
	main() 
