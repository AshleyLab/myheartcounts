data=open('age.new','r').read().split('\n')
age_hist=dict()
for line in data:
    if line not in age_hist:
        age_hist[line]=1
    else:
        age_hist[line]+=1
print str(age_hist)
outf=open('age.new.histogram','w')
outf.write('Age\tSubjects\n')
for key in age_hist:
    outf.write(key+'\t'+str(age_hist[key])+'\n')
    
