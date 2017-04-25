source=open('NonTimeSeries.txt','r').read().split('\n') 
if '' in source: 
   source.remove('') 
newpeople=open('tmp_newsubject/newnames','r').read().split('\n')
newpeople.remove('') 
newpeople_dict=dict() 
for person in newpeople: 
    newpeople_dict[person]=1 
outf=open('NonTimeseries_oldpeople.txt','w') 
outf.write(source[0]+'\n'+source[1]+'\n') 
for line in source[2::]: 
    subject=line.split('\t')[0] 
    if subject not in newpeople_dict: 
       outf.write(line+'\n')
