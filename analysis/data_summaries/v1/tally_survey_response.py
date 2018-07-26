data=open('NonTimeSeries.txt','r').read().split('\n') 
while '' in data: 
    data.remove('') 
header=data[0].split('\t') 
overall_survey_participants=set()  
categories=set(header) 
survey_dict=dict() 
for entry in header: 
    survey_dict[entry]=set([]) 

for line in data[2::]: 
    tokens=line.split('\t') 
    subject=tokens[0] 
    for i in range(1,len(tokens)):
        if tokens[i]!="NA": 
            filetype=header[i] 
            survey_dict[filetype].add(subject) 
            overall_survey_participants.add(subject) 

print "overall::"+str(len(overall_survey_participants)) 
for entry in survey_dict: 
    print str(entry)+":"+str(len(survey_dict[entry]))

        

