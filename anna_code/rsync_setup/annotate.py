#phenotypes=open("all_gwas_phenotype.txt",'r').read().strip().split('\n')
phenotypes=open("gwas_outcomes_motion_and_healthkit_observed.txt",'r').read().strip().split('\n') 
metadata=open("cardiovascular-23andmeTask-v1.tsv",'r').read().strip().split('\n')
outf=open('gwas_outcomes_motion_and_healthkit_observed.txt.23MeSubset.txt','w')
outf.write('23MeId\t'+phenotypes[0]+'\n')
metadata_dict=dict()
for line in metadata[1::]:
    tokens=line.split('\t')
    subject=tokens[5]
    idval='-'.join([tokens[-2],tokens[-1]])
    metadata_dict[subject]=idval
for line in phenotypes[1::]:
    tokens=line.split('\t')
    subject=tokens[0]
    if subject in metadata_dict: 
        cur_id_val=metadata_dict[subject]
        outf.write(cur_id_val+'\t'+line+'\n')
    
