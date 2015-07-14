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
def parse_motion_tracker(data): 
        subject_dict=dict() 
        counter=0 
        for line1 in data[1::]: 
                counter+=1 
                if counter%1000==0: 
                        print "COUNTER:"+str(counter) 
                line1=line1.split('\t') 
                if len(line1)<9: 
                        continue 
                subject=line1[2]
                if subject not in subject_dict:
                    subject_dict[subject]=[] 
                blob=line1[8] 
                if blob=="NA": 
                        continue 
                if blob in bad_blobs: 
                        continue 
                data1=parse_blob(blob)
                if data1==None: 
                        print str(blob) 
                        continue 
                if '' in data1: 
                        data1.remove('')
                for line in data1[1::]:
                        if line.startswith('2015'): 
				#add on any missing values! 
				line=line.replace(',','\t') 
				if len(line.split('\t'))==6: 
					subject_dict[subject].append(line) 
				elif len(line.split('\t'))==5: 
					vals=line.split('\t')
					if vals[-1]=="0":
						subject_dict[subject].append(line+'\t0') 
					elif vals[-1]=="1": 
						subject_dict[subject].append(line+'\t0.5') 
					elif vals[-1]=="2": 
						subject_dict[subject].append(line+'\t1.0') 
					else: 
						pass #NOT A VALID LINE, DO NOT APPEND ! 
        return subject_dict 

def main():
        from Parameters import * 
	if table_dir.endswith('/')==False: 
		table_dir=table_dir+'/' 
	if synapse_dir.endswith('/')==False: 
		synapse_dir=synapse_dir+'/' 
	table_files=['cardiovascular-motionTracker-v1.tsv.sorted']
	for t in table_files:
                if t=='cardiovascular-motionTracker-v1.tsv.sorted':
                        data=split_lines(table_dir+t)
                        motion_track_dict=parse_motion_tracker(data[1::])
                else: 
                        continue 
        for subject in motion_track_dict:
            outf=open(motiontrakcer_table+subject+'.tsv','w')
            values=motion_track_dict[subject] 
            values.sort() 
            outf.write('\n'.join(values)+'\n') 
if __name__=="__main__": 
	main() 
