data=open('age.new','r').read().split('\n')
age_hist=dict()
for line in data:
    try: 
        line=int(round(float(line)))
        if line < 1: 
            continue 
        if line > 100: 
            continue 
        if line not in age_hist:
            age_hist[line]=1
        else:
            age_hist[line]+=1
    except: 
        continue 
print str(age_hist)
outf=open('age.new.histogram','w')
outf.write('Age\tSubjects\n')
for key in age_hist:
    outf.write(str(key)+'\t'+str(age_hist[key])+'\n')
    
