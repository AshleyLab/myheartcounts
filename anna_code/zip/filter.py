rct_subjects=open("rct.subjects",'r').read().strip().split('\n') 
rct_dict=dict() 
for line in rct_subjects: 
    rct_dict[line]=1
zips=open("all.zipcodes",'r').read().strip().split('\n') 
outf=open('rct.zipcodes','w') 
for line in zips[1::]: 
    tokens=line.split('\t') 
    subject=tokens[0] 
    if subject in rct_dict: 
        outf.write(line+'\n') 

