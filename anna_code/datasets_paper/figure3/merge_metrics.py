import argparse 
def parse_args(): 
    parser=argparse.ArgumentParser()
    parser.add_argument("--histograms",nargs="+")
    parser.add_argument("--categories",nargs="+") 
    parser.add_argument("--outf") 
    return parser.parse_args() 
def main():
    args=parse_args() 
    outf=open(args.outf,'w') 
    outf.write('Value'+'\t'+'\t'.join(args.categories)+'\n')
    val_dict=dict() 
    for index in range(len(args.histograms)): 
        f=args.histograms[index] 
        cur_category=args.categories[index] 
        data=open(f,'r').read().strip().split('\n') 
        for line in data: 
            tokens=line.split('\t') 
            cur_val=tokens[0] 
            if cur_val not in val_dict: 
                val_dict[cur_val]=dict() 
            val_dict[cur_val][cur_category]=tokens[1] 
    #write output file 
    for cur_val in val_dict: 
        outf.write(cur_val) 
        for cur_category in args.categories: 
            if cur_category in val_dict[cur_val]: 
                outf.write('\t'+val_dict[cur_val][cur_category])
            else: 
                outf.write('\t0') 
        outf.write('\n') 
        
if __name__=="__main__": 
    main() 

