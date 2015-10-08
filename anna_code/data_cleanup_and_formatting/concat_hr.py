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
import codecs 

#reads in a datafile and splits by line 
#replace '\r\n' with '\n' for Linux & Windows compatible newline characters 
def split_lines(fname): 
	data=open(fname,'r').read().replace('\r\n','\n').split('\n')
	if '' in data:
		data.remove('') 
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
                if f.endswith('.clean')==False: 
                        continue 
                else: 
                    inputfname=full_dir+'/'+f
                    data=open(inputfname).read()
                    return data # slightly modified version does not call split lines because we want to preserve the json structure 
        return None 



#function to parse the table 'cardiovascular-6MWT Displacement Data-v1.tsv'
def parse_6min_disp(data):
        header="timestamp,direction,directionUnit,displacement,displacementUnit,altitude,horizontalAccuracy,verticalAccuracy" 
        subject_dict=dict() 
        for line1 in data:
                #print str(line1) 
                line1=line1.split('\t') 
                subject=line1[2]
                if len(line1)<9: 
                        continue 
                blob=line1[8] 
                datab=parse_blob(blob)
                if datab==None: 
                        continue 
                json_object=json.loads(datab) 
                if subject not in subject_dict: 
                        subject_dict[subject]=[] 
                for entry in json_object: 
                        direction=str(entry.get("direction")) 
                        dispUnit=str(entry.get("displacementUnit")) 
                        dirUnit=str(entry.get("directionunit")) 
                        timestamp=str(entry.get("timestamp")) 
                        altitude=str(entry.get("altitude")) 
                        displacement=str(entry.get("displacement")) 
                        horAcc=str(entry.get("horizontalAccuracy")) 
                        vertAcc=str(entry.get("verticalAccuracy")) 
                        concat_entry="\t".join([timestamp,direction,dirUnit,displacement,dispUnit,altitude,horAcc,vertAcc])
                        subject_dict[subject].append(concat_entry) 
        return subject_dict,header  


