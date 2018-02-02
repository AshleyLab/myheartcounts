#identify any blob files present in the data tables that have not been downloaded to synapseCache.
import argparse 
from os import listdir
from os.path import isfile, join

def parse_args(): 
    parser=argparse.ArgumentParser(description="identify any blob files present in the data tables that have not been downloaded to synapseCache.") 
    parser.add_argument("--table")
    parser.add_argument("--columns",nargs="+",type=int) 
    parser.add_argument("--blob_source_dir") 
    parser.add_argument("--outf") 
    return parser.parse_args() 
def main(): 
    args=parse_args() 
    outf=open(args.outf,'w')
    table=open(args.table,'r').read().strip().split('\n') 
    c=0
    total=str(len(table))
    for line in table[1::]: 
        c+=1
        if c%1000==0: 
            print(str(c)+"/"+total)
        tokens=line.split('\t') 
        blobs=[tokens[i] for i in args.columns]
        for b in blobs: 
            if b=="NA": 
                continue
            #check if a file exists 
            outer_dir=b[-3::].lstrip('0')                
            if outer_dir=="": 
                outer_dir="0"
            inner_dir=b 
            full_dir=args.blob_source_dir+'/'+outer_dir+'/'+inner_dir+'/'
            onlyfiles = [f for f in listdir(full_dir) if (f.startswith('.')==False) and (isfile(join(full_dir, f)))]
            if len(onlyfiles)==0: 
                outf.write(b+'\n') 
                

if __name__=="__main__": 
    main() 

