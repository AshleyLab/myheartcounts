nonts=open('NonTimeSeries_10022015.txt','r').read().split('\n')
while '' in nonts:
    nonts.remove('')
fractions=open('fractions.updated.txt','r').read().split('\n')
while '' in fractions:
    fractions.remove('')
clusters=open('clusters.txt','r').read().split('\n')
while '' in clusters:
    clusters.remove('')

#get the headers
header_nont=nonts[0].split('\t')[1::]
nont_fields=len(header_nont)-1
header_fractions=fractions[0].split('\t')[1::]
fraction_fields=len(header_fractions)-1
header_clust=clusters[0].split('\t')[1::]
clust_fields=len(header_clust)-1

    
value_dict=dict()
for line in nonts:
    tokens=line.split('\t')
    subject=tokens[0]
    value_dict[subject]=dict() 
    value_dict[subject]['nont']=tokens[1::]
for line in fractions: 
    tokens=line.split('\t')
    subject=tokens[0]
    if subject in value_dict:
        value_dict[subject]['fractions']=tokens[1::]
for line in clusters:
    tokens=line.split('\t')
    subject=tokens[0]
    if subject in value_dict:
        value_dict[subject]['cluster']=tokens[1::]
        
outf=open('DataFreezeDataFrame_10022015.txt','w')
outf.write('Subject')
outf.write('\t'+'\t'.join(header_nont)+'\t'+'\t'.join(header_fractions)+'\t'+'\t'.join(header_clust)+'\n')
for subject in value_dict:
    outf.write(subject)
    outf.write('\t'+'\t'.join(value_dict[subject]['nont']))
    if 'fractions' in value_dict[subject]:
        outf.write('\t'+'\t'.join(value_dict[subject]['fractions']))
    else:
        outf.write(fraction_fields*'\tNA')
    if 'cluster' in value_dict[subject]:
        outf.write('\t'+'\t'.join(value_dict[subject]['cluster']))
    else:
        outf.write(clust_fields*'\tNA')
    outf.write('\n')
   
