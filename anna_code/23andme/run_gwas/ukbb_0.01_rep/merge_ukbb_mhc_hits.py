import pdb 
ukbb_hits=open("all.filtered.0.01.txt",'r').read().strip().split('\n') 
mhc_hits=open("allsnps.mhc.extended.nointerventions.n50ormore.csv",'r').read().strip().split('\n') 
clumps=open("clumped.txt",'r').read().strip().split('\n') 
ukbb_dict=dict() 
mhc_dict=dict() 
clump_map=dict() 
meta_details=dict() 
for line in ukbb_hits[1::]: 
    tokens=line.split(',') 
    snp=tokens[0] 
    if snp not in meta_details: 
        meta_details[snp]=tokens[1:5]
    if snp in ukbb_dict: 
        ukbb_dict[snp].append(','.join(tokens[5::]))
    else: 
        ukbb_dict[snp]=[','.join(tokens[5::])]
print("made ukbb map") 

for line in mhc_hits[1::]: 
    tokens=line.split(',') 
    snp=tokens[0] 
    if snp in mhc_dict: 
        mhc_dict[snp].append(','.join(tokens[5::])) 
    else: 
        mhc_dict[snp]=[','.join(tokens[5::])]
print("made mhc map") 

for line in clumps: 
    tokens=line.split(' ') 
    feature=tokens[0] 
    ukbb_hit=tokens[3] 
    ld_snps=tokens[-1].split(',') 
    for ld_snp in ld_snps: 
        if ld_snp in mhc_dict: 
            #we have a match! 
            if ld_snp not in clump_map: 
                clump_map[ld_snp]=[','.join([feature,ukbb_hit])]
            else: 
                clump_map[ld_snp].append(','.join([feature,ukbb_hit]))
print("made clumped map") 
pdb.set_trace() 

outf=open("merged.mhc.hits.ukbb.validated.txt",'w')
for snp in mhc_dict: 
    if (snp not in ukbb_dict) and (snp not in clump_map): 
        continue 
    else: 
        outf.write(snp+'\t'+'\t'.join(meta_details[snp])+"\t"+';'.join(mhc_dict[snp]))
        if snp not in ukbb_dict:         
            outf.write('\tNone') 
        else: 
            outf.write('\t'+';'.join(ukbb_dict[snp]))
        if snp in clump_map: 
            outf.write('\t'+';'.join(clump_map[snp])+'\n')
        else: 
            outf.write('\tNone\n')

