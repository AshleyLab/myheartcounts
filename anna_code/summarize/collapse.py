data=open('merged.tsv','r').read().strip().split('\n') 
data_dict=dict() 
header=data[0].split('\t') 
header=[i.replace('_y','') for i in header] 
header=[i.replace('_x','') for i in header] 
for row in data[1::]: 
    tokens=row.split('\t') 
    healthCode=tokens[0] 
    if healthCode not in data_dict: 
        data_dict[healthCode]=dict() 
    for i in range(1,len(tokens)): 
        cur_field=header[i] 
        cur_val=tokens[i] 
        data_dict[healthCode][cur_field]=cur_val 
outf=open("merged.collapsed.tsv",'w') 
header=list(set(header[1::]))
outf.write('healthCode'+'\t'+'\t'.join(header)+'\n') 
for subject in data_dict: 
    outf.write(subject) 
    for field in header: 
        if field in data_dict[subject]: 
            outf.write('\t'+data_dict[subject][field])
        else: 
            outf.write('\tNA') 
    outf.write('\n') 
    

        
