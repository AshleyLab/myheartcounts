# -*- coding: utf-8 -*-
"""
Created on Mon Jun 24 18:08:32 2019

Parses raw walk cycles into normalized cycles with LSE, and saves to hdf5 table

See the Data Preprocessing Notebook for more information.

@author: dwubu
"""

#Imports
import lomb_scargle_extractor as lse
import pandas as pd
import os
import json
import numpy as np
import tables

out_path = r"/scratch/PI/euan/projects/mhc/code/daniel_code"
data_dir = r"/scratch/PI/euan/projects/mhc/data/6mwt/accel_walk_dir"
 
#out_path = r'C:\Users\dwubu\Desktop'
#data_dir = r'C:\Users\dwubu\Desktop\gender_6mwt_subset'
   
def ls_extract(data):
    '''
    Takes in a 6mwt in MHC format: list of dict objects, with each dict
    containing a single time point with "timestamp", "x", "y", "z" keys
    does Lomb-Scargle extraction.
    
    Returns a (n x 100 x 4) numpy array
    of n walk cycles interpolated and aligned to 100 datapoints with 4 channels:
    x, y, z, mag
    '''

    #Convert data from list of json to a pandas dataframe
    df = pd.DataFrame(columns=['timestamp','x','y','z'])
    for row in data:
        df = df.append(pd.Series(row), ignore_index=True)
        
    #Conform to lse api - reindex, add mag column, and rename
    df['timestamp'] = pd.to_datetime(df['timestamp'], unit='s')
    temp_idx = pd.DatetimeIndex(df['timestamp'])
    df = df.drop('timestamp', axis = 1)
    norm = np.sqrt(np.square(df).sum(axis=1))
    df = pd.concat([df, norm], axis=1)
    df = df.rename(index=str, columns={'x': 'a_x', 'y': 'a_y', 'z': 'a_z', 0: 'a_mag'})
    df = df.set_index(temp_idx)
    
    #Chunk data, and extract windows from each chunk
    chunk_size = 500
    cycles = np.empty((0, 100, 4))
    for idx in range(0, df.shape[0], chunk_size):
    
        chunk = df[idx: idx+chunk_size]
        
        try:
            test_cycle = lse.extract(chunk)
        except:
            continue
        
        if(isinstance(test_cycle, pd.DataFrame)):
            #Reshape output and concatenate into the n x 100 x 4 format
            mag_cycle = np.reshape(list(test_cycle['a_mag']), (100, -1), order='F').T
            x_cycle = np.reshape(list(test_cycle['a_x']), (100, -1), order='F').T
            y_cycle = np.reshape(list(test_cycle['a_y']), (100, -1), order='F').T
            z_cycle = np.reshape(list(test_cycle['a_z']), (100, -1), order='F').T
            all_cycle = np.stack([x_cycle, y_cycle, z_cycle, mag_cycle], -1)
    
            #Store our current cycle into a container
            cycles = np.vstack((cycles, all_cycle))
                    
        
    return cycles

if __name__ == "__main__":
    
    #Initialize the file
    with tables.open_file(os.path.join(out_path, "cycles.hdf5"), mode='w', title = "cycles") as file:
        earray = file.create_earray(file.root, "data", 
                                    atom = tables.Float64Atom(), 
                                    shape=(0, 100, 4), 
                                    expectedrows = 5e7)
        labels = file.create_earray(file.root, "labels", 
                                    atom = tables.StringAtom(itemsize=40), 
                                    shape=(0,), 
                                    expectedrows = 5e7)
        #8126 healthcodes * 1 6mwt/healthcode * 600 steps/6mwt ~ 5e7
    
    #Iterate through all the records in the directory
    for dirpath, dirnames, filenames in os.walk(data_dir):
        i = 0
        for filename in filenames:
    
            #Only take one 6mwt per healthcode        
            while (i < 1):
                i += 1
         
                healthCode = dirpath.split(os.sep)[-1]
                print("Processing healthcode {}".format(healthCode), flush=True)
                
                #Load in data and get ready for LSE
                with open(os.path.join(dirpath, filename), 'r') as file:
                    data = json.load(file)
                    
                #Extract
                temp_cycles = ls_extract(data)
                
                #Store in pytables
                with tables.open_file(os.path.join(out_path, "cycles.hdf5"), mode='a', title = "cycles") as h5_file:
                    h5_file.root.data.append(temp_cycles)
                    h5_file.root.labels.append([healthCode]*temp_cycles.shape[0])
                #earray.append(temp_cycles)
                #labels.append([healthCode]*temp_cycles.shape[0])
                
                
