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
def parse_6min_disp(data):
        header="timestamp,direction,directionUnit,displacement,displacementUnit,altitude,horizontalAccuracy,verticalAccuracy" 
        subject_dict=dict() 
        for line1 in data: 
                line1=line1.split('\t') 
                subject=line1[2]
                if len(line1)<9: 
                        continue 
                blob=line1[8] 
                data=parse_blob(blob)
                if data==None: 
                        continue 
                json_object=json.loads(data) 
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
                        concat_entry=",".join([timestamp,direction,dirUnit,displacement,dispUnit,altitude,horAcc,vertAcc])
                        subject_dict[subject].append(concat_entry) 
        return subject_dict,header  


#function to parse the table 'cardiovascular-6MinuteWalkTest-v2.tsv'
def parse_6min_walk(data): 
        #store entries, sessions, first, last
        pedometer_dict=dict() 
        acceleration_walk_dict=dict() 
        deviceMotion_walk_dict=dict() 
        hr_dict_walk=dict() 
        acceleration_rest_dict=dict() 
        deviceMotion_rest_dict=dict() 
        hr_dict_rest=dict() 
        #headers 
        pedometer_header="startDate,endDate,numberOfSteps,distance,floorsAscended,floorsDescended" 
        acceleration_walk_header="timestamp,x,y,z" 
        acceleration_rest_header="timestamp,x,y,z"  
        deviceMotion_walk_header="timestamp,useAcceleration_x,userAcceleration_y,userAcceleration_z,magneticField_x,magneticField_y,magneticField_z,magneticField_accuracy,gravity_x,gravity_y,gravity_z,rotationRate_x,rotationRate_y,rotationRate_z,attitude_x,attitude_y,attitude_z,attitude_w"
        deviceMotion_rest_header="timestamp,useAcceleration_x,userAcceleration_y,userAcceleration_z,magneticField_x,magneticField_y,magneticField_z,magneticField_accuracy,gravity_x,gravity_y,gravity_z,rotationRate_x,rotationRate_y,rotationRate_z,attitude_x,attitude_y,attitude_z,attitude_w"
        hr_header_walk="" 
        hr_header_rest="" 
        counter=0
        for line1 in data:
                counter+=1 
                if counter%100==0: 
                        print str(counter) 
                line1=line1.split('\t') 
                if len(line1)<9: 
                        continue 
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
                            if subject not in pedometer_dict: 
                                    pedometer_dict[subject]=[] 
                            for entry in json_object: 
                                    startDate=str(entry.get("startDate")) 
                                    endDate=str(entry.get("endDate")) 
                                    steps=str(entry.get("numberOfSteps")) 
                                    distance=str(entry.get("distance")) 
                                    floorsAscended=str(entry.get("floorsAscended")) 
                                    floorsDescended=str(entry.get("floorsDescended")) 
                                    string_entry=",".join([startDate,endDate,steps,distance,floorsAscended,floorsDescended]) 
                                    pedometer_dict[subject].append(string_entry) 
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
                                    hr_dict_walk[subject]=[] 
                            for entry in json_object: 
                                    hr_dict_walk[subject].append(str(entry)) 
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
                                    hr_dict_rest[subject]=[] 
                            for entry in json_object: 
                                    hr_dict_rest[subject].append(str(entry)) 
                except: 
                        #print "did not parse blob:"+str(hr_rest_blob) 
                        pass
                try:
                        if accel_walk_blob!="NA": 
                            data1=parse_blob(accel_walk_blob)
                            json_object=json.loads(data1)
                            if subject not in acceleration_walk_dict: 
                                    acceleration_walk_dict[subject]=[] 
                            for entry in json_object: 
                                    timestamp=str(entry.get("timestamp"))
                                    x=str(entry.get("x"))
                                    y=str(entry.get("y")) 
                                    z=str(entry.get("z")) 
                                    string_entry=','.join([timestamp,x,y,z])
                                    acceleration_walk_dict[subject].append(string_entry)
                except: 
                        #print "did not parse blob:"+str(accel_walk_blob) 
                        pass
                try:
                        if accel_rest_blob!="NA": 
                            data1=parse_blob(accel_rest_blob)
                            json_object=json.loads(data1)
                            if subject not in acceleration_rest_dict: 
                                    acceleration_rest_dict[subject]=[] 
                            for entry in json_object: 
                                    timestamp=str(entry.get("timestamp"))
                                    x=str(entry.get("x"))
                                    y=str(entry.get("y")) 
                                    z=str(entry.get("z")) 
                                    string_entry=','.join([timestamp,x,y,z])
                                    acceleration_rest_dict[subject].append(string_entry)
                except: 
                        #print "did not parse blob:"+str(accel_rest_blob) 
                        pass
                try:
                        if dev_mo_walk_blob!="NA": 
                            data1=parse_blob(dev_mo_walk_blob)
                            json_object=json.loads(data1) 
                        if subject not in deviceMotion_walk_dict: 
                            deviceMotion_walk_dict[subject]=[]
                        for entry in json_object: 
                            timestamp=str(entry.get('timestamp')) 
                            userAccel=entry.get('userAcceleration') 
                            userAccelx=str(userAccel.get("x")) 
                            userAccely=str(userAccel.get("y")) 
                            userAccelz=str(userAccel.get("z")) 
                            magnetic=entry.get("magneticField") 
                            magneticx=str(magnetic.get("x")) 
                            magneticy=str(magnetic.get("y")) 
                            magneticz=str(magnetic.get("z")) 
                            magneticaccur=str(magnetic.get("accuracy")) 
                            gravity=entry.get("gravity") 
                            gravityx=str(gravity.get("x")) 
                            gravityy=str(gravity.get("y")) 
                            gravityz=str(gravity.get("z")) 
                            rotationRate=entry.get("rotationRate") 
                            rotationRatex=str(rotationRate.get("x")) 
                            rotationRatey=str(rotationRate.get("y")) 
                            rotationRatez=str(rotationRate.get("z")) 
                            attitude=entry.get("attitude") 
                            attitudex=str(attitude.get("x")) 
                            attitudey=str(attitude.get("y")) 
                            attitudez=str(attitude.get("z"))
                            attitudew=str(attitude.get("w")) 
                            string_entry=','.join([timestamp,userAccelx,userAccely,userAccelz,magneticx,magneticy,magneticz,gravityx,gravityy,gravityz,rotationRatex,rotationRatey,rotationRatez,attitudex,attitudey,attitudez,attitudew])
                            deviceMotion_walk_dict[subject].append(string_entry) 
                except: 
                        #print "did not parse blob:"+str(dev_mo_walk_blob) 
                        pass
                try: 
                    if dev_mo_rest_blob!="NA": 
                            data1=parse_blob(dev_mo_rest_blob)
                            json_object=json.loads(data1) 
                            if subject not in deviceMotion_rest_dict: 
                                    deviceMotion_rest_dict[subject]=[]
                            for entry in json_object: 
                                    timestamp=str(entry.get('timestamp')) 
                                    userAccel=entry.get('userAcceleration') 
                                    userAccelx=str(userAccel.get("x")) 
                                    userAccely=str(userAccel.get("y")) 
                                    userAccelz=str(userAccel.get("z")) 
                                    magnetic=entry.get("magneticField") 
                                    magneticx=str(magnetic.get("x")) 
                                    magneticy=str(magnetic.get("y")) 
                                    magneticz=str(magnetic.get("z")) 
                                    magneticaccur=str(magnetic.get("accuracy")) 
                                    gravity=entry.get("gravity") 
                                    gravityx=str(gravity.get("x")) 
                                    gravityy=str(gravity.get("y")) 
                                    gravityz=str(gravity.get("z")) 
                                    rotationRate=entry.get("rotationRate") 
                                    rotationRatex=str(rotationRate.get("x")) 
                                    rotationRatey=str(rotationRate.get("y")) 
                                    rotationRatez=str(rotationRate.get("z")) 
                                    attitude=entry.get("attitude") 
                                    attitudex=str(attitude.get("x")) 
                                    attitudey=str(attitude.get("y")) 
                                    attitudez=str(attitude.get("z"))
                                    attitudew=str(attitude.get("w")) 
                                    string_entry=','.join([timestamp,userAccelx,userAccely,userAccelz,magneticx,magneticy,magneticz,gravityx,gravityy,gravityz,rotationRatex,rotationRatey,rotationRatez,attitudex,attitudey,attitudez,attitudew])
                                    deviceMotion_rest_dict[subject].append(string_entry) 

                except: 
                        #print "did not parse blob:"+str(dev_mo_rest_blob)                 
                        pass
        return pedometer_dict,pedometer_header,acceleration_walk_dict,acceleration_walk_header,deviceMotion_walk_dict,deviceMotion_walk_header,hr_dict_walk,hr_header_walk,acceleration_rest_dict,acceleration_rest_header,deviceMotion_rest_dict,deviceMotion_rest_header,hr_dict_rest,hr_header_rest

