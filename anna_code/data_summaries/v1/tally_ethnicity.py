data=open('ethnicity.csv','r').read().split('\n') 
tallies=dict() 
for line in data: 
    if line not in tallies: 
        tallies[line]=1
    else: 
        tallies[line]+=1 
outf=open('ethnicity_tally.tsv','w') 
for ethnicity in tallies: 
    outf.write(ethnicity+'\t'+str(tallies[ethnicity])+'\n') 
