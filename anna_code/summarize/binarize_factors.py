import pandas as pd 
from math import isnan
import pdb 
data=pd.read_csv("merged.tsv",header=0,sep='\t',index_col=0)
tobinarize=['vascular','medications_to_treat','family_history','heart_disease','race','device','sodium']
bin_vals=dict() 
for index,row in data.iterrows(): 
    for field in tobinarize: 
        healthCode=index
        cur_vals=row[field]
        try:
            if isnan(cur_vals): 
                continue
        except: 
            pass
        try:
            cur_vals=cur_vals.split(',')
        except: 
            cur_vals=[str(int(cur_vals))]
        if field not in bin_vals: 
            bin_vals[field]=dict() 
        for v in cur_vals: 
            if v not in  bin_vals[field]: 
                bin_vals[field][field+"_"+v]=dict() 
            bin_vals[field][field+"_"+v][healthCode]=1 
data=data.drop(tobinarize, axis=1)
for field in bin_vals: 
    subdf=pd.DataFrame.from_dict(bin_vals[field])
    subdf=subdf.fillna(0)
    data=data.merge(subdf,left_index=True,right_index=True,how="outer") 
data.to_csv("merged_binarized.tsv",sep='\t',header=True,index=True)
