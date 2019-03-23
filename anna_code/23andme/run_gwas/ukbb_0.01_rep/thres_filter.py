data=open('all.filtered.txt','r').read().strip().split("\n") 
outf=open('all.filtered.0.01.txt','w') 
thresh=0.01 
for line in data: 
    tokens=line.split('\t') 
    pval=float(tokens[-1]) 
    if pval < thresh: 
        outf.write(line+'\n') 
