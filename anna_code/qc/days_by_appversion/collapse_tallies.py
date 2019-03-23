import pandas as pd 
data=pd.read_table("appVersion.tallies.txt",header=0,sep='\t')
print("loaded data") 
outf=open("appVersion.tallies.collapsed.txt","w")
data_dict=dict() 
for index,row in data.iterrows(): 
    healthCode=row['healthCode'] 
    appVersion=row['appVersion'] 
    if healthCode not in data_dict: 
        data_dict[healthCode]=dict() 
    if appVersion not in data_dict[healthCode]: 
        data_dict[healthCode][appVersion]=1 
    else: 
        data_dict[healthCode][appVersion]+=1 
outf.write('healthCode\tVersion\tUniqueNumberDays\n')
for healthCode in data_dict: 
    for appVersion in data_dict[healthCode]: 
        outf.write(healthCode+'\t'+str(appVersion)+'\t'+str(data_dict[healthCode][appVersion])+'\n')

    
