zips=open('zip.txt','r').read().strip().split('\n') 
outf=open('filtered_zip.txt','w') 
for line in zips: 
    tokens=line.split('\t') 
    curzip=tokens[1] 
    if len(curzip)==0: 
        continue
    elif len(curzip)==1: 
        curzip="00"+curzip 
    elif len(curzip)==2:
        curzip="0"+curzip 
    elif len(curzip)>3: 
        curzip=curzip[0:3] 
    outf.write(tokens[0]+'\t'+curzip+'\n')
outf.close() 
