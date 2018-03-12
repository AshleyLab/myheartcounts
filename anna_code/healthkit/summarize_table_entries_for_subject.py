#summarize all healthkit and/or motion tracker entries for a given subject, from the raw table data
import argparse
from os import listdir
from os.path import isfile, join

def parse_args():
    parser=argparse.ArgumentParser(description="")
    parser.add_argument("--subject")
    parser.add_argument("--source_tables",nargs="+")
    parser.add_argument("--synapseCache",default="/scratch/PI/euan/projects/mhc/data/synapseCache")
    parser.add_argument("--outf")
    return parser.parse_args()

def main():
    args=parse_args()
    subject=args.subject 
    blobs=[] 
    for table in args.source_tables:
        data=open(table,'r').read().strip().split('\n')
        for line in data:
            tokens=line.split('\t')
            for t in tokens:
                if t==subject:
                    #get the corresponding entry
                    blobs.append(tokens[-1])
                    break
    print("got list of blobs!")
    outf=open(args.outf,'w')
    for blob in blobs:
        last3=blob[-3::].lstrip('0')
        if last3=="":
            last3="0"
        blobdir=args.synapseCache+'/'+last3+'/'+blob
        #get all the files in the blob dir
        onlyfiles = [blobdir+'/'+f for f in listdir(blobdir) if isfile(join(blobdir, f))]
        print(str(onlyfiles))
        for f in onlyfiles:
            if f.endswith('.csv'):
                data=open(f,'r').read()
                outf.write(data)
                
if __name__=="__main__":
    main()
    
    
