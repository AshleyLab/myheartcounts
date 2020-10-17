#combine 23&me subject profiles to generate a ped file in plink 
import argparse 
import numpy as np 
import pdb
from statistics import mode 

def parse_args(): 
    parser=argparse.ArgumentParser(description="generate subject phenotype matrix")
    parser.add_argument("--subjects",default="subjects.txt")
    parser.add_argument("--out_prefix",default="phenotypes") 
    parser.add_argument("--demographics_table",default="/scratch/PI/euan/projects/mhc/data/tables/cardiovascular-NonIdentifiableDemographicsTask-v2.tsv") 
    parser.add_argument("--sex_field_name",default="NonIdentifiableDemographics.json.patientBiologicalSex") 
    parser.add_argument("--phenotype_file",default="phenotypes.txt")
    parser.add_argument("--phenotype_prefix",default="/scratch/PI/euan/projects/mhc/data/tables/") 
    parser.add_argument("--activity_rct",default="/scratch/PI/euan/projects/mhc/data/timeseries_allversions/parsed_HealthKitData.steps.tsv") 
    parser.add_argument("--motion_tracker_file",default="/scratch/PI/euan/projects/mhc/data/timeseries_allversions/parsed_motionActivity.0")
    parser.add_argument("--health_kit_steps",default="/scratch/PI/euan/projects/mhc/data/timeseries_allversions/parsed_HealthKitData.steps.tsv")
    parser.add_argument("--health_kit_distance",default="/scratch/PI/euan/projects/mhc/data/timeseries_allversions/parsed_HealthKitData.distance.tsv")
    return parser.parse_args() 

def get_biological_sex(demographics_table,sex_field_name,subject_dict): 
    data_dict=dict() 
    data=open(demographics_table,'r').read().strip().split('\n') 
    data[0]='\t'+data[0] 
    header=data[0].split('\t') 
    sex_index=[14,15] 
    healthCode_index=header.index('healthCode') 
    #for i in range(len(header)): 
    #    if header[i]==sex_field_name: 
    #        sex_index.append(i) 
    for line in data[1::]: 
        tokens=line.split('\t') 
        subject_id=tokens[healthCode_index] 
        if subject_id not in subject_dict: 
            continue 
        biological_sex_values=[tokens[i] for i in sex_index]
        if 'NA' in biological_sex_values: 
            biological_sex_values.remove('NA')
        if len(biological_sex_values)>0: 
            biological_sex=biological_sex_values[0] 
        else: 
            biological_sex='-1000' 
        if subject_id not in data_dict: 
            if biological_sex!='-1000': 
                if biological_sex.lower().__contains__('female'): 
                    biological_sex='2' 
                else: 
                    biological_sex='1'
            data_dict[subject_id]=biological_sex 
    return data_dict         
        

def get_phenotypes(phenotype_file,phenotype_prefix,subject_dict):
    phenotype_dict=dict() 
    phenotype_fields=set([]) 
    #consolidate the parsing -- generate a dictionary of phenotype source file to list of phenotypes from that source file. 
    source_to_field=dict() 
    field_to_datatype=dict() 
    source_files=open(phenotype_file,'r').read().strip().split('\n') 
    for line in source_files: 
        tokens=line.split('\t') 
        cur_source=tokens[0] 
        cur_field=tokens[1] 
        cur_field_datatype=tokens[2] 
        phenotype_fields.add(cur_field) 
        field_to_datatype[cur_field]=cur_field_datatype
        if cur_source not in source_to_field: 
            source_to_field[cur_source]=[cur_field] 
        else: 
            source_to_field[cur_source].append(cur_field) 
    for source_file in source_to_field: 
        data=open(phenotype_prefix+'/'+source_file,'r').read().strip().split('\n') 
        header=data[0].split('\t') 
        fields=source_to_field[source_file] 
        field_to_index=dict() 
        if 'healthCode' in header:             
            healthcode_index=header.index('healthCode')+1
            for field in fields: 
                field_to_index[field]=header.index(field)+1
        else: 
            healthcode_index=header.index('Subject')
            for field in fields: 
                field_to_index[field]=header.index(field) 
        for line in data[1::]: 
            tokens=line.split('\t') 
            cur_subject=tokens[healthcode_index]
            if cur_subject not in subject_dict: 
                continue 
            if cur_subject not in phenotype_dict: 
                phenotype_dict[cur_subject]=dict() 
            for field in field_to_index: 
                cur_index=field_to_index[field] 
                cur_value=tokens[cur_index] 
                cur_value=cur_value.replace('[','') 
                cur_value=cur_value.replace(']','') 
                if field not in phenotype_dict[cur_subject]: 
                    phenotype_dict[cur_subject][field]=[cur_value]
                else: 
                    phenotype_dict[cur_subject][field].append(cur_value)
    #get the average phenotype value for the continuous fields and the most common (mode) for categorical fields, per user 
    # this is to handle multiple responses (i.e. daily sleep survey) 
    for subject in phenotype_dict: 
        for field in phenotype_dict[subject]: 
            field_type=field_to_datatype[field] 
            if field_type=="categorical": 
                #get the mode 
                try:
                    phenotype_dict[subject][field]=mode([str(i) for i in phenotype_dict[subject][field]])
                except: 
                    phenotype_dict[subject][field]=str(phenotype_dict[subject][field][0])
                    
            else: 
                #get the mean 
                try:
                    phenotype_dict[subject][field]=sum([float(i) for i in phenotype_dict[subject][field]])/len(phenotype_dict[subject][field])
                except: 
                    #handle NA's 
                    vals=phenotype_dict[subject][field]
                    print(vals) 
                    while 'NA' in vals: 
                        vals.remove('NA') 
                    if len(vals)>0: 
                        phenotype_dict[subject][field]=sum([float(i) for i in vals])/len(vals)
                    else: 
                        phenotype_dict[subject][field]='NA' 
    return phenotype_dict,phenotype_fields 

