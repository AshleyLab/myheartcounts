data=open('Activity_states_weekday_weekend_total_10022015.tsv').read().split('\n') 
while '' in data: 
    data.remove('') 
watches=open('watch_subjects_uniq.txt','r').read().split('\n') 
while '' in watches: 
    watches.remove('') 
watch_dict=dict() 
for line in watches: 
    watch_dict[line]=1 
outf=open('Activity_states_with_watches.tsv','w') 
outf.write(data[0]+'\tWatch\n') 
for line in data[1::]: 
    tokens=line.split('\t') 
    subject=tokens[0] 
    watchval='0' 
    if subject in watch_dict: 
        watchval='1' 
    outf.write(line+'\t'+watchval+'\n') 

