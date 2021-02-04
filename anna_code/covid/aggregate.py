import pandas as pd 
import sys 
import pdb 
df=pd.read_csv(sys.argv[1],header=0,sep='\t')
print(df.shape) 
sub_df_2019=df[(df['Date']>='2019-03-01') & (df['Date']<'2019-05-01')]
sub_df_2020=df[(df['Date']>='2020-03-01') & (df['Date']<'2020-05-01')]

print(df.shape) 
print(sub_df_2019.shape) 
print(sub_df_2020.shape) 

sub_df_2019_means=pd.DataFrame(sub_df_2019.groupby('Date')['Fraction'].mean())
#sub_df_2019_means['Date']=sub_df_2019_means.index
sub_df_2020_means=pd.DataFrame(sub_df_2020.groupby('Date')['Fraction'].mean()) 
#sub_df_2020_means['Date']=sub_df_2020_means.index
merged=sub_df_2019_means.merge(sub_df_2020_means,on=['Date'])
pdb.set_trace() 

