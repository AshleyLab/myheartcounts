data=open('results.tsv','r').read().replace('\r\n','\n').split('\n')
if '' in data:
    data.remove('')
outf=open('results.clean.tsv','w')
email_dict=dict()
for line in data[1::]:
    line=line.split('"')
    name=line[3].split(' ')[0]
    if len(line)<6:
        print str(line)
        continue 
    email=line[5]
    email_dict[email]=name
outf.write('name\temail\n')
for email in email_dict:
    outf.write(str(email_dict[email])+'\t'+email+'\n')
    
