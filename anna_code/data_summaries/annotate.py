phenotypes=open("all_gwas_phenotype.txt",'r').read().strip().split('\n')
metadata=open("cardiovascular-23andmeTask-v1.tsv",'r').read().strip().split('\n')
outf=open('all_gwas_phenotype_with_23MeID.txt','w')
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
    cur_id_val=metadata_dict[subject]
    outf.write(cur_id_val+'\t'+line+'\n')
    
