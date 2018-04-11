steps=open("/scratch/PI/euan/projects/mhc/data/timeseries_v2/summary/healthkit_combined.stepcount.txt",'r').read().strip().split('\n') 
distance=open("/scratch/PI/euan/projects/mhc/data/timeseries_v2/summary/healthkit_combined.distance.txt",'r').read().strip().split('\n') 
steps_thresh=50000
dist_thresh=25000
step_dict=dict() 
dist_dict=dict() 
for line in steps[1::]: 
    tokens=line.split('\t') 
    subject=tokens[0] 
    day=tokens[3] 
    value=tokens[5] 
    source=tokens[6] 
    if source.__contains__("apple.health"): 
        if source.lower().__contains__("iphone"): 
            source="iPhone"
        elif source.lower().__contains__("watch"): 
            source="Watch"
        else: 
            source="iPhoneOrWatch"
    elif source.__contains__("garmin"): 
        source="Garmin" 
    elif source.__contains__("strava"): 
        source="Strava" 
    elif source.__contains__("syncforfitbit"): 
        source="FitbitSync" 
    else: 
        source=source.split('\'')[1]
    blobs=tokens[-1] 
    step_dict[tuple([subject,day])]=[value,source,blobs]
for line in distance[1::]: 
    tokens=line.split('\t') 
    subject=tokens[0] 
    day=tokens[3] 
    value=tokens[5] 
    source=tokens[6]
    if source.__contains__("apple.health"): 
        if source.lower().__contains__("iphone"): 
            source="iPhone"
        elif source.lower().__contains__("watch"): 
            source="Watch"
        else: 
            source="iPhoneOrWatch"
    elif source.__contains__("garmin"): 
        source="Garmin" 
    elif source.__contains__("strava"): 
        source="Strava" 
    elif source.__contains__("syncforfitbit"): 
        source="FitbitSync" 
    else: 
        source=source.split('\'')[1]
    blobs=tokens[-1] 
    dist_dict[tuple([subject,day])]=[value,source,blobs]
outf=open('outliers.txt','w') 
outf.write('Subject\tDay\tStep\tStepSource\tDist\tDistSource\tStepBlobs\tDistBlobs\n')
options=set(dist_dict.keys()).union(set(step_dict.keys()))
for option in options: 
    step_val=float("-inf") 
    dist_val=float("-inf")
    if option in step_dict: 
        step_val=float(step_dict[option][0])
    if option in dist_dict:
        dist_val=float(dist_dict[option][0]) 
    if ((step_val>steps_thresh) or (dist_val > dist_thresh)): 
        #add to outliers list 
        subject=option[0] 
        day=option[1] 
        try:
            step_source=step_dict[option][1] 
        except: 
            step_source="NA"
        try:
            step_blobs=step_dict[option][2] 
        except:
            step_blobs="NA"
        try:
            dist_source=dist_dict[option][1] 
        except: 
            dist_source="NA"
        try:
            dist_blobs=dist_dict[option][2] 
        except: 
            dist_blobs="NA"
        if step_val==float('-inf'): 
            step_val="NA"
        if dist_val==float("-inf"): 
            dist_val="NA"
        outf.write(subject+'\t'+
                   day+'\t'+
                   str(step_val)+'\t'+
                   step_source+'\t'+
                   str(dist_val)+'\t'+
                   dist_source+'\t'+
                   step_blobs+'\t'+
                   dist_blobs+'\n')

                   
