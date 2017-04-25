source=open('/srv/gsfs0/projects/ashley/common/device_validation/Batch_2_full_dataset.tsv','r').read().split('\n')  
while '' in source: 
    source.remove('') 
gs_e=open('/srv/gsfs0/projects/ashley/common/device_validation/e2','r').read().split('\n')
while '' in gs_e: 
    gs_e.remove('') 
gs_e_dict=dict() 
for line in gs_e[1::]: 
    tokens=line.split('\t') 
    date=tokens[0] 
    energy=tokens[2] 
    gs_e_dict[date]=energy 
pulseon_e=open('/srv/gsfs0/projects/ashley/common/device_validation/pulseon_energy.tsv','r').read().split('\n') 
print str(pulseon_e) 
while '' in pulseon_e: 
    pulseon_e.remove('') 
pulseon_dict=dict() 
for line in pulseon_e[1::]: 
    tokens=line.split('\t') 
    date=tokens[0] 
    energy=tokens[1] 
    pulseon_dict[date]=energy 
outf=open('/srv/gsfs0/projects/ashley/common/device_validation/Batch_2_full_dataset.tsv.WITHENERGY','w')
outf.write(source[0]+'\tPulseOnEnergy\tGS_Energy\n')
for line in source[1::]: 
    tokens=line.split('\t') 
    date=tokens[0] 
    p_e='NA' 
    gs_e='NA' 
    if date in pulseon_dict: 
        p_e=pulseon_dict[date] 
    if date in gs_e_dict: 
        gs_e=gs_e_dict[date] 
    outf.write(line+'\t'+p_e+'\t'+gs_e+'\n')

