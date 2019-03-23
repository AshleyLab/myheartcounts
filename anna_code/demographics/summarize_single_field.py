#get counts and % of total for each age group 
import argparse
import pandas as pd 
import pdb 
def parse_args(): 
    parser=argparse.ArgumentParser(description="get counts and % of total for each age group ")
    parser.add_argument("--inputs",nargs="+") 
    parser.add_argument("--fields",nargs="+") 
    parser.add_argument("--subjects",default=None,help="file with list of subjects for whom to calculate demographics. by default all subjects will be used ") 
    parser.add_argument("--version",default=None) 
    parser.add_argument("--output_field_vals",action="store_true")
    parser.add_argument("--outf") 
    return parser.parse_args() 

def summarize_generic(args): 
    if args.subjects!=None: 
        subjects_to_use=open(args.subjects,'r').read().strip().split('\n') 
        subject_dict=dict() 
        for entry in subjects_to_use: 
        subject_dict[entry]=1 
    summary_dict=dict()
    for table in args.inputs: 
        data=pd.read_csv(table,index_col=0,sep='\t',header=0,dtype=object)
        #print(head(data))
        for index,row in data.iterrows(): 
            version=row['appVersion'] 
            if args.version!=None: 
                if (version.startswith(args.version)==False):
                    continue 
            subject=row['healthCode'] 
            if args.subjects!=None: 
                if subject not in subject_dict: 
                    continue 
            if subject not in summary_dict: 
                summary_dict[subject]=dict() 
            for field in args.fields: 
                field_val =row[field]
                summary_dict[subject][field]=field_val
    for field in args.fields: 
        outf=open(args.outf+'.'+field,'w')
        outf.write("Subject\t"+field+"\n")
        for subject in summary_dict: 
            if field in summary_dict[subject]: 
                outf.write(subject+'\t'+str(summary_dict[subject][field])+'\n')
    
                

    

def main(): 
    args=parse_args()
    summarize_generic(args)
        
 
        

if __name__=="__main__": 
    main() 
