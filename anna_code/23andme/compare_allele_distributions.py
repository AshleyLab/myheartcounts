import argparse 
from collections import defaultdict 
def parse_args(): 
    parser=argparse.ArgumentParser()
    parser.add_argument("--file_list1")
    parser.add_argument("--file_list2")
    parser.add_argument("--o")
    parser.add_argument("--numpos",type=int,default=2266424)
    return parser.parse_args() 

def main(): 
    args=parse_args() 
    numpos=args.numpos 
    freqs=dict() 
    freqs[1]=dict()
    freqs[2]=dict()
    chars=set([]) 
    for i in range(numpos): 
        freqs[1][i]=defaultdict(int) 
        freqs[2][i]=defaultdict(int) 
    print("set up dictionaries") 
    files1=open(args.file_list1,'r').read().strip().split('\n') 
    files2=open(args.file_list2,'r').read().strip().split('\n') 
    
    for f1 in files1:
        data=open(f1,'r').read() 
        for i in range(numpos):
            try:
                chars.add(data[i])
                freqs[1][i][data[i]]+=1 
            except: 
                continue 
    print("done with batch 1") 

    for f2 in files2: 
        data=open(f2,'r').read() 
        for i in range(numpos):
            try:
                chars.add(data[i]) 
                freqs[2][i][data[i]]+=1 
            except: 
                continue 
    print("done with batch 2")  
    
    outf1=open(args.o+".batch1",'w')
    outf2=open(args.o+".batch2",'w') 
    chars=list(chars)
    outf1.write('pos'+'\t'+'\t'.join(chars)+'\n')
    outf2.write('pos'+'\t'+'\t'.join(chars)+'\n')
    for i in range(numpos): 
        outf1.write(str(i))
        outf2.write(str(i))
        for c in chars: 
            outf1.write('\t'+str(freqs[1][i][c]))
            outf2.write('\t'+str(freqs[2][i][c]))
        outf1.write('\n') 
        outf2.write('\n')  
    
if __name__=="__main__": 
    main() 

