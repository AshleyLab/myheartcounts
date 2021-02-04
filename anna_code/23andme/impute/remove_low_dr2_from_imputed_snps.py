import argparse 
import pandas as pd 
def parse_args(): 
    parser=argparse.ArgumentParser(description="Filter Beagle imputed SNPs with DR2<0.8")
    parser.add_argument("--input_vcf") 
    parser.add_argument("--thresh",type=float,default=0.8) 
    parser.add_argument("--outf") 
    return parser.parse_args() 

def main(): 
    args=parse_args() 
    data=pd.read_table(args.input_vcf,skiprows=9,header=0,usecols=[2,7])
    print("loaded vcf:"+str(args.input_vcf)) 
    outf=open(args.outf,'w') 
    for index,row in data.iterrows(): 
        snp_entry=row['ID'] 
        info=row['INFO'] 
        dr2=info.split(';')[0].split('=')[1].split(',') 
        dr2=max([float(i) for i in dr2]) 
        if dr2<args.thresh: 
            snp_entry=snp_entry.split(';') 
            for snp in snp_entry: 
                outf.write(snp+'\n')

if __name__=="__main__": 
    main() 
