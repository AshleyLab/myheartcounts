consented=open("ab_test_subjects",'r').read().strip().split('\n') 
consented_dict=dict() 
for line in consented: 
    consented_dict[line]=1 
data=open("../AWS_vs_ABTable_HealthKit_Steps_Distance.tsv",'r').read().strip().split('\n') 
outf=open("../AWS_vs_ABTable_HealthKit_Steps_Distance.consent.tsv",'w')
outf.write(data[0]+'\n')
print("filtering")
for line in data[1::]: 
    tokens=line.split('\t') 
    subject=tokens[0] 
    if subject in consented_dict: 
        outf.write(line+'\n') 
