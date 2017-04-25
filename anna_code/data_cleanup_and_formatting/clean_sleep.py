data=open('/home/anna/r_scripts/Non_timeseries_filtered.tsv','r').read().split('\n') 
outf=open('/home/anna/r_scripts/Non_timeseries_filtered2.tsv','w')
outf.write(data[0]) 
for line in data:
    outf.write('\n')
    line=line.split('\t')
    if line[22] not in ['1','2','3','4','5','6','7','8','9','10']:
        line[22]="NA"
    outf.write('\t'.join(line))
    
