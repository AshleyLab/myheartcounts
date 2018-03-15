import argparse
from os import listdir
from os.path import isfile, join
import json
import pdb

def parse_args():
    parser=argparse.ArgumentParser(description="get steps and distance from 6MWT pedometer files")
    parser.add_argument("--pedometer_dir")
    parser.add_argument("--outf")
    return parser.parse_args()

def main():
    args=parse_args()
    outf=open(args.outf,'w')
    outf.write('Subject\tDistance(m)\tSteps\tEndTime\n')
    data_dir=args.pedometer_dir
    subject_dirs=listdir(data_dir)
    counter=0 
    for subject_dir in subject_dirs:
        counter+=1
        if counter %100==0:
            print(str(counter))
        fnames=[f for f in listdir(join(data_dir,subject_dir))]
        for fname in fnames:
            fname=data_dir+'/'+subject_dir+'/'+fname 
            data=json.loads(open(fname,'r').read())
            final_entry=data[-1]
            final_distance=final_entry['distance']
            final_steps=final_entry['numberOfSteps']
            final_timestamp=final_entry['endDate']
            subject=subject_dir
            outf.write(subject+'\t'+str(final_distance)+'\t'+str(final_steps)+'\t'+str(final_timestamp)+'\n')
            

if __name__=="__main__":
    main()
    
