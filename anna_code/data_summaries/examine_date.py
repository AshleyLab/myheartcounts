#Looks at the number of uploads by each active user on a specified day 
#parses all tables to give a file with Date\tVersion\tNumberOfRecords
import sys 
from Parameters import * 
import os 
from os import listdir 
from os.path import isfile,join,exists


def main(): 
    target_date=sys.argv[1]
    files=csv_files=[f for f in listdir(table_dir) if isfile(join(table_dir,f))]
    upload_dict=dict()#user->number of uploads  
    for f in files: 
        if f.endswith('.tsv'): 
            print str(f) 
            data=open(table_dir+f,'r').read().split('\n') 
            if '' in data: 
                data.remove('') 
            for line in data[1::]: 
                line=line.split('\t')
                subject=line[2] 
                upload_date=line[4] 
                if upload_date!=target_date:
                    continue 
                version=line[6] 
                if version=="NA": 
                    continue 
                if version.__contains__("YML"): 
                    continue 
                if version not in upload_dict: 
                    upload_dict[version]=dict() 
                if subject not in upload_dict[version]: 
                    upload_dict[version][subject]=1
                else: 
                    upload_dict[version][subject]+=1 
    outf=open('examine_'+target_date,'w') 
    #Write output file 
    for version in upload_dict: 
        for subject in  upload_dict[version]: 
            outf.write(version+'\t'+subject+'\t'+str(upload_dict[version][subject])+'\n')

if __name__=="__main__": 
    main() 
