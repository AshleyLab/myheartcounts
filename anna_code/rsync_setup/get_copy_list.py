import argparse
import pdb

def parse_args():
    parser=argparse.ArgumentParser(description="Pull out the synapse cache entries to copy")
    parser.add_argument("--synapseCacheKey")
    parser.add_argument("--outf")
    return parser.parse_args()
def main():
    args=parse_args()
    synapseCache_dict=dict()
    synapseCache_data=open(args.synapseCacheKey,'r').read().strip().split('\n')
    for line in synapseCache_data:
        tokens=line.split('\t')
        print(str(tokens))
        synapseCache_dict[tokens[0]]=[int(i) for i in tokens[1].split(',')]
    print("build synapseCacheDict")
    outf=open(args.outf,'w')
    for filename in synapseCache_dict:
        data=open(filename,'r').read().strip().split('\n')
        fields_to_get=synapseCache_dict[filename]
        for line in data[1::]:
            tokens=line.split('\t')
            print(str(tokens))
            print(str(fields_to_get))
            tokens=[tokens[i] for i in fields_to_get]
            #get the last three fields
            for token in tokens:
                if token=="NA":
                    continue 
                outer_dir=token[-3::]
                inner_dir=token
                outf.write(outer_dir+"/"+inner_dir+'\n')
    
                   

if __name__=="__main__":
    main()
    