def get_activity_rct(phenotype_dict,activity_source,subject_dict): 
    data=open(activity_source,'r').read().strip().split('\n')
    activity_fields=set([]) 
    activity_dict=dict() 
    allowed_interventions=['baseline','walk','stand','cluster','read_aha']
    for line in data[1::]: 
        tokens=line.split('\t') 
        intervention=tokens[4] 
        if intervention not in allowed_interventions: 
            continue 
        subject=tokens[0] 
        if subject not in subject_dict: 
            continue 
        field =tokens[6] 
        if field not in ["HKQuantityTypeIdentifierStepCount","HKQuantityTypeIdentifierDistanceWalk"]: 
            continue 
        if intervention!="baseline": 
            activity_fields.add(field+"_"+intervention) 
        value=tokens[7] 
        if subject not in activity_dict: 
            activity_dict[subject]=dict() 
        if field not in activity_dict[subject]: 
            activity_dict[subject][field]=dict() 
        if intervention not in activity_dict[subject][field]: 
            activity_dict[subject][field][intervention]=[float(value)] 
        else: 
            activity_dict[subject][field][intervention].append(value)
    #get the mean delta from baseline for each intervention 
    for subject in activity_dict: 
        for field in activity_dict[subject]: 
            try:
                mean_baseline=sum(activity_dict[subject][field]['baseline'])/len(activity_dict[subject][field]['baseline'])
                for intervention in activity_dict[subject][field]: 
                    if intervention=="baseline": 
                        continue 
                    intervention_mean=sum(activity_dict[subject][field][intervention])/len(activity_dict[subject][field][intervention])
                    delta=(intervention_mean-mean_baseline)/mean_baseline 
                    if subject not in phenotype_dict: 
                        phentype_dict[subject]=dict() 
                    print('ADDED RCT VALUE!') 
                    phenotype_dict[subject][field+"_"+intervention]=delta 
            except: 
                continue
    return phenotype_dict,activity_fields

#get mean duration in minutes and mean fraction for each activity state 
def get_motiontracker(phenotype_dict,motion_tracker_file,subject_dict): 
    data=open(motion_tracker_file,'r').read().strip().split('\n') 
    motion_dict=dict() 
    activity_fields=set([]) 
    for line in data[1::]: 
        tokens=line.split('\t') 
        subject=tokens[0] 
        if subject not in subject_dict: 
            continue 
        field=tokens[5]
        if field in ['stationary','walking','automotive','cycling','running']: 
            minutes=float(tokens[6])
            fraction=float(tokens[7]) 
            if subject not in motion_dict: 
                motion_dict[subject]=dict() 
            f1=field+"_Mins" 
            f2=field+"_Fract" 
            activity_fields.add(f1) 
            activity_fields.add(f2) 
            if f1 not in motion_dict[subject]: 
                motion_dict[subject][f1]=[minutes] 
            else: 
                motion_dict[subject][f1].append(minutes) 
            if f2 not in motion_dict[subject]: 
                motion_dict[subject][f2]=[fraction] 
            else: 
                motion_dict[subject][f2].append(fraction) 
    for subject in motion_dict: 
        if subject not in phenotype_dict: 
            phenotype_dict[subject]=dict() 
        for field in motion_dict[subject]: 
            phenotype_dict[subject][field]=sum(motion_dict[subject][field])/len(motion_dict[subject][field])
    return phenotype_dict,activity_fields 
    

