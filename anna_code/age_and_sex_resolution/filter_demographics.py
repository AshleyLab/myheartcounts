from dateutil.parser import parse
from collections import Counter 

#gets a majority vote for age and sex information 
def vote(age,sex):
    #print "voting:"+str(age)+"|"+str(sex) 
    value_counts=Counter(age)
    histogram=value_counts.most_common()
    if 'Other'in sex:
        sex.remove('Other')
    while '' in sex:
        sex.remove('') 
    sex_counts=Counter(sex)
    #print str(sex_counts) 
    sex_to_assign=sex_counts.most_common(1)
    sex_to_assign=sex_to_assign[0][0]  
    #print str(sex_to_assign) 

    if (len(histogram)==1) or (histogram[0][1] > histogram[1][1]):
        #we have a unique mode!
        mode_age_result=histogram[0][0]
        mode_count=age.count(mode_age_result)
        confidence=float(mode_count)/len(age)
        column=age.index(mode_age_result)
        return sex_to_assign,mode_age_result,column,confidence
    else: #there is no majority consensus on age and sex 
        return None,None,None,None

data=open('data_summary.tsv','r').read().replace('\r\n','\n').replace('NA','-1').split('\n')
outf=open('filtered_summary.txt','w')
header='\t'.join(data[0].split('\t')[5::])
outf.write('Subject\tAge\tSex\tConfidence\t'+header+'\n')

#determine which columns are from the heartage file and which are from the Demographics file
heartage_columns=dict()
dem_columns=dict()
fields=data[0].split('\t') 
for i in range(len(fields)):
    entry=fields[i] 
    if entry.startswith('NonIdentifiable'):
        dem_columns[i]=1
    else:
        heartage_columns[i]=1



while '' in data:
    data.remove('')
subject_to_sex=dict()
subject_to_age=dict()
subject_to_dem_column=dict()
subject_to_heartage_column=dict()
subject_to_confidence=dict()


