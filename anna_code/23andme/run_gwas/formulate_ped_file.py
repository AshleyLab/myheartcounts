#combine 23&me subject profiles to generate a ped file in plink 
import argparse 
import numpy as np 
import pdb
def parse_args(): 
    parser=argparse.ArgumentParser(description="combine 23&me subject profiles to generate a ped file in plink")
    parser.add_argument("--subject_files",default="all_genomes.txt")
    parser.add_argument("--map_file",default="/scratch/PI/euan/projects/mhc/23andme/plink/data/23andme_fix.map")
    parser.add_argument("--out_prefix",default="23andme") 
    parser.add_argument("--demographics_table",default="/scratch/PI/euan/projects/mhc/data/tables/cardiovascular-NonIdentifiableDemographicsTask-v2.tsv") 
    parser.add_argument("--sex_field_name",default="NonIdentifiableDemographics.json.patientBiologicalSex") 
    parser.add_argument("--health_code_to_23andme_id",default="/scratch/PI/euan/projects/mhc/data/tables/cardiovascular-23andmeTask-v1.tsv")
    parser.add_argument("--phenotype_file",default="phenotypes.txt")
    parser.add_argument("--phenotype_prefix",default="/scratch/PI/euan/projects/mhc/data/tables/") 
    parser.add_argument("--activity_rct",default="/scratch/PI/euan/projects/mhc/data/timeseries_v2/summary/within_subject_measures.txt") 
    parser.add_argument("--motion_tracker_file",default="/scratch/PI/euan/projects/mhc/data/timeseries_v2/summary/motion_tracker_combined.filtered.txt")
    parser.add_argument("--health_kit_steps",default="/scratch/PI/euan/projects/mhc/data/timeseries_v2/summary/healthkit_combined.stepcount.txt") 
    parser.add_argument("--health_kit_distance",default="/scratch/PI/euan/projects/mhc/data/timeseries_v2/summary/healthkit_combined.distance.txt") 
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
        
def get_id_map(health_code_to_23andme_id,all_genotypes):
    all_genotypes=open(all_genotypes,'r').read().strip().split('\n') 
    subject_dict=dict() 
    for line in all_genotypes:
        id_23me=line.split('/')[-1].split('.')[0]
        subject_dict[id_23me]=None
    data=open(health_code_to_23andme_id,'r').read().strip().split('\n') 
    data[0]='\t'+data[0] 
    header=data[0].split('\t') 
    healthCode_id=header.index('healthCode') 
    userId_23andme=header.index('23andMeUserId.userId')
    profileId_23andme=header.index('23andMeUserId.profileId')
    for line in data[1::]: 
        tokens=line.split('\t') 
        userId_23andme_cur=tokens[userId_23andme] 
        profileId_23andme_cur=tokens[profileId_23andme] 
        healthCode_id_cur=tokens[healthCode_id] 
        keyval=userId_23andme_cur+'-'+profileId_23andme_cur
        if keyval in subject_dict: 
            subject_dict[keyval]=healthCode_id_cur
    rev_dict=dict() 
    subject_dict_filtered=dict() 
    for key in subject_dict: 
        val=subject_dict[key] 
        if val==None: 
            continue 
        rev_dict[val]=key
        subject_dict_filtered[key]=val 
    return subject_dict_filtered,rev_dict

def get_phenotypes(phenotype_file,phenotype_prefix,subject_dict):
    phenotype_dict=dict() 
    phenotype_fields=set([]) 
    #consolidate the parsing -- generate a dictionary of phenotype source file to list of phenotypes from that source file. 
    source_to_field=dict() 
    source_files=open(phenotype_file,'r').read().strip().split('\n') 
    for line in source_files: 
        tokens=line.split('\t') 
        cur_source=tokens[0] 
        cur_field=tokens[1] 
        phenotype_fields.add(cur_field) 
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
                if field not in phenotype_dict[cur_subject]: 
                    phenotype_dict[cur_subject][field]=cur_value
    return phenotype_dict,phenotype_fields 

def get_activity_rct(phenotype_dict,activity_source,subject_dict): 
    data=open(activity_source,'r').read().strip().split('\n')
    activity_fields=set([]) 
    activity_dict=dict() 
    for line in data[1::]: 
        tokens=line.split('\t') 
        subject=tokens[0] 
        if subject not in subject_dict: 
            continue 
        field =tokens[1] 
        if field not in ["HKQuantityTypeIdentifierStepCount","HKQuantityTypeIdentifierDistanceWalk"]: 
            continue 
        intervention=tokens[2] 
        if intervention!="Baseline": 
            activity_fields.add(field+"_"+intervention) 
        value=tokens[3] 
        if subject not in activity_dict: 
            activity_dict[subject]=dict() 
        if field not in activity_dict[subject]: 
            activity_dict[subject][field]=dict() 
        if intervention not in activity_dict[subject][field]: 
            activity_dict[subject][field][intervention]=[float(value)] 
        else: 
            activity_dict[subject][field][intervention].append(value)
    #get the mean delta from Baseline for each intervention 
    for subject in activity_dict: 
        for field in activity_dict[subject]: 
            try:
                mean_baseline=sum(activity_dict[subject][field]['Baseline'])/len(activity_dict[subject][field]['Baseline'])
                for intervention in activity_dict[subject][field]: 
                    if intervention=="Baseline": 
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
        field=tokens[4]
        if field in ['stationary','walking','automotive','cycling','running']: 
            minutes=float(tokens[5])
            fraction=float(tokens[6]) 
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
    for line in steps_data[1::]: 
        tokens=line.split('\t') 
        subject=tokens[0] 
        if subject not in subject_dict: 
            continue 
        value=float(tokens[5]) 
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
        value=float(tokens[5])
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
    data_map=open(args.map_file,'r').read().strip().split('\n') 


    #generate a dictionary of aws file name to subject id 
    subject_ids,mhc_to_23me=get_id_map(args.health_code_to_23andme_id,args.subject_files) 
    print("got map of 23andme id's to health codes") 

    #generate a dictionary of subject -> sex 
    subject_biological_sex_dict=get_biological_sex(args.demographics_table,args.sex_field_name,mhc_to_23me) 
    print("got biological sex of subjects") 

    subject_order=get_ped_file(data_map,args.out_prefix,args.subject_files,subject_biological_sex_dict,subject_ids)
    print("generated genetic data file") 

    #get the phenotype file 
    phenotype_dict,phenotype_fields=get_phenotypes(args.phenotype_file,args.phenotype_prefix,mhc_to_23me)

    print("got phenotype fields without activity") 
    phenotype_dict,activity_fields=get_activity_rct(phenotype_dict,args.activity_rct,subject_order)

    print("got RCT percent change in stepcount and distance")
    all_fields=list(phenotype_fields)+list(activity_fields) 
    
    phenotype_dict,activity_fields=get_healthkit(phenotype_dict,args.health_kit_steps,args.health_kit_distance,subject_order)
    print("got healthkit steps and healthkit distance")
    all_fields=all_fields+list(activity_fields) 

    phenotype_dict,activity_fields=get_motiontracker(phenotype_dict,args.motion_tracker_file,subject_order)
    all_fields=all_fields+list(activity_fields) 
    print("got motion tracker fields") 
    
    #write the phenotype file 
    print("writing phenotype file") 
    write_phenotype_file(args.out_prefix,phenotype_dict,all_fields,subject_order) 
        

if __name__=="__main__": 
    main() 

