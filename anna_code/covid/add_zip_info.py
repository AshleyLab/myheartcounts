zip_dict=dict()  
zips=open('filtered_zip.txt','r') 
for line in zips: 
    tokens=line.split('\t') 
    subject=tokens[0] 
    curzip=tokens[1] 
    zip_dict[subject]=curzip

hk=open('parsed_HealthKitData.txt','r').read().strip().split('\n') 
outf_hk=open('zip_parsed_HealthKitData.txt','w')
header=hk[0]+'\tzip'
outf_hk.write(header+'\n')
for line in hk[1::]: 
    tokens=line.split('\t') 
    subject=tokens[0] 
    curzip="NA"
    if subject in zip_dict: 
        curzip=zip_dict[subject]
    tokens.append(curzip) 
    outf_hk.write('\t'.join(tokens)+'\n')
outf_hk.close() 

ma=open('parsed_motionActivity.txt','r').read().strip().split('\n') 
outf_ma=open('zip_parsed_motionActivity.txt','w')
header=ma[0]+'\tzip'
outf_ma.write(header+'\n') 
for line in ma[1::]: 
    tokens=line.split('\t') 
    subject=tokens[0] 
    curzip="NA" 
    if subject in zip_dict: 
        curzip=zip_dict[subject] 
    tokens.append(curzip) 
    outf_ma.write('\t'.join(tokens)+'\n') 
outf_ma.close() 

