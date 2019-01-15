# -*- coding: utf-8 -*-
"""
Created on Sun Nov 25 16:58:55 2018

Identify peaks in data, and make dynamic windows

@author: dwubu
"""

from smoothedZScore import findPeaks

import sys, os, errno
import numpy as np
import pandas as pd

#directory_in_str = '/scratch/PI/euan/projects/mhc/data/6mwt/accel_walk_dir'
directory_in_str = 'C:/Users/dwubu/Desktop/6mwtData';
directory = os.fsencode(directory_in_str)

#final_directory_in_str = '/scratch/PI/euan/projects/mhc/data/6mwtwindows'
final_directory_in_str = 'C:/Users/dwubu/Desktop/6mwtDynamicWindows';
final_directory = os.fsencode(final_directory_in_str)


def normalize_dataset(dataframe):
    return (dataframe - dataframe.mean())

def create_dataframes(steps_per_frame):
    
    for file in os.listdir(directory):
        #Version when all jsons in one file on local storage
        #Read in json
        file_path = os.path.join(directory.decode(), file.decode())
        raw_data = pd.read_json(file_path).set_index('timestamp')
        
        #Put into array form
        x = np.asarray(raw_data.x)
        y = np.asarray(raw_data.y)
        z = np.asarray(raw_data.z)
        
        #Using z as metric
        peaks = findPeaks(z)
        
        x_ = []
        y_ = []
        z_ = []
        
        print(peaks)
        
        for i in range(len(peaks) - steps_per_frame):
            #Insert some check for peak validity here?
            x_.append(x[ peaks[i] : peaks[i + steps_per_frame] ]) 
            y_.append(y[ peaks[i] : peaks[i + steps_per_frame] ]) 
            z_.append(z[ peaks[i] : peaks[i + steps_per_frame] ]) 

        df = pd.DataFrame({'healthCode': file, 
                           'xwindows': x_, 'ywindows': y_, 'zwindows': z_}, columns=['healthCode', 'xwindows', 
                           'ywindows', 'zwindows']).set_index('healthCode')
    
        if not os.path.exists(final_directory.decode()):          
            os.makedirs(final_directory.decode())
        
        df.to_hdf(final_directory.decode() + '/' + os.path.splitext(file)[0].decode() +'.h5', key='df', mode='w')



create_dataframes(2)