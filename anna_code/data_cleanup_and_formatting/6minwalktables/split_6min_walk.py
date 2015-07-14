total_entries=12380 
total_nodes=20 
per_file=total_entries/total_nodes 
per_file+=1 

data=open('cardiovascular-6MinuteWalkTest-v2.tsv.sorted','r').read().replace('\r\n','\n').split('\n') 
if '' in data: 
    data.remove('') 
header=data[0]
print str(header)  
data=data[1::] 

for i in range(total_nodes): 
    start_index=i*per_file
    end_index=(i+1)*per_file 
    if end_index > total_entries: 
        end_index= total_entries 
    chunk=data[start_index:end_index] 
    outf=open('f'+str(i),'w') 
    outf.write(header+'\n'+'\n'.join(chunk)) 
