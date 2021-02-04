randomization_order=open("randomization_order_for_completers.tsv",'r').read().strip().split('\n') 
completion=open("completed.txt",'r').read().strip().split('\n') 
subject_to_order=dict() 
for line in randomization_order: 
    tokens=line.split(',') 
    subject=tokens[0] 
    if subject in subject_to_order: 
        continue 
    subject_to_order[subject]=dict() 
    for i in range(1,len(tokens)): 
        subject_to_order[subject][tokens[i]]=i 
print("set up intervention order") 
tally=dict() 
for line in completion: 
    tokens=line.split('\t') 
    subject=tokens[0] 
    intervention=tokens[1] 
    intervention_index=subject_to_order[subject][intervention] 
    if intervention not in tally: 
        tally[intervention]=dict() 
    if intervention_index not in tally[intervention]: 
        tally[intervention][intervention_index]=1 
    else: 
        tally[intervention][intervention_index]+=1 

import pandas as pd 
df=pd.DataFrame(tally) 
print(df) 

    
