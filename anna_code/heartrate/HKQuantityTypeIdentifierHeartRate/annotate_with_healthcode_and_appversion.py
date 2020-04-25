#annotate healthkit entries from synapseCache with appropriate health Code and app version 
import pandas as pd 
import argparse 
def parse_args(): 
    parser=argparse.ArgumentParser(description="#annotate healthkit entries from synapseCache with appropriate health Code and app version ")
    parser.add_argument("--metadata",default="subset.cardiovascular-HealthKitDataCollector-v1.tsv") 
    parser.add_argument("--hr_data_slice")
    return parser.parse_args() 

def main(): 
    args=parse_args() 
    metadata=open(args.metadata,'r').read().strip().split('\n') 
    metadata_dict=dict() 
    for line in metadata: 
        tokens=line.split('\t') 
        metadata_dict[tokens[-1]]=tokens[0:2]
    print("made metadata dict") 
    outf=open(args.hr_data_slice+".annotated",'w') 
    data=open(args.hr_data_slice,'r').read().replace('.csv:','.csv,').replace('.json:','.json,').strip().split('\n') 
    print("loaded data slice to annotate") 
    counter=0 
    for line in data: 
        counter+=1 
        if counter %1000==0: 
            print(str(counter)) 
        tokens=line.split(',') 
        fname=tokens[0] 
        if fname.endswith('.json'): 
            continue 
        blob_id=tokens[0].split('/')[-2] 
        try:
            cur_metadata=metadata_dict[blob_id]
            outf.write('\t'.join(cur_metadata)+'\t'+'\t'.join(tokens)+'\n')
        except: 
            print("could not find:"+str(blob_id))
            continue
            
if __name__=="__main__":
    main() 


