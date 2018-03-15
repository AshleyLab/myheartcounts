tallies=open('zipcode.hist','r').read().split('\n') 
options=open('zipcode_prefixes.csv','r').read().split('\n') 
options.remove('') 
tallies.remove('') 
#make dictionary of zipcode prefixes 
prefix_dict=dict() 
for line in options: 
    tokens=line.split(' ') 
    zipcode=tokens[-1] 
    state=tokens[-2] 
    city=' '.join(tokens[0:-2])
    prefix_dict[zipcode]=[state,city] 
outf=open('geographic_locations.txt','w') 
outf.write('City\tState\tZipCode\tSubject\n') 
for line in tallies: 
    tokens=line.split('\t') 
    zipcode=tokens[0][-3::] 
    if zipcode not in prefix_dict: 
        outf.write('NA\tNA\t'+line+'\n') 
    else: 
        place=prefix_dict[zipcode] 
        state=place[0] 
        city=place[1] 
        outf.write(city+'\t'+state+'\t'+line+'\n') 

