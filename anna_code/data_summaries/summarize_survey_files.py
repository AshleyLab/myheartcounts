from dateutil.parser import parse
from collections import Counter 
from helpers import * 
from Parameters import * 
#gets a majority vote across multiple values 
def vote(entry):
    value_counts=Counter(entry)
    histogram=value_counts.most_common()
    if (len(histogram)==1) or (histogram[0][1] > histogram[1][1]):
        #we have a unique mode!
        mode=histogram[0][0]
        mode_count=entry.count(mode)
        confidence=float(mode_count)/len(entry)
        index_val=entry.index(mode) 
        return mode,confidence,index_val
    else: #there is no majority consensus  
        return None,None,None 


#entry_h --> from heart_age table 
#entry_d --> from demographics table, takes precedence 
def resolve(entry_h,entry_d):  
    stored=False

    empty_h=(len(entry_h)==0)
    empty_d=(len(entry_d)==0) 

    unique_d=(len(set(entry_d))<2)
    unique_h=(len(set(entry_h))<2) 
    
    resolved_entry=None 
    confidence=0 
    #keep the index for the entry to use in case of non-unique values 
    index_d=None 
    index_h=None 

    #1) Demographics Information 
    if unique_d and (not empty_d): 
        resolved_entry=entry_d[0] 
        confidence=1 
        index_d=0 
        stored=True 
    elif (not empty_d): 
        #TAKE A MAJORITY VOTE! 
        vote_result,vote_confidence,index=vote(entry_d) 
        if vote_result!=None: 
            resolved_entry=vote_result 
            confidence=vote_confidence 
            index_d=index 
    #2) Check Heart Age information 
    #CASE 1: No demographic information, unique heart age entry 
    if unique_h and (not stored) and (not empty_h): 
        resolved_entry=entry_h[0] 
        confidence=1 
        index_h=0 
    #CASE 2: unique demographic and unique heart age, check for agreement, demographic wins 
    elif unique_h and stored and (not empty_h): 
        index_h=0 
        if resolved_entry!=entry_h[0]:
            #allow a 1 year delta in age 
            if type(resolved_entry) in [int,float]: 
                delta=abs(resolved_entry-entry_h[0])
                if delta >2: 
                    confidence=0.5 
            else: 
                confidence=0.5 #lower confidence because they don't agree 

            #print "Disagreement between  heart age entry("+str(entry_h[0])+") and  demographic file entry("+str(resolved_entry)+"),demographic overrides"
    #CASE 3: Non-unique heart age entry and no demographic age stored 
    elif (not unique_h) and (not stored): 
        #MAJORITY VOTE! 
        vote_result,vote_confidence,index=vote(entry_h) 
        if vote_result!=None: 
            resolved_entry=vote_result
            confidence=vote_confidence 
            index_h=index 
    return resolved_entry,confidence,index_d,index_h 


#get the column indices of the age and sex fields in each table 
def get_age_sex_indices(table_dir,demographics):
    table_to_age_index=dict() 
    table_to_sex_index=dict() 
    for table in demographics:
        data=split_lines(table_dir+table) 
        header=data[0].split('\t')
        age_index=None 
        sex_index=None 
        isheartage=False 
        if header.__contains__('heartAgeDataAge'): 
            isheartage=True 
            age_index=header.index('heartAgeDataAge') 
            sex_index=header.index('heartAgeDataGender') 
        else: 
            #the field may or may not include the word "json" 
            if "NonIdentifiableDemographics.json.patientCurrentAge" in header: 
                age_index=header.index('NonIdentifiableDemographics.json.patientCurrentAge')
            else: 
                age_index=header.index('NonIdentifiableDemographics.patientCurrentAge')
            if "NonIdentifiableDemographics.json.patientBiologicalSex" in header: 
                sex_index=header.index('NonIdentifiableDemographics.json.patientBiologicalSex') 
            else: 
                sex_index=header.index('NonIdentifiableDemographics.patientBiologicalSex') 
        table_to_age_index[table]=age_index+1
        table_to_sex_index[table]=sex_index+1
    return table_to_age_index,table_to_sex_index 
        


