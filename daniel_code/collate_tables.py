# -*- coding: utf-8 -*-
"""
Created on Fri Feb 22 00:36:04 2019

Utility function to read in useful data from .tsv files and put into a central
file

Currently gets:
    Risk factor survey: 
        family_history, 
        medications_to_treat, 
        heart_disease
        (optional vascular, currently not included)
        
    Heart age survey: 
        heartAgeDataHypertension
        heartAgeDataAge
        heartAgeDataDiabetes
        heartAgeDataEthnicity
        heartAgeDataGender
        heartAgeDataHdl
        heartAgeDataHypertension
        heartAgeDataLdl
        heartAgeDataSystolicBloodPressure
        heartAgeDataTotalCholesterol
        smokingHistory
        
    ParQ:
        heartCondition
        
and indexes by healthCode


GET GENDER FROM NONIDENTIFIABLE DEMOGRAPHICS

@author: dwubu
"""
import numpy as np
import pandas as pd
import os

source_dir = '/scratch/users/danjwu/tables'

par_q_filename = 'cardiovascular-par-q-quiz-v1.tsv'
heart_age_filename = 'cardiovascular-2-APHHeartAge-7259AC18-D711-47A6-ADBD-6CFCECDED1DF-v2.tsv'
risk_factors_filename = 'cardiovascular-risk_factors-v1.tsv'

destination_filename = 'combined_health_label_table.pkl'

#As of 2/23/19, there are 53882 entries
par_q = pd.read_csv(
        os.path.join(source_dir, par_q_filename), 
        sep='\t')

#As of 2/23/19, there are 4249 entries
heart_age = pd.read_csv(
        os.path.join(source_dir, heart_age_filename), 
        sep='\t')

#As of 2/23/19, there are 21307 entries
risk_factors = pd.read_csv(
        os.path.join(source_dir, risk_factors_filename), 
        sep='\t')

#Keep only wanted columns
par_q = par_q[['heartCondition',
               'healthCode']]

heart_age = heart_age[['heartAgeDataHypertension',
                       'heartAgeDataAge',
                       'heartAgeDataDiabetes',
                       'heartAgeDataEthnicity',
                       'heartAgeDataGender',
                       'heartAgeDataHdl',
                       'heartAgeDataHypertension',
                       'heartAgeDataLdl',
                       'heartAgeDataSystolicBloodPressure',
                       'heartAgeDataTotalCholesterol',
                       'smokingHistory',
                       'healthCode']]

risk_factors = risk_factors[['family_history',
                             'medications_to_treat', 
                             'heart_disease',
                             'healthCode']]

#Drop duplicate healthcodes
#As of 2/23/19, there are unique 44283 entries
par_q.drop_duplicates(subset='healthCode', inplace = True, keep='last')
#As of 2/23/19, there are unique 3022 entries
heart_age.drop_duplicates(subset='healthCode', inplace = True, keep='last')
#As of 2/23/19, there are unique 20327 entries
risk_factors.drop_duplicates(subset='healthCode', inplace = True, keep='last')

#Reindex by healthcode
par_q = par_q.set_index('healthCode')
heart_age = heart_age.set_index('healthCode')
risk_factors = risk_factors.set_index('healthCode')

#Merge data
#As of 2/23/19, there are 44557 total unique entries 
final_table = pd.concat([par_q, heart_age, risk_factors], axis = 1)

final_table.to_pickle(os.path.join(source_dir, destination_filename))