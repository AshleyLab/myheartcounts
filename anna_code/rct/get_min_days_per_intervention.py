import argparse 
import pandas as pd 
import pdb 
def parse_args(): 
    parser=argparse.ArgumentParser(description="filter dataset to require minimum days of data per intervention")
    parser.add_argument("--input_data") 
    parser.add_argument("--min_days",type=int) 
    parser.add_argument("--outf") 
    return parser.parse_args() 

def main(): 
    args=parse_args() 
    data=pd.read_table(args.input_data,header=0,sep='\t')
    #tally number of days of data for each subject/intervention 
    intervention_tally=dict() 
    for index,row in data.iterrows(): 
        cur_subject=row['Subject'] 
        cur_intervention=row['ABTest'] 
        cur_date=row['Date'] 
        if cur_subject not in intervention_tally: 
            intervention_tally[cur_subject]=dict() 
        if cur_intervention not in intervention_tally[cur_subject]: 
            intervention_tally[cur_subject][cur_intervention]=dict() 
        if cur_date not in intervention_tally[cur_subject][cur_intervention]: 
            intervention_tally[cur_subject][cur_intervention][cur_date]=['\t'.join([str(i) for i in row])]
        else: 
            intervention_tally[cur_subject][cur_intervention][cur_date].append('\t'.join([str(i) for i in row]))
    print("got tally of intervention") 
    #filter subject/interventions for min number of days 
    outf=open(args.outf,'w') 
    outf.write('\t'.join([str(data.columns[i]) for i in range(len(data.columns))])+'\n')
    for subject in intervention_tally: 
        for intervention in intervention_tally[subject]: 
            num_days=len(intervention_tally[subject][intervention]) 
            if (num_days >=args.min_days): 
                #write the output file 
                for day in intervention_tally[subject][intervention]: 
                    outf.write('\n'.join(intervention_tally[subject][intervention][day])+'\n')
                
    

if __name__=="__main__":
    main() 
