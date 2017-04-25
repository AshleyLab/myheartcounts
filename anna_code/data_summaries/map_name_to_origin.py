newnames=open('newnames','r').read().split('\n') 
if '' in newnames: 
    newnames.remove('') 
origins=open('origins.uniq','r').read().split('\n') 
if '' in origins: 
    origins.remove('') 
origin_dict=dict() 
for line in origins: 
    line=line.split('\t') 
    subject=line[0] 
    timestamp=line[1]
    if timestamp.endswith("+08:0"): 
        origin_dict[subject]="HongKong" 
    elif timestamp.endswith("+01:0"): 
        origin_dict[subject]="UK" 
    else: 
        origin_dict[subject]="Other" 

zipcodes=open('zipcodes','r').read().split('\n') 
numbers=["0","1","2","3","4","5","6","7","8","9"]
if '' in zipcodes: 
    zipcodes.remove('') 
zipcode_dict=dict() 
for line in zipcodes: 
    line=line.split('\t') 
    if len(line)<2: 
        continue 
    subject=line[0] 
    zipcode=line[1] 
    if zipcode[0] not in numbers: 
        zipcode_dict[subject]="UK" 
    elif (zipcode[0] in numbers) and (zipcode[1] in numbers): 
        zipcode_dict[subject]="Other" 
    elif zipcode=="Hong Kong": 
        zipcode_dict[subject]="HongKong" 

outf=open("origin.map",'w') 
for subject in newnames: 
    if subject in origin_dict: 
        outf.write(subject+'\t'+origin_dict[subject]+'\n') 
    elif subject in zipcode_dict: 
        outf.write(subject+'\t'+zipcode_dict[subject]+'\n') 
    else: 
        outf.write(subject+'\t'+'Unknown'+'\n') 

