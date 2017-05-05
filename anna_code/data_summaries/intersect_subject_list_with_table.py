#NOTE: intersect a list of subjects with specific data fields in a table
import argparse
def parse_args():
    parser=argparse.ArgumentParser(description="intersect a list of subjects with specific data fields in a table")
    parser.add_argument("--subjects_file")
    parser.add_argument("--table")
    parser.add_argument("--fields_to_ignore",nargs="*")
    return parser.parse_args()

#handles the case when the header is 1 field shorter than the body of the table 
def get_health_code_index(data_table):
    tokens=data_table[0].split('\t')
    if len(data_table)==1:
        return tokens.index("healthCode")
    else:
        first_entry=data_table[1].split('\t')
        if len(tokens)==len(first_entry):
            return tokens.index("healthCode"),0 
        else:
            return tokens.index("healthCode")+1,1
def main():
    args=parse_args()

    subjects=open(args.subjects_file,'r').read().strip().split('\n')
    subject_dict=dict()
    for subject in subjects:
        subject_dict[subject]=1
        
    data_table=open(args.table,'r').read().strip().split('\n')
    health_code_col,offset=get_health_code_index(data_table)
    print(str(health_code_col))
    header=data_table[0].split('\t')  
    field_index=dict()
    field_tally=dict()
    
    for i in range(len(header)):
        cur_field=header[i]
        if cur_field not in args.fields_to_ignore:
            field_index[cur_field]=i+offset
            field_tally[cur_field]=0
    print(str(field_tally))
    for row in data_table[1::]:
        tokens=row.split('\t')
        subject=tokens[health_code_col]
        if subject in subject_dict:
            #augment our field tallies!
            for field in field_index:
                cur_index=field_index[field]
                cur_value=tokens[cur_index]
                if (cur_value!="NA") and (cur_value!=""):
                    field_tally[field]+=1
    #print the table name & field counts
    for field in field_tally:
        print(args.table+":"+field+":"+str(field_tally[field]))
        
if __name__=="__main__":
    main()
    
