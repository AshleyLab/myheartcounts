import pandas as pd 
import sys 
import datetime
from dateutil.parser import parse
from scipy import mean 
import pdb 

survey_path=sys.argv[1] 
outf=sys.argv[2] 
data= pd.read_csv(survey_path,
                  sep='\t',
                  header=0,
                  quotechar='"',
                  index_col=0,
                  error_bad_lines=False,
                  engine='c')
data['createdOn']=[parse(i) for i in data['createdOn']]
data=data.sort_values(by='createdOn',ascending=True)
data=data[data['createdOn']>datetime.datetime(2015,1,1)]

data=data[data['createdOn']<datetime.datetime(2020,4,14)]

print("ready") 
day_to_upload={} 
day_to_subject={} 
day_to_new_subject={} 
seen_subjects={} 
dates=set([])
for index,row in data.iterrows(): 
    if index%100==0: 
        print(index) 
    cur_subject=row['healthCode'] 
    cur_date=row['createdOn'].date()  
    dates.add(cur_date)
    if cur_date not in day_to_upload: 
        day_to_upload[cur_date]=1 
        day_to_subject[cur_date]={} 
        day_to_new_subject[cur_date]=0
    else: 
        day_to_upload[cur_date]+=1 
        if cur_subject not in day_to_subject[cur_date]: 
            day_to_subject[cur_date][cur_subject]=1 
        else: 
            day_to_subject[cur_date][cur_subject]+=1 
    #is this a new subject? 
    if cur_subject not in seen_subjects:
        day_to_new_subject[cur_date]+=1 
        seen_subjects[cur_subject]=1 
#aggregate 
#pdb.set_trace()
dates=list(dates)
print("writing outputs") 
outf=open(outf,'w') 
outf.write('Date\tUploads\tSubjects\tNewSubjects\tMeanUploadsPerSubjectPerDay\n')
for date in dates: 
    outf.write(str(date)+'\t'+str(day_to_upload[date])+'\t'+str(len(day_to_subject[date]))+'\t'+str(day_to_new_subject[date])+'\t'+str(mean(list(day_to_subject[date].values())))+'\n')
outf.close() 