def read_known_entries(table_dir,demographics,table_to_age_index,table_to_sex_index): 
    heartage_age=dict() 
    heartage_sex=dict() 
    dem_age=dict() 
    dem_sex=dict() 
    subjects=set() 
    for table in demographics:
        print str(table) 
        data=split_lines(table_dir+table)
        age_index=table_to_age_index[table] 
        #print "age_index:"+str(age_index) 
        sex_index=table_to_sex_index[table] 
        #print "sex_index:"+str(sex_index) 
        if data[0].__contains__("heartAgeDataAge"):
            isheartage=True
        else:
            isheartage=False 
        for line in data[1::]: 
            line=line.split('\t') 
            if len(line)<3: 
                continue 
            healthcode=line[2] 
            subjects.add(healthcode) 
            age_entry=line[age_index].split(',')  
            while "" in age_entry: 
                age_entry.remove('') 
            sex_entry=line[sex_index].split(',') 
            while "" in sex_entry: 
                sex_entry.remove("")
            while "NA" in age_entry: 
                age_entry.remove("NA") 
            while "NA" in sex_entry: 
                sex_entry.remove("NA") 
            sex_entry=[i.replace("HKBiologicalSex","") for i in sex_entry] 
            sex_entry=[i.replace("[","").replace("]","").replace('\"','')  for i in sex_entry] 
            print str(age_entry) 
            if isheartage: 
                # since v.1.0.10, there are both years and numerical ages in the heart age file. Be able to parse both of them. 
                age_entry_filtered=[] 
                for ae in age_entry: 
                    if ae.__contains__('-'): 
                        #YEAR! 
                        age_entry_filtered.append(2015-int(ae.split('-')[0]))
                    else: 
                        age_entry_filtered.append(int(ae))
                age_entry=age_entry_filtered                 
                #age_entry=[2015-parse(i).year for i in age_entry] #allow age +/- 1 for comparison with Dem. file data, since they may or may not have had a birthday this year     
                if healthcode not in heartage_age: 
                    heartage_age[healthcode]=age_entry 
                else: 
                    heartage_age[healthcode]+=age_entry 
                if healthcode not in heartage_sex: 
                    heartage_sex[healthcode]=sex_entry 
                else: 
                    heartage_sex[healthcode]+=sex_entry 
            else: 
                if healthcode not in dem_age: 
                    dem_age[healthcode]=age_entry 
                else: 
                    dem_age[healthcode]+=age_entry 
                if healthcode not in dem_sex: 
                    dem_sex[healthcode]=sex_entry 
                else: 
                    dem_sex[healthcode]+=sex_entry 
    return heartage_age,heartage_sex,dem_age,dem_sex,subjects  

