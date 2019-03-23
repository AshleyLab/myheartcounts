#filter the table "/scratch/PI/euan/projects/mhc/data/tables/appVersionWithDates.tsv" to a specific list of subjects & versions (for efficient use in generating RCT summary tables)
import argparse 
import pandas as pd 
def parse_args(): 
    parser=argparse.ArgumentParser("filter the table \"/scratch/PI/euan/projects/mhc/data/tables/appVersionWithDates.v2.tsv\" to a specific list of subjects & versions (for efficient use in generating RCT summary tables)") 
    parser.add_argument("--source_table",default="/scratch/PI/euan/projects/mhc/data/tables/appVersionWithDates.v2.tsv") 
    parser.add_argument("--version",default=None)
    parser.add_argument("--subjects") 
    parser.add_argument("--outf") 
    return parser.parse_args() 

def main(): 
    args=parse_args() 
    subjects=open(args.subjects,'r').read().strip().split('\n') 
    subject_dict=dict() 
    for line in subjects: 
        subject_dict[line]=1
    print("read in subjects") 
    
    data=pd.read_csv(args.source_table,header=0,sep='\t')
    print("read in appVersion data frame") 
    outf=open(args.outf,'w') 
    outf.write('healthCode\tcreatedOn\tappVersion\n')
    records=dict() 
    row_index=0
    for index,row in data.iterrows(): 
        healthCode=row['healthCode'] 
        if healthCode not in subject_dict: 
            continue 
        if args.version!=None:
            cur_version=row['appVersion'] 
            if (cur_version.startswith(args.version)==False):
                continue
        output_line='\t'.join([row['healthCode'],row['createdOn'].split(' ')[0],row['appVersion']])
        records[output_line]=1
        row_index+=1
        if row_index%1000==0: 
            print(row_index) 

    outf.write('\n'.join(records.keys()))

if __name__=="__main__": 
    main() 

