# -*- coding: utf-8 -*-
"""
Created on Mon Jul 11

Takes in a pytables h5 file of structure 
/ (RootGroup) 'cycles'
/data (EArray(n, 100, 4)) ''
  atom := Float64Atom(shape=(), dflt=0.0)
  maindim := 0
  flavor := 'numpy'
  byteorder := 'little'
  chunkshape := (?, 100, 4)
/labels (EArray(n,)) ''
  atom := StringAtom(itemsize=40, shape=(), dflt=b'')
  maindim := 0
  flavor := 'numpy'
  byteorder := 'irrelevant'
  chunkshape := (?,)

and makes a new h5 file containing cycles only with certain healthcodes.

@author: dwubu
"""

#Imports
import pandas as pd
import os
import json
import numpy as np
import tables

out_path = r"/scratch/PI/euan/projects/mhc/code/daniel_code/data"
source_file_name = "cycles.hdf5"
file_name = "age_cycles.hdf5"
table_path = "/scratch/PI/euan/projects/mhc/code/daniel_code/tables/all.tsv"


def get_gender_hcs(table_file):
    '''
    Returns a list of healthcodes for extraction. Takes in a path to a tsv table.
    '''
    label_df = pd.read_csv(table_file, 
                           header=None,
                           names=["Healthcode", "Age", "Gender", "Ethnicity", "Version"], 
                           delimiter='\t')
    #Encode to bytes
    label_df['Healthcode'] = label_df['Healthcode'].map(lambda x: x.encode('UTF-8'))
    #Drop duplicates
    label_df = label_df.set_index('Healthcode')
    label_df = label_df.loc[~label_df.index.duplicated(keep='first')]
    
    #Drop invalid gender values
    label_df = label_df[(label_df.Gender =='Male') | (label_df.Gender == 'Female')]
    
    return list(label_df.index)


def get_age_hcs(table_file):
    '''
    Returns a list of healthcodes for extraction. Takes in a path to a tsv table.
    '''
    label_df = pd.read_csv(table_file, 
                           header=None,
                           names=["Healthcode", "Age", "Gender", "Ethnicity", "Version"], 
                           delimiter='\t')
    #Encode to bytes
    label_df['Healthcode'] = label_df['Healthcode'].map(lambda x: x.encode('UTF-8'))
    #Drop duplicates
    label_df = label_df.set_index('Healthcode')
    label_df = label_df.loc[~label_df.index.duplicated(keep='first')]
    
    
    #Drop invalid age values (non-integer)
    label_df = label_df[label_df.Age.apply(lambda x: str(x).isdigit())]
    
    #Drop invalid age values (>100)
    
    return list(label_df.index)

def get_BMI_hcs():
    table_folder = "/scratch/PI/euan/projects/mhc/data/tables"
    table_path = os.path.join(table_folder, 'cardiovascular-NonIdentifiableDemographicsTask-v2.tsv')

    df = pd.read_csv(table_path, sep='\t')
    df = df[['healthCode', 
             'NonIdentifiableDemographics.json.patientWeightPounds',
             'NonIdentifiableDemographics.json.patientHeightInches', 
             'NonIdentifiableDemographics.patientWeightPounds',
             'NonIdentifiableDemographics.patientHeightInches',]]
             #'NonIdentifiableDemographics.json.patientWakeUpTime',
             #'NonIdentifiableDemographics.json.patientCurrentAge', 
             #'NonIdentifiableDemographics.json.patientGoSleepTime']]

    print(f"Starting with {df.shape[0]} records")

    #Merge weights and heights
    df['Weight'] = df['NonIdentifiableDemographics.patientWeightPounds'].fillna(df['NonIdentifiableDemographics.json.patientWeightPounds'])
    df['Height'] = df['NonIdentifiableDemographics.patientHeightInches'].fillna(df['NonIdentifiableDemographics.json.patientHeightInches'])
    df = df[['healthCode', 'Weight', 'Height']]

    df = df.dropna()
    print(f"Dropping NaNs gives {df.shape[0]} users")

    #Drop duplicates
    df = df.set_index('healthCode')
    df = df.loc[~df.index.duplicated(keep='last')]
    print(f"Dropping duplicate healthcodes gives {df.shape[0]} users")


    df = df[df['Weight'] < 1000]
    df = df[df['Weight'] > 10]
    print(f"Dropping invalid weights (10 > w or w > 1000 pounds) gives {df.shape[0]} users")

    df = df[df['Height'] < 96]
    df = df[df['Height'] > 36]
    print(f"Dropping invalid weights (36 inches (3ft) > h or h > 96 inches (8ft)) gives {df.shape[0]} users")
    
    return list(df.index)

if __name__ == "__main__":
    
    print(f"Starting parsing from table {table_path}")
    
    #Initialize the file
    with tables.open_file(os.path.join(out_path, file_name), mode='w', title = "cycles") as file:
        file.create_earray(file.root, "data", 
                           atom = tables.Float64Atom(), 
                           shape=(0, 100, 4), 
                           expectedrows = 5e7)
        file.create_earray(file.root, "labels", 
                           atom = tables.StringAtom(itemsize=40), 
                           shape=(0,), 
                           expectedrows = 5e7)
        #8126 healthcodes * 1 6mwt/healthcode * 600 steps/6mwt ~ 5e7
    
    #Get healthcodes
    #hcs = get_gender_hcs(table_path)
    hcs = get_age_hcs(table_path)
    #hcs = get_BMI_hcs()
    
    #Parse the source file
    with tables.open_file(os.path.join(out_path, source_file_name), mode='r') as source_file:
        #Get indicies of the labels that are in the healthcodes
        labels = np.isin(source_file.root.labels[:], hcs)
        val_idxs = labels.nonzero()[0]
    
        print(f"There are {len(val_idxs)} records to be extracted out of {labels.shape}", flush = True)

        #np.random.shuffle(labels)

        #Store in pytables
        with tables.open_file(os.path.join(out_path, file_name), mode='a', title = "cycles") as new_file:
            for idx in val_idxs:
                new_file.root.data.append(np.expand_dims(source_file.root.data[idx], 0))
                new_file.root.labels.append(np.expand_dims(source_file.root.labels[idx], 0))
                

                
                