def add_demographic_entries(resolved_index_h,resolved_index_d,table_to_age_index,table_to_sex_index,table_dir,demographics): 
    feature_dict=dict() 
    feature_dict['HeartAge']=dict() 
    feature_dict['Demographics']=dict() 
    for table in demographics: 
        data=split_lines(table_dir+table)
        age_index=table_to_age_index[table] 
        print "age_index:"+str(age_index) 
        sex_index=table_to_sex_index[table]
        to_remove=[age_index,sex_index] 
        header=data[0].split('\t') 
        if "heartAgeDataAge" in header: 
            isheartage=True
        else:
            isheartage=False 
        if isheartage: 
            table_name="HeartAge" 
        else: 
            table_name="Demographics"
 
       #remove the age and sex indices 
        for index in sorted(to_remove, reverse=True):
            del header[index-1]
        header=header[7::] 

        for line in data: 
            line=line.split('\t') 
            if len(line)<9: 
                continue 
            for index in sorted(to_remove,reverse=True): 
                del line[index] 
            subject=line[2]
            line=line[8::] 

            for i in range(len(line)): 
                if header[i].endswith("_unit"): 
                    continue 
                feature=header[i] 
                value=line[i].replace('\"','').replace(']','').replace('[','') 
                value=value.split(',') 

                #if there are multiple entries for the value, choose the one that corresponds to the resolved age/sex entry 
                if len(value)>1 and (isheartage) and (subject in resolved_index_h): 
                    value=value[resolved_index_h][subject] 
                elif len(value)>1 and (not isheartage) and (subject in resolved_index_d): 
                    value=value[resolved_index_d][subject] 
                else: 
                    value=value[0] #DEFAULT TO THE FIRST ENTERED VALUE ! 
                if feature not in feature_dict[table_name]: 
                    feature_dict[table_name][feature]=dict() 
                feature_dict[table_name][feature][subject]=value 
    return feature_dict     

#Aggregate entries for all the survey files! 
def add_survey_entries(table_dir,survey_files): 
    feature_dict=dict() 
    for table in survey_files: 
        print str(table) 
        feature_dict[table]=dict()
        data=open(table_dir+table,'r').read().replace('\r\n','\n').split('\n') 
        if '' in data: 
            data.remove('') 
        header=data[0].split('\t')[7::] 
        for line in data[1::]: 
            line=line.split('\t') 
            if len(line)<8: 
                continue 
            subject=line[2] 
            line=line[8::] 
            for i in range(len(line)): 
                feature=header[i] 
                if feature.endswith('_unit'): 
                    continue 
                value=line[i].replace('\"','').replace('[','').replace(']','') 
                value=value.split(',')[0]# ONLY KEEP 1 ENTRY 
                if feature not in feature_dict[table]: 
                    feature_dict[table][feature]=dict() 
                feature_dict[table][feature][subject]=value 
    return feature_dict 

def write_output(survey_summary_file,subjects,resolved_age,resolved_sex,demographic_dict,survey_dict):
    outf=open(survey_summary_file,'w') 
    #get the header lines 
    header1_dem=[] 
    header2_dem=[]
    header1_survey=[] 
    header2_survey=[] 

    for fname in demographic_dict: 
        for feature in demographic_dict[fname]: 
            header1_dem.append(fname) 
            header2_dem.append(feature) 

    for fname in survey_dict: 
        for feature in survey_dict[fname]:
            header1_survey.append(fname) 
            header2_survey.append(feature) 

    header1="#File\tAge\tConfidenceAge\tSex\tConfidenceSex\t"+"\t".join(header1_dem)+"\t"+"\t".join(header1_survey)
    header2="Feature\tAge\tConfidenceAge\tSex\tConfidenceSex\t"+"\t".join(header2_dem)+"\t"+"\t".join(header2_survey) 
    outf.write(header1+'\n'+header2+'\n') 
    print "got headers!" 
    print "subjects:"+str(len(subjects))
    c=0
    for subject in subjects: 
        c+=1 
        #if c%100==0: 
        #    print str(c) 
        cur_entry=subject
        #outf.write(subject) 
        #AGE & SEX 
        if subject in resolved_age: 
            cur_entry=cur_entry+'\t'+'\t'.join([str(i) for i in resolved_age[subject]])
        else: 
            cur_entry=cur_entry+'\tNA\tNA'
        if subject in resolved_sex: 
            cur_entry=cur_entry+'\t'+'\t'.join([str(i) for i in resolved_sex[subject]])
        else: 
            cur_entry=cur_entry+'\tNA\tNA'
        #DEMOGRAPHIC FEATURES 
        for i in range(len(header1_dem)): 
            h1=header1_dem[i] 
            h2=header2_dem[i] 
            if subject in demographic_dict[h1][h2]: 
                cur_entry=cur_entry+'\t'+str(demographic_dict[h1][h2][subject])
            else: 
                cur_entry=cur_entry+'\tNA'
        #SURVEY FEATURES 
        for i in range(len(header1_survey)):
            h1=header1_survey[i] 
            h2=header2_survey[i] 
            if subject in survey_dict[h1][h2]: 
                cur_entry=cur_entry+'\t'+str(survey_dict[h1][h2][subject])
            else: 
                cur_entry=cur_entry+'\tNA'
        outf.write(cur_entry+'\n') 

            

