import argparse 
import pandas as pd
from dateutil.parser import parse
def parse_args(): 
    parser=argparse.ArgumentParser(description="plot histograms of # subjects vs days of data; day of study vs # subjects")
    parser.add_argument("--source_tables",nargs="+") 
    parser.add_argument("--outf") 
    parser.add_argument("--start_date",default=None) 
    parser.add_argument("--end_date",default=None)
    return parser.parse_args() 

def main(): 
    args=parse_args() 
    date_to_subject=dict()
    subject_to_date=dict()
    start_date=None
    if args.start_date!=None: 
        start_date=parse(args.start_date).date()
    end_date=None
    if args.end_date!=None: 
        end_date=parse(args.end_date).date() 
        
    for source_table in args.source_tables:
        print(source_table)
        data=pd.read_csv(source_table,header=0,sep='\t',index_col=0)
        for index,row in data.iterrows(): 
            healthCode=row['healthCode'] 
            uploadedOn=parse(row['uploadDate']).date() 
            if start_date!=None: 
                if uploadedOn < start_date: 
                    continue 
            if end_date!=None: 
                if uploadedOn > end_date: 
                    continue 
            if healthCode not in subject_to_date: 
                subject_to_date[healthCode]=set([uploadedOn])
            else: 
                subject_to_date[healthCode].add(uploadedOn)
            if uploadedOn not in date_to_subject: 
                date_to_subject[uploadedOn]=set([healthCode]) 
            else: 
                date_to_subject[uploadedOn].add(healthCode) 
    #write output files
    outf_date=open(args.outf+".by_date.tsv",'w')
    outf_date.write("Date\tNumSubjects\n")
    for cur_date in date_to_subject: 
        outf_date.write(str(cur_date)+'\t'+str(len(date_to_subject[cur_date]))+'\n')
    subject_hist=dict() 
    for subject in subject_to_date: 
        cur_duration=len(subject_to_date[subject])
        if cur_duration not in subject_hist: 
            subject_hist[cur_duration]=1
        else: 
            subject_hist[cur_duration]+=1 
    outf_subject=open(args.outf+".by_subject.tsv",'w')
    outf_subject.write("NumDaysData\tNumSubjects\n")
    for cur_duration in subject_hist: 
        outf_subject.write(str(cur_duration)+'\t'+str(subject_hist[cur_duration])+'\n')

        
if __name__=="__main__": 
    main() 
