#get counts and % of total for each age group 
import argparse
def parse_args(): 
    parser=argparse.ArgumentParser(description="get counts and % of total for each age group ")
    parser.add_argument("--input") 
    parser.add_argument("--field") 
    parser.add_argument("--version_index",default=None,type=int)
    parser.add_argument("--version",default=None) 
    parser.add_argument("--field_index",default=None,type=int) 
    parser.add_argument("--field_keys",nargs="+",default=[])
    parser.add_argument("--field_values",nargs="+",default=[]) 
    parser.add_argument("--outf") 
    return parser.parse_args() 

def summarize_generic(data,outf,args): 
    summary_dict=dict() 
    subjects=set([]) 
    if len(args.field_keys)>0: 
        #get a key-value mapping 
        key_val=dict() 
        for i in range(len(args.field_keys)): 
            cur_key=args.field_keys[i] 
            cur_val=args.field_values[i] 
            key_val[cur_key]=cur_val
    for line in data[1::]: 
        tokens=line.split('\t') 
        if args.version!=None: 
            version_val=tokens[args.version_index] 
            if not(version_val.startswith("version "+str(args.version))): 
                continue 
        subject=tokens[5] 
        if subject in subjects: 
            #avoid double counting 
            continue 
        subjects.add(subject) 
        field_val=tokens[args.field_index].strip('[').strip(']') 
        if len(args.field_keys)>0: 
            #get a key value mapping
            if field_val!="NA":
                field_val=key_val[field_val]
        if field_val not in summary_dict: 
            summary_dict[field_val]=1 
        else: 
            summary_dict[field_val]+=1 
    total_subjects=len(subjects) 
    for entry in summary_dict: 
        outf.write(str(entry)+'\t'+str(summary_dict[entry])+'\t'+str(float(summary_dict[entry])/total_subjects)+'\n')
    
                
def summarize_age(data,outf,args): 
    age_dict=dict() 
    subjects=set([]) 
    for line in data: 
        tokens=line.split('\t') 
        subject=tokens[0]
        if subject in subjects: 
            #avoid double counting 
            continue 
        subjects.add(subject)
        age=tokens[1] 
        if age=="NA": 
            if 'NA' not in age_dict: 
                age_dict['NA']=1
            else: 
                age_dict['NA']+=1
        else: 
            #bin to decade 
            try:
                age=(int(age)//10)*10 
            except: 
                age=2015-int(age.split('-')[0])
                age=(int(age)//10)*10
            if age not in age_dict: 
                age_dict[age]=1
            else: 
                age_dict[age]+=1 
    total_subjects=len(subjects) 
    for entry in age_dict: 
        outf.write(str(entry)+'\t'+str(age_dict[entry])+'\t'+str(float(age_dict[entry])/total_subjects)+'\n')

def summarize_sex(data,outf,args): 
    sex_dict=dict() 
    subjects=set([]) 
    for line in data: 
        tokens=line.split('\t') 
        subject=tokens[0] 
        if subject in subjects: 
            continue 
        subjects.add(subject) 
        sex=tokens[2] 
        if sex not in sex_dict: 
            sex_dict[sex]=1 
        else: 
            sex_dict[sex]+=1
    total_subjects=len(subjects) 
    for entry in sex_dict: 
        outf.write(str(entry)+'\t'+str(sex_dict[entry])+'\t'+str(float(sex_dict[entry])/total_subjects)+'\n') 
def summarize_race(data,outf,args): 
    race_dict=dict() 
    subjects=set([]) 
    for line in data: 
        tokens=line.split('\t') 
        subject=tokens[0] 
        if subject in subjects: 
            continue 
        subjects.add(subject) 
        race=tokens[3] 
        if race not in race_dict: 
            race_dict[race]=1 
        else: 
            race_dict[race]+=1
    total_subjects=len(subjects) 
    for entry in race_dict: 
        outf.write(str(entry)+'\t'+str(race_dict[entry])+'\t'+str(float(race_dict[entry])/total_subjects)+'\n') 

    

def main(): 
    args=parse_args() 
    data=open(args.input,'r').read().strip().split("\n") 
    outf=open(args.outf,'w') 
    if args.field=="age": 
        summarize_age(data,outf,args) 
    elif args.field=="sex": 
        summarize_sex(data,outf,args) 
    elif args.field=="race": 
        summarize_race(data,outf,args) 
    elif args.field=="generic": 
        summarize_generic(data,outf,args) 
    else: 
        raise Exception("no functionality to summarize the specified field:"+args.field)
        
 
        

if __name__=="__main__": 
    main() 
