#identifies records in each table where the time lag between uploadDate and createdOn is greater than 24 hours 
import argparse 
import pandas as pd 
import pdb 

def parse_args(): 
    parser=argparse.ArgumentParser(description="identifies records in each table where the time lag between uploadDate and createdOn is greater than 24 hours ") 
    parser.add_argument("--tables",nargs="+") 
    parser.add_argument("--outf",nargs="+") 
    return parser.parse_args() 
def main(): 
    args=parse_args() 
    for cur_index in range(len(args.tables)): 
        table=args.tables[cur_index]
        print("processing:"+table) 
        data=pd.read_csv(table,header=0,sep='\t') 
        data['uploadDate']=pd.to_datetime(data['uploadDate'])
        data['createdOn']=pd.to_datetime(data['createdOn'])
        time_delta=data['uploadDate']-data['createdOn'] 
        delays=data[[i.days>0 for i in time_delta]]
        delays=delays.sort_values(by='appVersion')
        delays.to_csv(args.outf[cur_index],index=False,sep='\t')

if __name__=="__main__": 
    main() 
