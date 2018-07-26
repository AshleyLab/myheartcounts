#collapses duplicated fields in an input table file -- duplicates are assumed to have the same name, except one field has ".json" and one does not. 
import sys 

def main(): 
    data=open(sys.argv[1],'r').read().split('\n') 
    if '' in data: 
        data.remove('') 

    #identify the duplicated columns 
    header='\t'+data[0]
    header=header.split('\t') 
    dups=dict() 
    for i in range(len(header)): 
        for j in range(i+1,len(header)): 
            field1=header[i].replace('.json','') 
            field2=header[j].replace('.json','') 
            if field1==field2: 
                dups[i]=j 
                dups[j]=i 
    print str(dups) 
    
    #collapse the table 
    outf=open(sys.argv[1]+".NODUPLICATES",'w') 
    for line in data: 
        recorded=dict() 
        if line==data[0]: 
            line='\t'+line 
            first=True
        else: 
            first=False 
        line=line.split('\t') 
        out_line=[] 
        for i in range(len(line)): 
            if i in recorded: 
                continue 
            elif i in dups: 
                option1=line[i] 
                option2=line[dups[i]]
                if option1=="NA": 
                    out_line.append(option2) 
                else: 
                    out_line.append(option1) 
                recorded[i]=1 
                recorded[dups[i]]=1 
            else: 
                out_line.append(line[i]) 
                recorded[i]=1 
        if first==True: 
            out_line=out_line[1::] 
        outf.write('\t'.join(out_line)+'\n')
        
                
if __name__=="__main__": 
    main() 
