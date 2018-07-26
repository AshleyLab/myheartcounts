import sys 
from Parameters import * 
from helpers import * 
from datetime import datetime
import os 
from os import listdir 
from os.path import isfile,join,exists
from dateutil.parser import parse

#reads in a datafile and splits by line 
#replace '\r\n' with '\n' for Linux & Windows compatible newline characters 
def split_lines(fname): 
	data=open(fname,'r').read().replace('\r\n','\n').split('\n')
	if '' in data:
		data.remove('') 
        #data.sort() 
        return data

#reads in a blob file specified with hash notation in a table file 
def parse_blob(blob_hash): 
        top_dir=blob_hash[-3::].lstrip('0') 
        if top_dir=="": 
                top_dir='0' 
	if blob_hash=="NA":
		return None
        full_dir=synapse_dir+top_dir+'/'+blob_hash
        csv_files=[f for f in listdir(full_dir) if isfile(join(full_dir,f))]
        for f in csv_files: 
                if f.startswith('.'): 
                        continue 
                else: 
                        return split_lines(full_dir+'/'+f) 
	return None


#function to parse the file "cardiovascular-HealthKitDataCollector-v1.tsv" 
def parse_cardiovascular_displacement(data): 
        feature_dict=dict() 
        counter=0 
        for line1 in data: 
                counter+=1 
                if counter%1000==0: 
                        print "COUNTER:"+str(counter) 
                line1=line1.split('\t') 
                subject=line1[2] 
                if len(line1)<9: 
                        continue 
                blob=line1[8] 
                data1=parse_blob(blob)
		if data1==None: 
			continue 
                for line in data1:
                        if line.startswith('2015')==False: 
                                continue 
			line=line.replace(',','\t') 
                        parts=line.split('\t') 
                        if parts[0]=="datetime": 
                                continue 
                        if len(parts)<3: 
                                continue 
                        if len(parts)<5: 
                                feature='displacement' 
                        elif parts[1].startswith('H'):
                                feature=parts[1] 
                        else: 
                                feature=parts[2] 
                        if feature not in feature_dict: 
                                feature_dict[feature]=dict() 
                        if subject not in feature_dict[feature]: 
                                feature_dict[feature][subject]=[line]
                        else: 
                                feature_dict[feature][subject].append(line) 
        return feature_dict 

        
def main():
	from Parameters import * 
	if synapse_dir.endswith('/')==False: 
		synapse_dir=synapse_dir+'/' 
	#fname=table_dir+cardio_disp_file 
	fname=sys.argv[1] 
        data=split_lines(fname) 
        cardv_disp_dict=parse_cardiovascular_displacement(data[1::])
        for feature in cardv_disp_dict: 
                #try to create the directory for the feature 
                dirname=cardio_disp_table+feature+'/'
                if not os.path.exists(dirname):
                        os.makedirs(dirname)
                #in the directory, write the data for each subject
                for subject in cardv_disp_dict[feature]: 
                        outf=open(dirname+subject+'.tsv','w') 
                        cur_entries=cardv_disp_dict[feature][subject] 
                        cur_entries.sort() 
                        outf.write('\n'.join(cur_entries)+'\n')
if __name__=="__main__": 
	main() 
