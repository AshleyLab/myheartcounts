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
	if blob_hash=="NA":
		return None 
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
def parse_health_kit_data_collector(data): 
        feature_dict=dict() 
        counter=0 
        for line1 in data: 
                counter+=1 
                if counter%1000==0: 
                        print "COUNTER:"+str(counter) 
                line1=line1.split('\t') 
                if len(line1)<9: 
                        continue 
                subject=line1[2] 
                blob=line1[8] 
		if blob=="NA":
			continue
                data1=parse_blob(blob)
                accounted_for=dict() 
                for line in data1: 
			line=line.replace(',','\t')
                        parts=line.split('\t') 
			if len(parts)<3: 
				continue 
                        if parts[0]=="datetime": 
                                continue 
                        feature=parts[1] 
			if feature.startswith('20'): 
				feature=parts[2] 
                        if feature not in feature_dict: 
                                feature_dict[feature]=dict() 
                        if subject not in feature_dict[feature]: 
                                feature_dict[feature][subject]=[line]
                        else: 
                                feature_dict[feature][subject].append(line) 
 
                                accounted_for[tuple([feature,subject])]=1 
        return feature_dict 

        
def main():
	from Parameters import * 
	if synapse_dir.endswith('/')==False: 
		synapse_dir=synapse_dir+'/' 
	if table_dir.endswith('/')==False: 
		table_dir=table_dir+'/' 
	for fname in sys.argv[1::]: 
		print str(fname) 
		#fname=table_dir+t
		data=split_lines(fname) 
		health_kit_dict=parse_health_kit_data_collector(data[1::])
		for feature in health_kit_dict: 
			#try to create the directory for the feature 
			dirname=healthkit_tables+feature+'/'
			if not os.path.exists(dirname):
				os.makedirs(dirname)
			#in the directory, write the data for each subject
			for subject in health_kit_dict[feature]: 
				outf=open(dirname+subject+'.tsv','w') 
				cur_entries=health_kit_dict[feature][subject] 
				cur_entries.sort() 
				outf.write('\n'.join(cur_entries)+'\n')
if __name__=="__main__": 
	main() 
