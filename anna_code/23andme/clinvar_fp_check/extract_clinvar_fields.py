import pandas as pd
data=open("FP_candidates_with_clinvar_annotations.tsv",'r').read().strip().split('\n') 
outf=open("FP_candidates_with_clinvar_annotations.CLNDN.CLNSIG.tsv",'w')
outf.write(data[0]+'\t'+'CLNSIG'+'\t'+'CLNDN'+'\n')

for line in data[1::]:
    tokens=line.split('\t')
    info=tokens[-1].split(';')
    CLNSIG=None
    CLNDN=None
    for entry in info:
        if entry.startswith("CLNSIG"):
            CLNSIG=entry
        elif entry.startswith("CLNDN"):
            CLNDN=entry
    outf.write('\t'.join(tokens[0:10]))
    outf.write('\t'+str(CLNSIG)+'\t'+str(CLNDN)+'\n')
    
