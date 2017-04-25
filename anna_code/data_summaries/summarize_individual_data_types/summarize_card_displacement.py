from Parameters import * 
from helpers import * 
from dateutil.parser import parse
from os import listdir 
from os.path import isfile,join 
import sys 

def main(): 
    subjects=open('/home/annashch/intermediate_results/disp.subjects','r').read().split('\n') 
    subjects.remove('') 
    start_line=int(sys.argv[1])*82
    end_line=int(sys.argv[2])*82
    if len(subjects) < end_line: 
        end_line=len(subjects) 
    subject_block=subjects[start_line:end_line] 
    subject_pool=dict() 
    for s in subject_block: 
        subject_pool[s]=1 

    utc_start=parse('2000-01-01T00:00:00-05:00')
    features=set([]) 
    data=split_lines(card_disp_table) 
    feature_dict=dict() 
    session_dict=dict() 
    phone_dict=dict() 
    granularity_dict=dict() 
    counter=0 
    for line in data[1::]:
        counter+=1 
        print str(counter) 
        line=line.split('\t') 
        subject=line[0] 
        if subject not in subject_pool: 
            continue 
        if subject not in feature_dict: 
            feature_dict[subject]=dict() 
        if subject not in phone_dict: 
            phone_dict[subject]=dict() 
        if subject not in granularity_dict: 
            granularity_dict[subject]=dict() 
        hashname=line[2] 
        l1_dir=hashname[-3::].lstrip('0')
        if l1_dir=="": 
            l1_dir='0' 
        blob_dir=synapse_dir+l1_dir+'/'+hashname+'/' 
        blob_files=[f for f in listdir(blob_dir) if isfile(join(blob_dir,f))] 
    
        for f in blob_files: 
            gran_found=False 
            if f.startswith('data')==False: 
                continue 
            if f.endswith('clean')==False: 
                continue 
            blob=split_lines(blob_dir+f) 
            for line in blob[1::]: 
                #print str(line) 
                line=line.split(',') 
                if len(line)<5: 
                    #print str(line) 
                    continue 
                timestamp_string=line[0] 
                timestamp_end_string=line[1] 
                feature=line[2] 
                try:
                    timestamp=(parse(line[0])-utc_start).total_seconds()  
                except: #skip all lines without a valid timestamp, these are usu. duplicate headers 
                     print blob_dir+f+"--->"+str(line) 
                     continue 
                
                phone=line[5] 
                features.add(feature) 
                if feature not in granularity_dict[subject]: 
                    try:
                        start_val=parse(line[0]) 
                        end_val=parse(line[1]) 
                        delta=(end_val-start_val).total_seconds() 
                        granularity_dict[subject][feature]=delta
                    except: 
                        print str(line[1]) 
                if feature not in feature_dict[subject]: 
                    feature_dict[subject][feature]=[1,timestamp_string,timestamp_string,timestamp,timestamp] 
                else: 
                    feature_dict[subject][feature][0]=feature_dict[subject][feature][0]+1
                    if timestamp > feature_dict[subject][feature][4]: 
                        feature_dict[subject][feature][4]=timestamp 
                        feature_dict[subject][feature][2]=timestamp_string 
                    elif timestamp < feature_dict[subject][feature][3]: 
                        feature_dict[subject][feature][1]=timestamp_string 
                        feature_dict[subject][feature][3]=timestamp 
                if feature not in phone_dict[subject]: 
                    phone_dict[subject][feature]=set([phone]) 
                else: 
                    phone_dict[subject][feature].add(phone) 
    #print str(granularity_dict) 
    #write the output file 
    outf=open(card_disp_results+"_"+str(start_line)+"_"+str(end_line),'w') 
    outf.write('healthCode') 
    groups=["_1st_timestamp","_last_timestamp","_rows","_granularity(s)","_phones"]
    for f in features: 
        for g in groups: 
            outf.write('\t'+f+g) 
    outf.write('\n') 
    for subject in feature_dict: 
        outf.write(subject) 
        for feature in features: 
            #print str(feature) 
            if feature not in feature_dict[subject]: 
                outf.write('\tNA\tNA\tNA\tNA\tNA') 
            else: 
                if feature not in granularity_dict[subject]: 
                    gran="NA" 
                else: 
                    gran=str(granularity_dict[subject][feature])
                #print "granularity:"+str(granularity) 
                #print "numentries:"+str(feature_dict[subject][feature][0]) 
                outf.write('\t'+feature_dict[subject][feature][1]+'\t'+feature_dict[subject][feature][2]+'\t'+str(feature_dict[subject][feature][0])+'\t'+gran+'\t'+','.join(phone_dict[subject][feature]))
        outf.write('\n') 
if __name__ == "__main__": 
    main() 
