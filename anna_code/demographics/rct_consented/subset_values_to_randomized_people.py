import pandas as pd 
import sys 
import pdb
data=pd.read_csv(sys.argv[1],header=None,sep='\t')
subjects=pd.read_csv('subjects.txt',header=None)
subset=data[data[0].isin(subjects[0])]
#nums=pd.to_numeric(subset[1],errors='coerce')
#mean_val=nums.mean() 
#print(mean_val) 
#std_val=nums.std() 
#print(std_val)
pdb.set_trace() 
