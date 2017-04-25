import re 
#SCRIPT TO MAP ACTOR FIRST NAME TO TRUE AGE AND SEX.
outf=open('imdb_truth_data.txt','w')
outf.write('Name\tFirstName\tSex\tAge\n') 
#BUILD TRUTH GENDER INFO FROM ACTOR (MALE) AND ACTRESS (FEMALE) LISTS 
actors=open('actors.uniq','r').read().split('\n')
while '' in actors:
    actors.remove('')
actor_dict=dict()
for actor in actors:
    actor_dict[actor]=1
actresses=open('actresses.uniq','r').read().split('\n')
while '' in actresses:
    actresses.remove('')
actress_dict=dict()
for actress in actresses:
    actress_dict[actress]=1
print "imported sex information"

#GET BIRTHDATE FROM BIOGRAPHY FILE 
bio=open('biographies.list','r').read().split('-------------------------------------------------------------------------------')
num_entries=str(len(bio))
c=0 
for entry in bio:
#    c+=1
#    if c%100==0:
#        print str(c)+"/"+num_entries
    nm_entry=None 
    name=None
    age=None
    dead=False 
    entry=entry.split('\n') 
    for line in entry:
        #print "|||||||"+str(line)+"|||||||" 
        if line.startswith('DD:'):
            #THIS PERSON DIED, WE ONLY WANT LIVING PEOPLE
            dead=True 
        elif line.startswith('NM:'):
            nm_entry=line.split(':')[1].lstrip(' ') 
        elif line.startswith('RN:'):
            name=line.split(':')[1].lstrip(' ')
        elif line.startswith('DB:'):
            dob=line.split(':')[1].lstrip(' ')
            year_info=re.search(r'\d{4}',dob)
            if year_info!=None:
                age=2015-int(year_info.group())
    if name and age and (not dead) and (age < 95):
        #CREATE AN ENTRY
        name_parts=name.split(' ')
        if name_parts[0].endswith(','):
            first_name=name_parts[1]
        else:
            first_name=name_parts[0]
        first_name=first_name.split(' ')[0] 
        sex="M"
        if nm_entry in actor_dict:
            sex="M"
        elif  nm_entry in actress_dict:
            sex="F"
        else:
            print "name missing from gender_dict:"+str(name)
            continue
        outf.write(name+'\t'+first_name+'\t'+sex+'\t'+str(age)+'\n')

