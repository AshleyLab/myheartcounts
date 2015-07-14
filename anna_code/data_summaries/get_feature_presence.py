data=open('../intermediate_results/all_myheart_summary.features','r').read().split('\n')
if '' in data: 
    data.remove('') 
outf=open('../intermediate_results/feature_presence_absence.csv','w') 
outf.write(data[0]+'\n')
for line in data[1::]: 
    line=line.split('\t') 
    subject=line[0] 
    outf.write(subject) 
    for i in range(1,len(line)): 
        if line[i]=="0": 
            outf.write('\t0') 
        elif line[i]=="": 
            outf.write('\t0')
        elif line[i]=="NA":
            outf.write('\t0') 
        else: 
            outf.write('\t1')
    outf.write('\n') 

        
