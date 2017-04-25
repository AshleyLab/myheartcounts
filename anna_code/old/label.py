data=open('../intermediate_results/feature_groups_main.tsv','r').read().replace('\r\n','\n').split('\n')
if '' in data:
    data.remove('')
    
outf=open('../intermediate_results/feature_groups_main_labeled.tsv','w')
outf.write(data[0]+'\n')
data=data[1::]
for i in range(len(data)):
    entry=data[i]
    outf.write('group'+str(i)+','+entry+'\n')
    
