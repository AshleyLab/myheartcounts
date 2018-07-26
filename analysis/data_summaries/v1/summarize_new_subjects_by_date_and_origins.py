#parses uploads to give Date\tGMToffset\tSubjects 
#parses all tables to give a file with Date\tVersion\tNumberOfRecords
from Parameters import * 
import os 
from os import listdir 
from os.path import isfile,join,exists


def main(): 
    files=csv_files=[f for f in listdir(table_dir) if isfile(join(table_dir,f))]
    subject_to_date=dict() 
    subject_to_version=dict() 
    for f in files: 
        if f.endswith('.tsv'): 
            print str(f) 
            data=open(table_dir+f,'r').read().split('\n') 
            if '' in data: 
                data.remove('') 
            for line in data[1::]: 
                line=line.split('\t')
                subject=line[2] 
                upload_date=line[5].split(' ')[0]  
                if upload_date=="NA": 
                    continue 
                #if upload_date.startswith("2015")==False: 
                #    print str(f) +" "+upload_date
                version=line[6] 
                #if version.__contains__("YML"): 
                #    continue 
                #if version=="NA": 
                #    continue 
                if subject not in subject_to_date: 
                    subject_to_date[subject]=[upload_date] 
                else:
                    subject_to_date[subject].append(upload_date) 
                if subject not in subject_to_version: 
                    subject_to_version[subject]=[version] 
                else: 
                    subject_to_version[subject].append(version) 

    #get subject info 
    newusers=set() 
    carryover=set() 
    total_users_by_date=dict() 
    new_users_by_date=dict() 

    for subject in subject_to_version: 
        entries=set(subject_to_version[subject]) 
        if "NA" in entries: 
            entries.remove("NA")
        entries=list(entries) 
        if len(entries)==1: 
            if entries[0].startswith("version 1.0.10"): 
                newusers.add(subject) 
        elif len(entries)>1: 
            #are the a cary-over user? 
            for version in entries: 
                if version.startswith("version 1.0.10"): 
                    carryover.add(subject) 

    all_dates=set() 
    for subject in subject_to_date: 
        dates=subject_to_date[subject] 
        dates.sort() 
        add_date=dates[0]
        all_dates.add(add_date) 
        if add_date not in new_users_by_date: 
            new_users_by_date[add_date]=1 
        else: 
            new_users_by_date[add_date]+=1 
    all_dates=list(all_dates) 
    all_dates.sort() 
    total_users=0 
    for d in all_dates: 
        total_users+=new_users_by_date[d] 
        total_users_by_date[d]=total_users 
    outf=open('v10_users.txt','w') 
    for u in newusers: 
        outf.write(u+'\n') 
    outf=open('carry_over_users.txt','w') 
    for u in carryover: 
        outf.write(u+'\n') 


    outf=open('new_users_by_date.txt','w') 
    outf2=open('new_users_by_date.graph','w') 
    for date in all_dates: 
        outf.write(date+'\t'+str(new_users_by_date[date])+'\t'+str(total_users_by_date[date])+'\n')
        outf2.write(date+'\t'+str(new_users_by_date[date])+'\t'+'NewUsers\n'+date+'\t'+str(total_users_by_date[date])+'\t'+'TotalUsers\n')

if __name__=="__main__": 
    main() 

