data=open('../subjects_sorted_unique.txt','r').read().split('\n') 
if '' in data: 
    data.remove('') 
outf=open('../subjects_sorted_unique.filtered','w') 
for line in data: 
    if (len(line)==36) and (line.count('-')==4): 
        outf.write(line+'\n')
