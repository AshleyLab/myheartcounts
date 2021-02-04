subjects=open('subjects.txt','r').read().strip().split('\n') 
covar=open('covariates.txt','r').read().strip().split('\n') 
covar_dict=dict() 
for line in covar: 
    tokens=line.split('\t') 
    covar_dict[tokens[0]]=line 
outf=open('blah.txt','w') 
for subject in subjects: 
    try:
        outf.write(covar_dict[subject]+'\n')
    except: 
        print(subject)