#function to parse the table 'cardiovascular-6MinuteWalkTest-v2.tsv'
def parse_subject(subject,lines): 
        pedometer_list=[]
        acceleration_walk_list=[]
        deviceMotion_walk_list=[]
        hr_list_walk=[] 
        acceleration_rest_list=[]
        deviceMotion_rest_list=[]
        hr_list_rest=[]
        #headers 
        pedometer_header="startDate\tendDate\tnumberOfSteps\tdistance\tfloorsAscended\tfloorsDescended" 
        acceleration_walk_header="timestamp\tx\ty\tz" 
        acceleration_rest_header="timestamp\tx\ty\tz"  
        deviceMotion_walk_header="timestamp\tuseAcceleration_x\tuserAcceleration_y\tuserAcceleration_z\tmagneticField_x\tmagneticField_y\tmagneticField_z\tmagneticField_accuracy\tgravity_x\tgravity_y\tgravity_z\trotationRate_x\trotationRate_y\trotationRate_z\tattitude_x\tattitude_y\tattitude_z\tattitude_w"
        deviceMotion_rest_header="timestamp\tuseAcceleration_x\tuserAcceleration_y\tuserAcceleration_z\tmagneticField_x\tmagneticField_y\tmagneticField_z\tmagneticField_accuracy\tgravity_x\tgravity_y\tgravity_z\trotationRate_x\trotationRate_y\trotationRate_z\tattitude_x\tattitude_y\tattitude_z\tattitude_w"
        hr_header_walk="startDate\tendDate\tvalue\tsource\tunit" 
        hr_header_rest="startDate\tendDate\tvalue\tsource\tunit" 
        for line1 in lines:                 
                line1=line1.split('\t') 
		print str(line1) 
                if len(line1)<9: 
                        continue 
                subject=line1[2] 
                #get all 7 blobs 
		#print str(line1)
                #ped_blob=line1[8]
                #accel_walk_blob=line1[9] 
                #dev_mo_walk_blob=line1[10] 
                hr_walk_blob=line1[11]
                #accel_rest_blob=line1[12] 
                #dev_mo_rest_blob=line1[13] 
                hr_rest_blob=line1[14] 
                try:
                        if hr_walk_blob!="NA": 
                            data1=parse_blob(hr_walk_blob)
			    #print "walk: "+str(data1) 
                            json_object=json.loads(data1) 
                            num_entries=len(json_object) 
                            if num_entries==0: 
                                    raise Exception() 
                            for entry in json_object: 
				    #GET THE HEART RATE FIELDS!! 
				    startDate=str(entry.get("startDate")) 
				    endDate=str(entry.get("endDate"))
				    value=str(entry.get("value")) 
				    source=entry.get("source")
				    source=str(source.encode("ascii","ignore"))
				    unit=str(entry.get("unit")) 
				    string_entry="\t".join([startDate,endDate,value,source,unit])
				    hr_list_walk.append(string_entry) 
                except: 
                        #print "did not parse blob:"+str(hr_walk_blob) 
                        pass
                try:
                        if hr_rest_blob!="NA": 
                            data1=parse_blob(hr_rest_blob)
			    print "rest:"+str(data1) 
                            json_object=json.loads(data1) 
                            num_entries=len(json_object) 
                            if num_entries==0: 
                                    raise Exception() 
                            for entry in json_object: 
				    #GET THE HEART RATE FIELDS!! 
				    startDate=str(entry.get("startDate")) 
				    endDate=str(entry.get("endDate"))
				    value=str(entry.get("value")) 
				    source=entry.get("source")
				    source=str(source.encode("ascii","ignore"))
				    unit=str(entry.get("unit")) 
				    string_entry="\t".join([startDate,endDate,value,source,unit])
                                    hr_list_rest.append(string_entry) 
                except Exception, e: 
			print e 
                        pass
        #write the output files!! 
        if len(hr_list_walk)>0: 
                outf=open(walktables+"hr_walk/"+subject+'.tsv','w') 
		hr_list_walk.sort() 
                outf.write(hr_header_walk+'\n'+'\n'.join(hr_list_walk)+"\n")
        if len( hr_list_rest)>0: 
                outf=open(walktables+"hr_rest/"+subject+'.tsv','w') 
		hr_list_rest.sort() 
                outf.write(hr_header_rest+'\n'+'\n'.join(hr_list_rest)+"\n")

def parse_6min_walk(data): 
        #store entries, sessions, first, last
        #print str(data) 
        counter=0 
        cur_subject=data[0].split('\t')[2] 
        cur_lines=[data[0]] 
        for line1 in data[1:]:
                subject=line1.split('\t')[2]
                #print str(subject) 
                if subject ==cur_subject: 
                        cur_lines.append(line1) 
                else: 
                        #record the current subject! 
                        parse_subject(cur_subject,cur_lines) 
                        counter+=1 
                        #print str(counter) 
                        cur_subject=subject 
                        cur_lines=[line1] 
        #make sure to record the last subject!
        parse_subject(cur_subject,cur_lines) 
        counter+=1 
        #print str(counter) 



def main():
	print "sys.argv:"+str(sys.argv) 
	allowed=[table_dir+'cardiovascular-6MWT Displacement Data-v1.tsv'] 
	if len(sys.argv)<2: 
		allowed.append(table_dir+'cardiovascular-6MinuteWalkTest-v2.tsv') 
	else: 
		f=sys.argv[1] 
		allowed.append(f) 
	print str(allowed) 
	for t in allowed:
		print "TABLE:"+str(t)  
		data=split_lines(t)
		if t.split('/')[-1]=='cardiovascular-6MWT Displacement Data-v1.tsv': 
			continue
                else:
                        parse_6min_walk(data[1::]) 
                

if __name__=="__main__": 
	main() 
