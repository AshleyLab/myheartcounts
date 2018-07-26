data=open('results.clean.tsv','r').read().split('\n') 
ssa=open('ssa_national_summary.txt','r').read().split('\n') 
ssa.remove('') 
ssa_dict=dict() 
for line in ssa[1::]: 
    line=line.split('\t') 
    ssa_dict[line[0]]=line[1::] 

outf=open('results.clean.mapped.tsv','w') 
outf.write('email\tfirst_name\tprobabilistic_sex\tmales\tfemales\tmedian_age\t25th_percentile\t75th_percentile\n')
for line in data[1::]: 
    line=line.split('\t') 
    print str(line) 
    name=line[0] 
    email=line[1] 
    if name in ssa_dict: 
        entry=ssa_dict[name]
        print str(entry) 
        males=int(entry[0]) 
        females=int(entry[1]) 
        if males > females: 
            called="male"
        else: 
            called="female" 
        total=entry[2]
        median=entry[3] 
        percent_25=entry[4] 
        percent_75=entry[5] 
        outf.write(email+'\t'+name+'\t'+called+"\t"+str(males)+'\t'+str(females)+'\t'+total+'\t'+median+'\t'+percent_25+'\t'+percent_75+'\n') 
    else: 
        outf.write(email+'\t'+name+'\t'+'NA'+'\t'+'NA'+'\t'+'NA'+'\t'+'NA'+'\t'+'NA'+'\t'+'NA'+'\t'+'NA'+'\n')
