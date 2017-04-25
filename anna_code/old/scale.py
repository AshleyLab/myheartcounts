data=open('../intermediate_results/feature_groups.tsv','r').read().replace('\r\n','\n').split('\n')
if '' in data:
    data.remove('')
outf=open('../intermediate_results/features_scaled.tsv','w')
outf.write(data[0]+'\n')
data =data[1::]
for line in data:
    line=line.split('\t')
    first =line[0].split(',')
    scale=first[1]
    name=first[0]
    outf.write(name)
    for i in range(1,len(line)):
        if line[i]=='1':
            outf.write('\t'+scale)
        else:
            outf.write('\t0')
    outf.write('\n')
    