for line in data[1::]:
    line=line.split('\t')
    subject=line[0]
    dem_sex=line[2].split(',')
    while '' in dem_sex:
        dem_sex.remove('') 
    dem_sex_string=line[2] 
    dem_age=line[4].split(',')
    while '' in dem_age:
        dem_age.remove('') 
    dem_age_string=line[4]
    heartage_sex=line[1].split(',')
    while '' in heartage_sex:
        heartage_sex.remove('') 
    heartage_sex_string=line[1] 
    heartage_age=line[3].split(',')
    while '' in heartage_age:
        heartage_age.remove('') 
    heartage_age_string=line[3] 

    sex_unique=True
    age_unique=True
    heartage_sex_unique=True
    heartage_age_unique=True

    stored=False

    #1) Filter Dem file information
    if len(dem_sex)>1:
        unique=set(dem_sex)
        if len(unique)>1:
            sex_unique=False

    if len(dem_age)>1:
        unique=set(dem_age)
        if len(unique)>1:
            age_unique=False

    if sex_unique and age_unique and (dem_sex_string!="") and (dem_age_string!=""): #unique information about age and sex from the demographics file, store this!
        #print str(dem_sex)
        try:
            subject_to_sex[subject]=dem_sex[0]
        except:
            True
        subject_to_age[subject]=dem_age[0]
        subject_to_dem_column[subject]=0
        subject_to_confidence[subject]=1 
        stored=True
    elif (dem_sex_string!="") and (dem_age_string!=""): #Try to take a majority vote!
        sex_mode,age_mode,column,confidence=vote(dem_age,dem_sex)
        if sex_mode!=None:
            subject_to_sex[subject]=sex_mode
            subject_to_age[subject]=age_mode
            subject_to_dem_column[subject]=column
            subject_to_confidence[subject]=confidence
                
    #2) Filter HeartAge file information
    #convert the age to a calendar birthday
    if line[3]!="":
        heartage_age=[2015-parse(i).year for i in heartage_age] #allow age +/- 1 for comparison with Dem. file data, since they may or may not have had a birthday this year 
    #check whether the heartage entry is unique 
    if len(heartage_sex)>1:
        unique=set(heartage_sex)
        if len(unique)>1:
            heartage_sex_unique=False

    if len(heartage_age)>1:
        unique=set(heartage_age)
        if len(unique)>1: 
            heartage_age_unique=False

    unique_entry=False
    if heartage_sex_unique and heartage_age_unique and (heartage_age_string!="") and(heartage_sex_string!=""):
        unique_entry=True

    if unique_entry and (stored==False): #store this as the truth data, since no demographic information is available for comparison
        try:
            subject_to_sex[subject]=heartage_sex[0]
        except:
            True 
        subject_to_age[subject]=heartage_age[0]
        subject_to_heartage_column[subject]=0
        subject_to_confidence[subject]=1 
    elif unique_entry:    #check for agreement with the Dem data, if it exists
        disagree=False
        subject_to_heartage_column[subject]= 0
        if subject not in subject_to_sex:
            subject_to_sex[subject]=heartage_sex[0] 
        if heartage_sex[0]!=subject_to_sex[subject]:
            disagree=True
        age_delta=abs(int(heartage_age[0]) - int(subject_to_age[subject]))
        if age_delta > 1:
            disagree=True
        if disagree:
            subject_to_confidence[subject]=0.5

            print "Disagreement between unique heart age entry and unique Demographic file entry (the demographic file entry overrides)"
            print "subject:"+str(subject) 
            print "demographic age:"+str(subject_to_age[subject])
            print "demographic sex:"+str(subject_to_sex[subject])
            print "heartage age:"+str(heartage_age[0])
            print "heartage sex:"+str(heartage_sex[0])
    elif (heartage_age_string!="") and (heartage_sex_string!=""): #non-unique entry
        #if one of the entries matches with the dem entry, use that
        if stored:
            dem_age_stored=int(subject_to_age[subject]) 
            #dem_sex_stored=subject_to_sex[subject]
            if dem_age_stored in heartage_age:
                column=heartage_age.index(dem_age_stored)
                #if heartage_sex[column]==dem_sex_stored:
                    #use this column!!
                subject_to_heartage_column[subject]=column 
        else: #take a majority vote of the heart age
            sex_mode,age_mode,column,confidence=vote(heartage_age,heartage_sex)
            if age_mode!=None:
                subject_to_sex[subject]=sex_mode
                subject_to_age[subject]=age_mode
                subject_to_heartage_column[subject]=column
                subject_to_confidence[subject]=confidence
            else: 
                print "non-unique heartage data"
                #print "heartage_sex:"+str(heartage_sex)
                #print "heartage_age:"+str(heartage_age)

    ## annotate the remaining fields ##
    outf.write(subject)
    if subject in subject_to_age:
        if int(subject_to_age[subject])==0:
            outf.write('\t-1')
        else: 
            outf.write('\t'+str(subject_to_age[subject]))
    else:
        outf.write('\t')
    if subject in subject_to_sex:
        outf.write('\t'+str(subject_to_sex[subject]))
    else:
        outf.write('\t')
    if subject in subject_to_confidence:
        outf.write('\t'+str(subject_to_confidence[subject]))
    else:
        outf.write('\t')
    for c in range(5,len(line)):
        value=line[c].split(',')
        if len(value)==1:
            #print str(value[0]) 
            outf.write('\t'+str(value[0]))
        elif len(value)>1:
            if c in dem_columns:
                if subject in subject_to_dem_column:
                    try:
                        value=line[c].split(',')[subject_to_dem_column[subject]]
                    except:#if the number of entries does not match the number of age entries, take the majority vote
                        value_counts=Counter(value)
                        value=value_counts.most_common(1)[0]                        
                    outf.write('\t'+str(value))
                else:
                    outf.write('\t'+line[c])
            else:
                if subject in subject_to_heartage_column:
                    #print str(subject)+"|"+str(subject_to_heartage_column[subject])
                    #print str(subject_to_heartage_column[subject])
                    try:
                        value=line[c].split(',')[subject_to_heartage_column[subject]]
                    except:
                        print str(subject) +"NOT SAME COLUMNS" 
                        value_counts=Counter(value)
                        value=value_counts.most_common(1)[0]                       
                    outf.write('\t'+str(value))
                else:
                    outf.write('\t'+line[c])
    outf.write('\n')
print str(len(subject_to_age.keys()))