def get_healthkit(phenotype_dict,healthkit_steps_file,healthkit_distance_file,subject_dict): 
    activity_fields=["HKQuantityTypeIdentifierStepCount","HKQuantityTypeIdentifierDistanceWalk"] 
    steps_data=open(healthkit_steps_file,'r').read().strip().split('\n') 
    step_dict=dict() 
    dist_dict=dict() 
    for line in steps_data: 
        tokens=line.split('\t') 
        subject=tokens[0] 
        if subject not in subject_dict: 
            continue 
        value=float(tokens[7]) 
        if subject not in step_dict: 
            step_dict[subject]=[value] 
        else: 
            step_dict[subject].append(value) 

    dist_data=open(healthkit_distance_file,'r').read().strip().split('\n') 
    for line in dist_data[1::]: 
        tokens=line.split('\t') 
        subject=tokens[0] 
        if subject not in subject_dict: 
            continue 
        value=float(tokens[7])
        if subject not in dist_dict: 
            dist_dict[subject]=[value] 
        else: 
            dist_dict[subject].append(value) 
    #get the averages 
    for subject in step_dict: 
        if subject not in phenotype_dict: 
            phenotype_dict[subject]=dict() 
        mean_steps=sum(step_dict[subject])/len(step_dict[subject])
        phenotype_dict[subject]["HKQuantityTypeIdentifierStepCount"]=mean_steps 
    for subject in dist_dict: 
        if subject not in phenotype_dict: 
            phenotype_dict[subject]=dict() 
        mean_dist=sum(dist_dict[subject])/len(dist_dict[subject])         
        phenotype_dict[subject]["HKQuantityTypeIdentifierDistanceWalk"]=mean_dist 
    return phenotype_dict,activity_fields 

def get_ped_file(data_map,out_prefix,subject_files,subject_biological_sex,subject_ids):  
    num_snps=len(data_map) 
    outf=open(out_prefix+".ped",'w') 
    snp_files=open(subject_files).read().strip().split('\n') 
    subject_order=[] 
    for snp_file in snp_files: 
        print(snp_file)
        data=open(snp_file,'r').read()[0:2*num_snps]
        alleles=[] 
        for entry in data: 
            if entry not in ['A','T','C','G']: 
                alleles.append('0') 
            else: 
                alleles.append(entry) 
        delta=2*num_snps - len(data) 
        for i in range(delta): 
            alleles.append('0')
        if len(alleles)!=(2*num_snps): 
            pdb.set_trace() 
        data=' '.join(alleles) 
        #get the subject id 
        id_23me=snp_file.split('/')[-1].split('.')[0]
        try:
            subject_id=subject_ids[id_23me]
            subject_order.append(subject_id) 
        except: 
            print("Couldn't parse:"+str(subject_id))
            continue 
        try:
            subject_sex=subject_biological_sex[subject_id]
        except: 
            #pdb.set_trace() 
            subject_sex='-1000' 
        leading_fields=[subject_id,subject_id,'0','0',subject_sex,'-9']
        outf.write(' '.join([str(i) for i in leading_fields])+' '+data+'\n')
    return subject_order

def write_phenotype_file(out_prefix,phenotype_dict,all_fields,subject_order): 
    outf=open(out_prefix+".phenotype",'w')
    outf.write('FID'+'\t'+'IID'+'\t'+'\t'.join(all_fields)+'\n')
    for subject in subject_order: 
        output_line=[subject,subject]
        if subject not in phenotype_dict: 
            #no phenotype data available, use all -1000 values 
            output_line='\t'.join([str(i) for i in output_line])+'\t'+'\t'.join(['-1000' for i in range(len(all_fields))])
            outf.write(output_line+'\n') 
            continue 
        for phenotype_field in all_fields: 
            if phenotype_field in phenotype_dict[subject]: 
                output_line.append(phenotype_dict[subject][phenotype_field])
            else: 
                output_line.append('-1000') 
        outf.write('\t'.join([str(i) for i in output_line])+'\n')
    

def main(): 
    args=parse_args()
    subjects=open(args.subjects,'r').read().strip().split('\n') 
    subject_dict=dict() 
    for subject in subjects: 
        subject_dict[subject]=1 
    #generate a dictionary of subject -> sex 
    subject_biological_sex_dict=get_biological_sex(args.demographics_table,args.sex_field_name,subject_dict) 
    print("got biological sex of subjects") 

    #get the phenotype file 
    phenotype_dict,phenotype_fields=get_phenotypes(args.phenotype_file,args.phenotype_prefix,subject_dict)

    print("got phenotype fields without activity") 
    phenotype_dict,activity_fields=get_activity_rct(phenotype_dict,args.activity_rct,subject_dict)

    print("got RCT percent change in stepcount and distance")
    all_fields=list(phenotype_fields)+list(activity_fields) 
    
    phenotype_dict,activity_fields=get_healthkit(phenotype_dict,args.health_kit_steps,args.health_kit_distance,subject_dict)
    print("got healthkit steps and healthkit distance")
    all_fields=all_fields+list(activity_fields) 

    phenotype_dict,activity_fields=get_motiontracker(phenotype_dict,args.motion_tracker_file,subject_dict)
    all_fields=all_fields+list(activity_fields) 
    print("got motion tracker fields") 
    
    #write the phenotype file 
    print("writing phenotype file") 
    write_phenotype_file(args.out_prefix,phenotype_dict,all_fields,subject_dict) 
        

if __name__=="__main__": 
    main() 

