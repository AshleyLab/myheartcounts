import sys 
import json 
data=open(sys.argv[1],'r').read()
json_object=json.loads(data) 
print "loaded json!" 
times=[] 
values=[] 
json_data=json_object.get("data") 
num_entries=len(json_data) 
total=str(num_entries) 
c=0 
for entry in json_data: 
    c+=1 
    if c%100==0: 
        print str(c)+'/'+total 
    ts=entry.get("ts") 
    ecg_vis=entry.get("data").get("ecgVisual")
    if ecg_vis==None: 
        continue 
    for ecg_val in ecg_vis: 
        values.append(str(ecg_val)) 
        times.append(str(ts))
outf=open(sys.argv[2],'w') 
for i in range(1,len(times)): 
    outf.write(times[i]+'\t'+values[i]+'\n') 
