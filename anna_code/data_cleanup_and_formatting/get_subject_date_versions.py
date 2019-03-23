#obtain the appVersion used by each subject on any given date. Done by aggregating across all tables that have healthCode, createdOn, appVersion"
import argparse 
import pandas as pd 
from os import listdir
from os.path import isfile, join
import pdb 

def parse_args(): 
    parser=argparse.ArgumentParser(description="Obtain the appVersion used by each subject on any given date. Done by aggregating across all tables that have healthCode, createdOn, appVersion") 
    parser.add_argument("--source_dir") 
    parser.add_argument("--outf") 
    return parser.parse_args() 

def main(): 
    args=parse_args() 
    allfiles = [f for f in listdir(args.source_dir) if isfile(join(args.source_dir, f))]    
    frames=[] 
    for f in allfiles: 
        print(f)
        try:
            data=pd.read_csv('/'.join([args.source_dir,f]),
                             header=0,
                             sep='\t',
                             index_col=0,
                             usecols=["healthCode", "createdOn", "appVersion"])
            data.dropna(inplace=True)
            frames.append(data)
        except:
            print("skipping"+f)
            continue

    result = pd.concat(frames,sort=True)
    result.to_csv(args.outf, sep='\t',header=True, index=False)
if __name__=="__main__":
    main() 

