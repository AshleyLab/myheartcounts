import argparse 
import pandas as pd 
import pdb 
def parse_args(): 
    parser=argparse.ArgumentParser(description="case-control encoding of categorical phenotypes")
    parser.add_argument("--case_control_map",default="case_control.map")
    parser.add_argument("--i",default="../23andme.phenotype")
    parser.add_argument("--fields",default="fields.categorical")
    parser.add_argument("--o",default="categorical.phenotypes.casecontrol")
    return parser.parse_args() 

def main(): 
    args=parse_args()

    #read in the phenotype data 
    data=pd.read_csv(args.i,header=0,sep='\t') 

    #generate dictionary of field-name --> control value 
    case_control_map=open(args.case_control_map,'r').read().strip().split('\n') 
    case_control_dict=dict() 
    for line in case_control_map[1::]: 
        tokens=line.split('\t') 
        case_control_dict[tokens[0]]=tokens[1] 

    #subset to just the categorical fields 
    fields=open(args.fields,'r').read().strip().split('\n') 
    data=data.ix[:,['FID','IID']+fields]
    #set all missing values to -1000
    data=data.fillna("-1000")
    for field in case_control_dict: 
        #get controls 
        controls=data[field]==case_control_dict[field] 
        #get cases 
        cases=data[field]!=case_control_dict[field] 
        missing=data[field]=="-1000" 
        #updated data frame to 1 for control, 2 for case 
        data.loc[controls,field]=1
        data.loc[cases,field]=2
        data.loc[missing,field]="-1000"
    #write the output case-control file
    data.to_csv(args.o,sep='\t',index=False)


if __name__=="__main__": 
    main() 
