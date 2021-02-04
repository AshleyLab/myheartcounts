import argparse
import os
import sys

def parse_args():
    parser=argparse.ArgumentParser(description="get unique id's for a given task")
    parser.add_argument("--source_files",nargs="+")
    parser.add_argument("--outf") 
    return parser.parse_args()

def main():
    args=parse_args()
    unique_subjects=set([])
    for f in args.source_files:
        print(f)
        data=open(f,'r').read().strip().split('\n')
        header=data[0].split('\t')
        try:
            health_code_index=header.index("healthCode")
            if health_code_index==-1:
                print("WARNING! inferring healthCode index=5 fo rtable:"+str(f))
                health_code_index=5
        except: 
            print("WARNING! inferring healthCode index=5 fo rtable:"+str(f))
            health_code_index=5
        for line in data[1::]:
            subject=line.split('\t')[health_code_index]
            unique_subjects.add(subject)
    print(len(unique_subjects))
    unique_subjects=list(unique_subjects)
    outf=open(args.outf,'w') 
    outf.write('\n'.join(unique_subjects)+'\n')
if __name__=="__main__":
    main()
    
