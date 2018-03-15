data=open('fractions_v2.txt','r').read().split('\n') 
'''
outf=open('fails_2.txt','w') 

while '' in data: 
    data.remove('')
for line in data[1::]: 
    tokens=line.split('\t') 
    numerical=[float(i) for i in tokens[1::]] 
    if min(numerical) < 0: 
        outf.write(line+'\n') 
    elif max(numerical)>1: 
        outf.write(line+'\n') 
'''
#remove any negative values from the data 
outf=open('fractions_v2_filtered.txt','w') 
outf.write(data[0]+'\n') 
while '' in data: 
    data.remove('')
for line in data[1::]: 
    tokens=line.split('\t') 
    numerical=[float(i) for i in tokens[1::]] 
    if min(numerical) < 0: 
        continue 
    if max(numerical)>1: 
        continue 
    outf.write(line+'\n')