def main(): 
    from Parameters import * 
    #GET INDICES OF AGE AND SEX COLUMNS 
    table_to_age_index,table_to_sex_index=get_age_sex_indices(table_dir,demographics)
    print "Got Age and Sex table indices!"#+str(table_to_age_index)+"|"+str(table_to_sex_index) 
    #BUILD DICTIONARIES OF ENTRIES FOR AGE AND SEX 
    heartage_age,heartage_sex,dem_age,dem_sex,subjects=read_known_entries(table_dir,demographics,table_to_age_index,table_to_sex_index)
    print "Read Known Entries!"
    resolved_age=dict() #STORES RESOLVED AGE ENTRIES 
    resolved_sex=dict() #STORES RESOLVED SEX ENTRIES 
    resolved_index_h=dict() 
    resolved_index_d=dict() 
    print "Number of subjects:"+str(len(subjects)) 
    for subject in subjects: 
        hs=[]
        ha=[] 
        ds=[] 
        da=[] 
        if subject in heartage_sex: 
            hs=heartage_sex[subject] 
        if subject in heartage_age: 
            ha=heartage_age[subject] 
        if subject in dem_age: 
            da=dem_age[subject] 
        if subject in dem_sex: 
            ds=dem_sex[subject] 

        resolved_age_subject,resolved_age_confidence,index_age_d,index_age_h = resolve(ha,da)
        #print "resolved age information" 
        resolved_sex_subject,resolved_sex_confidence,index_sex_d,index_sex_h = resolve(hs,ds) 
        #print "resolved sex information" 
        if resolved_age_subject!=None:
            resolved_age[subject]=[resolved_age_subject,resolved_age_confidence]
        if resolved_sex_subject!=None: 
            resolved_sex[subject]=[resolved_sex_subject,resolved_sex_confidence] 
    
        if (index_age_h==index_sex_h) and (index_age_h!=None): 
            resolved_index_h[subject]=index_age_h 
        elif index_age_h!=None: 
            resolved_index_h[subject]=index_age_h 
        elif index_sex_h!=None: 
            resolved_index_h[subject]=index_sex_h 


        if (index_age_d==index_sex_d) and (index_age_d!=None):  
            resolved_index_d[subject]=index_age_d 
        elif index_age_d!=None: 
            resolved_index_d[subject]=index_age_d 
        elif index_sex_d!=None: 
            resolved_index_d[subject]=index_sex_d 

    #MERGE THE AGE/SEX INFORMATION WITH OTHER INFORMATION FROM THE HEART AGE AND DEMOGRAPHIC FILES 
    demographic_dict=add_demographic_entries(resolved_index_h,resolved_index_d,table_to_age_index,table_to_sex_index,table_dir,demographics) 
    print "got demographic features" 
    #ADD IN ENTRIES FROM THE OTHER SURVEY TABLES 
    survey_dict=add_survey_entries(table_dir,csv_formats) 
    print "got survey features" 
    #GET A LIST OF ALL SUBJECTS IN THE STUDY  
    subjects=open(subject_file,'r').read().split('\n') 
    if '' in subjects: 
        subjects.remove('') 

    #MERGE SURVEY,DEMOGRAPHICS,AGE&SEX 
    write_output(survey_summary_file,subjects,resolved_age,resolved_sex,demographic_dict,survey_dict)
            
if __name__=="__main__": 
    main() 
