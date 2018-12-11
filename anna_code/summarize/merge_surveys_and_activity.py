import pandas as pd 
from functools import reduce 
import argparse 

def parse_args(): 
    parser=argparse.ArgumentParser(description="Merge specified list of tables by specified ID; full join") 
    parser.add_argument("--tables",nargs="+") 
    parser.add_argument("--outf") 
    parser.add_argument("--index",help="field to use for merging") 
    return parser.parse_args() 

def main(): 
    args=parse_args() 
    dfs=[] 
    for f in args.tables: 
        print(f) 
        data=pd.read_table(f,header=0,sep='\t') 
        for c in ['recordId','appVersion','phoneInfo','uploadDate','externalId','dataGroups','createdOn','createdOnTimeZone','userSharingScope','validationErrors','rawData']: 
            try:
                data=data.drop([c],axis=1)
            except: 
                print(c+" not in data") 
        data.drop_duplicates(subset ="healthCode", 
                     keep = False, inplace = True) 
        print('filtered!') 
        dfs.append(data) 
    print("loaded all data frames")     
    print("starting join") 
    df_final=reduce(lambda left,right: pd.merge(left,right,how='outer',on=args.index),dfs)
    print("writing output file") 
    df_final.to_csv(args.outf,sep='\t',header=True,index=False)

if __name__=="__main__": 
    main() 
