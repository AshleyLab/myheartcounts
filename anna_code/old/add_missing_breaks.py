missinglines=open('missingbreaks.txt','r').read().split('\n')
if '' in missinglines: 
    missinglines.remove('') 
for fname in missinglines: 
    #print str(fname) 
    data=open(fname,'r').read().split('\n') 
    if '' in data: 
        data.remove('') 
    outf=open(fname.split('/')[-1],'w') 
    for line in data: 
        if len(line.split('\t'))==6: 
            outf.write(line+'\n') 
        elif len(line.split('\t'))==5: 
            vals=line.split('\t') 
            if vals[-1]=="0":
                outf.write(line+'\t0\n') 
            elif vals[-1]=="1": 
                outf.write(line+'\t0.5\n') 
            elif vals[-1]=="2": 
                outf.write(line+'\t1.0\n') 
            else: 
                print str(line) 
        else: 
            print str(fname) 
            print str(line) 


        #bad_index=line.find("2015",10,len(line))
        #if bad_index==-1: 
        #    outf.write(line+'\n') 
        #else: 
        #    line=line[0:bad_index]+'\n'+line[bad_index::] 
        #    outf.write(line+'\n') 
            
