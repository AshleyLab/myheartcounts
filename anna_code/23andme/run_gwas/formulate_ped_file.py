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
    parser.add_argument("--activity_source",default="/scratch/PI/euan/projects/mhc/data/timeseries_v2/summary/within_subject_measures.txt") 
    return parser.parse_args() 

def get_biological_sex(demographics_table,sex_field_name): 
    data_dict=dict() 
    data=open(demographics_table,'r').read().strip().split('\n') 
    data[0]='\t'+data[0] 
    header=data[0].split('\t') 
    sex_index=[] 
    healthCode_index=header.index('healthCode') 
    for i in range(len(header)): 
        if header[i]==sex_field_name: 
            sex_index.append(i) 
    for line in data[1::]: 
        tokens=line.split('\t') 
        biological_sex_values=[tokens[i] for i in sex_index]
        if 'NA' in biological_sex_values: 
            biological_sex_values.remove('NA')
        if len(biological_sex_values)>0: 
            biological_sex=biological_sex_values[0] 
        else: 
            biological_sex='-1000' 
        subject_id=tokens[healthCode_index] 
        if subject_id not in data_dict: 
            if biological_sex!='-1000': 
                if biological_sex.lower().__contains__('female'): 
                    biological_sex='2' 
                else: 
                    biological_sex='1'
            data_dict[subject_id]=biological_sex 
    return data_dict         
        
def get_id_map(health_code_to_23andme_id): 
    subject_id_map=dict() 
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
        subject_id_map[userId_23andme_cur+'-'+profileId_23andme_cur]=healthCode_id_cur
    return subject_id_map

def get_phenotypes(phenotype_file,phenotype_prefix):
    phenotype_dict=dict() 
    #consolidate the parsing -- generate a dictionary of phenotype source file to list of phenotypes from that source file. 
    source_to_field=dict() 
    source_files=open(phenotype_file,'r').read().strip().split('\n') 
    for line in source_files: 
        tokens=line.split() 
        cur_source=tokens[0] 
        cur_field=tokens[1] 
        if cur_source not in source_to_field: 
            source_to_field[cur_source]=[cur_field] 
        else: 
            source_to_field[cur_source].append(cur_field) 
    for source_file in source_to_field: 
        data=open(phenotype_prefix+'/'+source_file,'r').read().strip().split('\n') 
        header=data[0].split() 
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
            tokens=line.split() 
            cur_subject=tokens[healthcode_index]
            if cur_subject not in phenotype_dict: 
                phenotype_dict[cur_subject]=dict() 
            for field in field_to_index: 
                cur_index=field_to_index[field] 
                cur_value=tokens[cur_index] 
                if field not in phenotype_dict[cur_subject]: 
                    phenotype_dict[cur_subject][field]=cur_value
    return phenotype_dict 

def get_activity_source(phenotype_dict,activity_source): 
    data=open(activity_source,'r').read().strip().split('\n')
    activity_fields=set([]) 
    for line in data[1::]: 
        tokens=line.split('\t') 
        subject=tokens[0] 
        field=tokens[1]+'_'+tokens[2]+'_'+tokens[4] 
        activity_fields.add(field) 
        value=tokens[3] 
        if subject not in phenotype_dict: 
            phenotype_dict[subject]=dict() 
        phenotype_dict[subject][field]=value 
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
        data=' '.join(alleles) 
        #get the subject id 
        id_23me=snp_file.split('/')[-1].split('.')[0]
        try:
            subject_id=subject_ids[id_23me]
        except: 
            print("Couldn't parse:"+str(subject_id))
            continue 
        subject_order.append(subject_id) 
        try:
            subject_sex=subject_biological_sex_dict[subject_id]
        except: 
            subject_sex='-1000' 
        leading_fields=[subject_id,subject_id,'0','0',subject_sex,'-9']
        outf.write(' '.join(leading_fields)+' '+data+'\n')

def write_phenotype_file(out_prefix,phenotype_dict,all_fields,subject_order): 
    outf=open(out_prefix+".phenotype")
    outf.write('FID'+'\t'+'IID'+'\t'+'\t'.join(all_fields)+'\n')
    for subject in subject_order: 
        output_line=[subject,subject]
        if subject not in phenotype_dict: 
            #no phenotype data available, use all -1000 values 
            output_line=output_line+'-1000'*len(all_fields)
            outf.write('\t'.join(output_line)+'\n')
            continue 
        for phenotype_field in all_fields: 
            if phenotype_field in phenotype_dict[subject]: 
                output_line.append(phenotype_dict[subject][phenotype_field])
            else: 
                output_line.append('-1000') 
        outf.write('\t'.join(output_line)+'\n')


def main(): 
    args=parse_args()
    data_map=open(args.map_file,'r').read().strip().split('\n') 

    #generate a dictionary of subject -> sex 
    subject_biological_sex_dict=get_biological_sex(args.demographics_table,args.sex_field_name) 
    print("got biological sex of subjects") 

    #generate a dictionary of aws file name to subject id 
    subject_ids=get_id_map(args.health_code_to_23andme_id) 
    print("got map of 23andme id's to health codes") 

    get_ped_file(data_map,args.out_prefix,args.subject_files,subject_biological_sex_dict,subject_ids)
    print("generated genetic data file") 

    #get the phenotype file 
    phenotype_dict=get_phenotypes(args.phenotype_file,args.phenotype_prefix)
    print("got phenotype fields without activity") 
    phenotype_dict,activity_fields=get_activity_source(phenotype_dict,activity_source)
    print("got activity fields") 
    all_fields=args.phenotype_fields+list(activity_fields) 
    
    #write the phenotype file 
    print("writing phenotype file") 
    write_phenotype_file(args.out_prefix,phenotype_dict,all_fields,subject_order) 
        

if __name__=="__main__": 
    main() 

