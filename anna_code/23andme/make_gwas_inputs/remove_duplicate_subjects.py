#removes duplicate subject entries from ped and phenotype file 
#ped_file=open("23andme.ped",'r').read().strip().split('\n') 
#outf_ped=open("23andme.ped.filtered",'w') 
phenotypes=open("../23andme.phenotype",'r').read().strip().split('\n') 
outf_phenotype=open("23andme.phenotype.filtered",'w')
#subjects=dict() 
#for line in ped_file: 
#    subject=line.split(' ')[0] 
#    if subject not in subjects: 
#        subjects[subject]=1 
#        outf_ped.write(line+"\n")
subjects=dict() 
for line in phenotypes: 
    subject=line.split('\t')[0] 
    if subject not in subjects: 
        outf_phenotype.write(line+'\n')
        subjects[subject]=1 

        
