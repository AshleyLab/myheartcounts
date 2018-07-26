from Parameters import * 
import sys 
imputed="/srv/gsfs0/projects/ashley/common/myheart/data/tables/derived_age_sex_prediction.tsv"
derived=open(imputed,'r').read().split('\n') 
while '' in derived: 
    derived.remove('') 
nts=open('NonTimeSeries.txt','r').read().split('\n') 
while '' in nts: 
    nts.remove('') 

derived_dict=dict() 
for line in derived[1::]: 
    line=line.split('\t') 
    subject=line[1] 
    males=line[2] 
    females=line[3]
    total=line[4]
    median_age=line[5] 
    if males=="NA": 
        continue 
    males=float(males) 
    females=float(females) 
    total=float(total) 
    median_age=median_age 
    if males > females: 
        sex="Male"
        confidence=str(round(males/total,2)) 
    else: 
        sex="Female" 
        confidence=str(round(females/total,2)) 
    derived_dict[subject]=[sex,confidence,median_age] 

#fill in missing people! 
imputed_age=0 
imputed_sex=0 

outf=open("NonTimeSeries_Imputed.txt",'w')
outf.write(nts[0]+'\n'+nts[1]) 
for line in nts[2::]: 
    tokens=line.split('\t') 
    subject=tokens[0] 
    sex=tokens[3] 
    age=tokens[1] 
    sex_confidence=tokens[4]
    age_confidence=tokens[2]
    if age=="NA":
        if subject in derived_dict: 
            age=derived_dict[subject][2] 
            imputed_age+=1 
    if sex=="NA": 
        if subject in derived_dict: 
            sex=derived_dict[subject][0] 
            sex_confidence=derived_dict[subject][1]
            imputed_sex+=1 
    outf.write(subject+'\t'+age+'\t'+age_confidence+'\t'+sex+'\t'+sex_confidence+'\t'+'\t'.join(tokens[5::])+'\n')
print "imputed_age:"+str(imputed_age) 
print "imputed_Sex:"+str(imputed_sex) 
