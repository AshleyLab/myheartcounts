#parses all tables to give a file with Date\tVersion\tNumberOfRecords
from Parameters import * 
import os 
from os import listdir 
from os.path import isfile,join,exists


def main(): 
    files=csv_files=[f for f in listdir(table_dir) if isfile(join(table_dir,f))]
    upload_dict=dict() 
    upload_dict_subject=dict() 
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
                version=line[6] 
                if version=="NA": 
                    continue 
                if version.__contains__("YML"): 
                    continue 
                if upload_date not in upload_dict: 
                    upload_dict[upload_date]=dict()
                    upload_dict_subject[upload_date]=dict() 
                if version not in upload_dict[upload_date]: 
                    upload_dict[upload_date][version]=1 
                    upload_dict_subject[upload_date][version]=[subject] 
                else: 
                    upload_dict[upload_date][version]+=1 
                    if subject not in upload_dict_subject[upload_date][version]: 
                        upload_dict_subject[upload_date][version].append(subject) 

    #Write output file 
    dates=upload_dict.keys() 
    dates.sort() 
    outf=open(uploads_file,'w')
    outf.write("Date\tVersion\tUploads\tActiveUsers\n") 
    for date in dates: 
        versions=upload_dict[date].keys() 
        versions.sort() 
        for version in versions: 
            actuse=len(upload_dict_subject[date][version])
            outf.write(date+'\t'+version+'\t'+str(upload_dict[date][version])+'\t'+str(actuse)+'\n')

if __name__=="__main__": 
    main() 

