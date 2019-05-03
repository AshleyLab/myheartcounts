import argparse 
import pandas as pd 
import numpy as np 
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
    data=pd.read_csv(args.i,header=0,sep='\t',dtype=str) 
    #generate dictionary of field-name --> control value 
    case_control_map=open(args.case_control_map,'r').read().strip().split('\n') 
    case_control_dict=dict() 
    for line in case_control_map[1::]: 
        tokens=line.split('\t') 
        #field --> [control value, comma-separated list of case values]
        print(str(tokens))
        case_control_dict[tokens[0]]=[tokens[1],tokens[2]] 
    
    #subset to just the categorical fields 
    fields=open(args.fields,'r').read().strip().split('\n') 
    data=data.ix[:,['FID','IID']+fields]
    #set all missing values to -1000
    data=data.fillna("-1000")
    binarized=dict() 
    binarized['FID']=data['FID'] 
    binarized['IID']=data['IID']
    for field in case_control_dict: 
        for case_val in case_control_dict[field][1].split(','): 
            field_subset=".".join([str(i) for i in [field,case_val]])
            print("processing:"+str(field_subset))
            #pdb.set_trace() 
            binarized[field_subset]=data[field]
            cases=np.where(data[field].str.contains(case_val,regex=False)==True) 
            controls=np.where(data[field].str.contains(case_val,regex=False)==False) 
            missing=np.where(data[field]=="-1000") 
            binarized[field_subset].loc[controls]=1 
            binarized[field_subset].loc[cases]=2
            binarized[field_subset].loc[missing]='-1000'            

    #convert the case/control field dictionary into a pandas data frame 
    binarized_df=pd.DataFrame.from_dict(binarized) 
    #write the output case-control file
    binarized_df.to_csv(args.o,sep='\t',index=False)


if __name__=="__main__": 
    main() 