def main():
        from Parameters import * 
        f=sys.argv[1] 
        allowed=[f,'cardiovascular-6MWT Displacement Data-v1.sorted'] 
	for t in allowed:
		print "TABLE:"+str(t)  
		data=split_lines(walktables+t)
                if t==f: 
                        pedometer_dict,pedometer_header,acceleration_walk_dict,acceleration_walk_header,deviceMotion_walk_dict,deviceMotion_walk_header,hr_dict_walk,hr_header_walk,acceleration_rest_dict,acceleration_rest_header,deviceMotion_rest_dict,deviceMotion_rest_header, hr_dict_rest,hr_header_rest=parse_6min_walk(data[1::]) 
                elif t=='cardiovascular-6MWT Displacement Data-v1.sorted': 
                        d6min_disp_dict,d6min_disp_header=parse_6min_disp(data[1::])
                else: 
                        continue 
        #WRITE OUTPUT FILES 
        for subject in d6min_disp_dict: 
                outf=open('/home/common/myheart/data/grouped_timeseries/6minute_walk/displacement/'+subject+'.tsv','w') 
                outf.write(d6min_disp_header+'\n'+'\n'.join(d6min_disp_dict[subject]))
        for subject in pedometer_dict: 
                outf=open('/home/common/myheart/data/grouped_timeseries/6minute_walk/pedometer/'+subject+'.tsv','w') 
                outf.write(pedometer_header+'\n'+'\n'.join(pedometer_dict[subject]))
        for subject in acceleration_walk_dict: 
                outf=open('/home/common/myheart/data/grouped_timeseries/6minute_walk/acceleration_walk/'+subject+'.tsv','w') 
                outf.write(acceleration_walk_header+'\n'+'\n'.join(acceleration_walk_dict[subject]))
        for subject in acceleration_rest_dict: 
                outf=open('/home/common/myheart/data/grouped_timeseries/6minute_walk/acceleration_rest/'+subject+'.tsv','w') 
                outf.write(acceleration_rest_header+'\n'+'\n'.join(acceleration_rest_dict[subject]))
        for subject in deviceMotion_walk_dict: 
                outf=open('/home/common/myheart/data/grouped_timeseries/6minute_walk/device_walk/'+subject+'.tsv','w') 
                outf.write(deviceMotion_walk_header+'\n'+'\n'.join(deviceMotion_walk_dict[subject]))
        for subject in deviceMotion_rest_dict: 
                outf=open('/home/common/myheart/data/grouped_timeseries/6minute_walk/device_rest/'+subject+'.tsv','w') 
                outf.write(deviceMotion_rest_header+'\n'+'\n'.join(deviceMotion_rest_dict[subject]))
        for subject in hr_dict_walk: 
                outf=open('/home/common/myheart/data/grouped_timeseries/6minute_walk/hr_walk/'+subject+'.tsv','w') 
                outf.write(hr_header_walk+'\n'+'\n'.join(hr_dict_walk[subject]))
        for subject in hr_dict_rest: 
                outf=open('/home/common/myheart/data/grouped_timeseries/6minute_walk/hr_rest/'+subject+'.tsv','w') 
                outf.write(hr_header_rest+'\n'+'\n'.join(hr_dict_rest[subject]))

if __name__=="__main__": 
	main() 
