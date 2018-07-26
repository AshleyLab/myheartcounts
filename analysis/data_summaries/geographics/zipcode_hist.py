data=open('zipcodes','r').read().split('\n') 
data.remove('')
data_dict=dict() 
for line in data: 
    tokens=line.split('\t') 
    print str(tokens) 
    zc = tokens[1] 
    if zc not in data_dict: 
        data_dict[zc]=1 
    else: 
        data_dict[zc]+=1 
outf=open('zipcode.hist','w') 
for entry in data_dict: 
    outf.write(entry+'\t'+str(data_dict[entry])+'\n') 
