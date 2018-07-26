#How many phones do we have of each type?" 

data=open("/home/annashch/myheart/myheart/data/tables/cardiovascular-appVersion.tsv","r").read().split('\n') 
data.remove('') 
print "read in data" 
phones=set() 
subject_to_phone=dict() 
for line in data[1::]: 
    line=line.split('\t') 
    #print str(line) 
    subject=line[2] 
    phone=line[7]
    phones.add(phone)
    if subject not in subject_to_phone: 
        subject_to_phone[subject]=[phone] 
print "tallied subject to phone" 
phone_to_count=dict() 
for subject in subject_to_phone: 
    phones_cur=subject_to_phone[subject] 
    for phone in phones_cur: 
        if phone not in phone_to_count: 
            phone_to_count[phone]=1 
        else: 
            phone_to_count[phone]+=1 
print "writing output" 
outf=open('phone_tally.txt','w') 
for phone in phone_to_count: 
    outf.write(phone+'\t'+str(phone_to_count[phone])+'\n') 
    
