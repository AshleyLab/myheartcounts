# -*- coding: utf-8 -*-
"""
Created on Sun Feb 10 21:05:40 2019

@author: dwubu
"""

import pandas as pd

def get_cardio_data(healthcodes = []):
    '''
    Function which returns a dataframe of the self reported cardiovascular heart
    risk factors and age data of the requested healthcodes.
    Takes a list of IDs as a parameter
    '''
    # Get the reference table 
    heart_risk_path = r"C:\Users\dwubu\Documents\mhc\cardiovascular-heart_risk_and_age-v1.tsv"
    table = pd.read_csv(heart_risk_path, sep='\t')
    
    #Get only useful columns
    table = table[['recordId', 'healthCode', 'heartAgeDataAge', 'heartAgeDataBloodGlucose', 
                   'heartAgeDataBloodGlucose_unit', 'heartAgeDataDiabetes', 'heartAgeDataGender',
                   'heartAgeDataEthnicity', 'heartAgeDataHdl', 'heartAgeDataHdl_unit', 
                   'heartAgeDataHypertension', 'heartAgeDataLdl', 'heartAgeDataLdl_unit',
                   'smokingHistory', 'heartAgeDataSystolicBloodPressure',
                   'heartAgeDataSystolicBloodPressure_unit', 'heartAgeDataDiastolicBloodPressure',
                   'heartAgeDataDiastolicBloodPressure_unit', 'heartAgeDataTotalCholesterol', 
                   'heartAgeDataTotalCholesterol_unit']]
    
    #Index by healthCode
    table = table.set_index('healthCode')
    
    #Extract rows with given healthcodes
    #table = table.loc[healthcodes]
    
    return table
