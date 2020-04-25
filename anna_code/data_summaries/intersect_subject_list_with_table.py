#NOTE: intersect a list of subjects with specific data fields in a table
import argparse
def parse_args():
    parser=argparse.ArgumentParser(description="intersect a list of subjects with specific data fields in a table")
    parser.add_argument("--subjects_file")
    parser.add_argument("--table")
    parser.add_argument("--fields_to_ignore",nargs="*")
    parser.add_argument("--fields_to_use_for_gwas",nargs="*")
    parser.add_argument("--outf")
    return parser.parse_args()

#handles the case when the header is 1 field shorter than the body of the table 
def get_health_code_index(data_table,table_name):
    tokens=data_table[0].split('\t')
    try:
        if len(data_table)==1:
            return [tokens.index("healthCode"),0]
        else:
            first_entry=data_table[1].split('\t')
            if len(tokens)==len(first_entry):
                return [tokens.index("healthCode"),0]
            else:
                return [tokens.index("healthCode")+1,1]
    except:
        print("Failed to get healthCode index for table:"+table_name)
        exit() 
        
def main():
    args=parse_args()
    print(args.table)
    subjects=open(args.subjects_file,'r').read().strip().split('\n')
    subject_dict=dict()
    for subject in subjects:
        subject_dict[subject]=1
        
    data_table=open(args.table,'r').read().strip().split('\n')
    [health_code_col,offset]=get_health_code_index(data_table,args.table)
    header=data_table[0].split('\t')  
    field_index=dict()
    field_tally=dict()
    field_subject_values=dict()
    
    for i in range(len(header)):
        cur_field=header[i]
        if cur_field not in args.fields_to_ignore:
            field_index[cur_field]=i+offset
            field_tally[cur_field]=set([])
            field_subject_values[cur_field]=dict()
    for row in data_table[1::]:
        tokens=row.split('\t')
        subject=tokens[health_code_col]
        if subject in subject_dict:
            #augment our field tallies!
            for field in field_index:
                cur_index=field_index[field]
                cur_value=tokens[cur_index]
                if (cur_value!="NA") and (cur_value!=""):
                    field_tally[field].add(subject)
                    field_subject_values[field][subject]=cur_value 
    #print the table name & field counts
    for field in field_tally:
        print(args.table+":"+field+":"+str(len(field_tally[field])))
    for field in args.fields_to_use_for_gwas:
        if field in field_subject_values:
            outf=open(args.outf+"."+field,'w')
            outf.write('Subject\t'+field+'\n')
            for subject in subjects:
                if subject in field_subject_values[field]:
                    outf.write(subject+'\t'+str(field_subject_values[field][subject])+'\n')
                else:
                    outf.write(subject+'\t'+"NA"+"\n")
        
if __name__=="__main__":
    main()
    
