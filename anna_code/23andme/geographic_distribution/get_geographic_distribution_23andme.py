subjects=open("zip.23andme.subjects",'r').read().strip().split('\n') 

#load and format possible us & uk zip codes 
us_zip=dict() 
us_geo_data=open("geo-data.csv",'r').read().strip().split('\n') 
states=set([]) 
for line in us_geo_data: 
    tokens=line.split(',') 
    state=tokens[1].lower() 
    states.add(state)
    zipcode=tokens[3] 
    zip3=zipcode[0:3]
    us_zip[zip3]=state
print('generated US zip dict') 

uk_zip=dict() 
uk_geo_data=open("uk.postcodes",'r').read().strip().split('\n') 
for line in uk_geo_data: 
    tokens=line.split(',') 
    zipcode=tokens[0].split()[0].lower()  
    county=tokens[1].strip("\"") 
    uk_zip[zipcode]=county.lower() 
print("generated UK zip dict") 

outf_us=open('us.tally','w') 
outf_us.write('State\tUsers\n') 
outf_uk=open('uk.tally','w') 
outf_uk.write('Count\tUsers\n') 
us_tally=dict() 
for state in states :
    us_tally[state]=0
uk_tally=dict() 
import pdb 
#pdb.set_trace() 
for line in subjects: 
    tokens=line.split('\t') 
    subject=tokens[0] 
    zipcode=tokens[1] 
    while len(zipcode)<3: 
        zipcode='0'+zipcode 
    if len(zipcode)>3: 
        zipcode=zipcode[0:3]
    zipcode=zipcode.lower() 
    if zipcode in us_zip: 
        cur_state=us_zip[zipcode]
        if cur_state not in us_tally: 
            us_tally[cur_state]=1
        else: 
            us_tally[cur_state]+=1 
    elif zipcode in uk_zip: 
        cur_county=uk_zip[zipcode] 
        if cur_county not in uk_tally: 
            uk_tally[cur_county]=1 
        else: 
            uk_tally[cur_county]+=1
    else: 
        print(line) 
#pdb.set_trace() 
for entry in us_tally: 
    outf_us.write(entry+'\t'+str(us_tally[entry])+'\n')
for entry in uk_tally: 
    outf_uk.write(entry+'\t'+str(uk_tally[entry])+'\n')

    


