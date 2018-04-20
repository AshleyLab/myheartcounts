import argparse 
def parse_args(): 
    parser=argparse.ArgumentParser(description="case-control encoding of categorical phenotypes")
    parser.add_argument("--case_control_map",default="case_control.map")
    parser.add_argument("--i",default="categorical.phenotypes.raw.csv")
    parser.add_argument("--o",default="categorical.phenotypes.casecontrol")
    return parser.parse_args() 

def main(): 
    args=parse_args() 
    data=open(args.i,'r').read().strip().split('\n') 
    case_control_map=open(args.case_control_map,'r').read().strip().split('\n') 
    case_control_dict=dict() 
    for line in case_control_map: 
        tokens=line.split('\t') 
        case_control_dict[tokens[0]]=tokens[1] 
    header=data[0].split('\t')
    outf=open(args.o,'w')
    outf.write('\t'.join(header)+'\n') 
    for line in data[1::]: 
        tokens=line.split('\t') 
        outf.write('\t'.join(tokens[0:2]))
        for i in range(2,len(tokens)): 
            cur_field=header[i] 
            cur_val=tokens[i] 
            if cur_val=="-1000": 
                outf.write('\t-1000') 
            elif cur_val=="": 
                outf.write('\t-1000')
            elif cur_val==case_control_dict[cur_field]: 
                outf.write('\t1') 
            else: 
                outf.write('\t2') 
        outf.write('\n') 

                
if __name__=="__main__": 
    main() 
