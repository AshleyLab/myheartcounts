import argparse
import os
import sys

def parse_args():
    parser=argparse.ArgumentParser(description="get unique id's for a given task")
    parser.add_argument("--source_files",nargs="+")
    return parser.parse_args()

def main():
    args=parse_args()
    print(args) 
    unique_subjects=set([])
    print(args)
    for f in args.source_files:
        print(f)
        data=open(f,'r').read().strip().split('\n')
        header=data[0].split('\t')
        health_code_index=header.index("healthCode")
        if health_code_index==-1:
            print(f)
            continue
        for line in data[1::]:
            subject=line.split('\t')[health_code_index+1]
            unique_subjects.add(subject)
    print(len(unique_subjects))
if __name__=="__main__":
    main()
    
