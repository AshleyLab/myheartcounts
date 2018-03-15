data=open('/home/anna/r_scripts/Non_timeseries_data_07012014.tsv','r').read().split('\n')
outf=open('/home/anna/r_scripts/Non_timeseries_filtered.tsv','w')
#data=open('/home/anna/r_scripts/merged_acceleration_meta.txt','r').read().split('\n')
#outf=open('/home/anna/r_scripts/merged_acceleration_meta_filtered.tsv','w')


for line in data:
    line=line.split('\t')
    outf.write(line[0]) 
    for entry in line[1::]:
        val=entry.split(',')[0]
        if val.startswith('\"'):
            val=val+'\"'
        outf.write('\t'+val)
    outf.write('\n')
