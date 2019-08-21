
hk_subjects=open('hk.subjects','r').read().strip().split('\n')
mt_subjects=open('mt.subjects','r').read().strip().split('\n')
hk_dict=dict() 
for line in hk_subjects: 
    hk_dict[line]=1 
mt_dict=dict() 
for line in mt_subjects: 
    mt_dict[line]=1
id_core=open('id_core.csv','r').read().strip().split('\n')
id_hk=open('id_HK_only.csv','r').read().strip().split('\n')

id_core_dict=dict() 
id_hk_dict=dict() 
for line in id_core: 
    id_core_dict[line]=1 
for line in id_hk: 
    id_hk_dict[line]=1 

id_total=open('id_total.csv','r').read().strip().split('\n')
outf=open('id_annotation.tsv','w') 
outf.write('Subject\tHK\tMT\tIDHK\tIDCORE\n')
for line in id_total: 
    out_list=[line] 
    if line in hk_dict: 
        out_list.append(1)
    else: 
        out_list.append(0) 
    if line in mt_dict: 
        out_list.append(1) 
    else: 
        out_list.append(0) 
    if line in id_hk_dict: 
        out_list.append(1) 
    else: 
        out_list.append(0) 
    if line in id_core_dict: 
        out_list.append(1) 
    else: 
        out_list.append(0) 
    outf.write('\t'.join([str(i) for i in out_list])+'\n')

