# -*- coding: utf-8 -*-
"""
Created on Sun Jan 27 21:31:07 2019

Provides a single function, process_data, which does the data preprocessing
Built to read the jsons in pedometer_walk_dir

Unifies the contents of make_windows.py, filter_windows.py, and butterworth.py

The pedometer data has absolute times, while the acceleration data has relative
timestamps as time since device boot. This converts to datetime.timedelta
objects for comparison

@author: dwubu
"""
# =============================================================================
# Import dependencies
# =============================================================================

import sys, os, errno
import numpy as np
import pandas as pd
from datetime import datetime
    

# =============================================================================
# Helper function for processing the time string
# =============================================================================
def format_time(time_str):
    return datetime.strptime(time_str, '%Y-%m-%dT%H:%M:%S%z')    

# =============================================================================
# Beefy preprocessing function for pedometer data
# =============================================================================
#%%
def process_pedometer_data(window_length, window_overlap, num_windows, data_dir):
    '''
    Master function for the windowing and preprocessing of MHC pedometer data.
    
    Read in the pedometer data from the data_dir,
    and returns a pandas Series containing the number of steps for each window.
    
    Arguments:
        window_length: the length of each data window, 
        in hundredths of a second
        
        window_overlap: the data overlap, in hundredths of a second, 
        of a window with its subsequent window
        
        num_windows: the number of windows wanted (Could be calculated, but given as an arg to remove errors from bad timestamps)
    
        data_dir: which contains the path to a SINGLE
        file of gait acceleometry data from the MHC 2.0 dataset.
    '''
    
    #Convert window length and overlap to ms
    window_length *= 10
    window_overlap *= 10
    
    #Read in JSON
    raw_data = pd.read_json(data_dir)
    
    #Drop floors
    raw_data.drop(columns = ['floorsAscended', 'floorsDescended'], inplace = True)
    
    #Remap the timestamps to datetime objects
    raw_data['startDate'] = raw_data['startDate'].map(format_time)
    raw_data['endDate'] = raw_data['endDate'].map(format_time)
    
    #Find the time during the test
    raw_data = raw_data.assign(time = (raw_data['endDate'] - raw_data['startDate']))
    raw_data.drop(columns = ['startDate', 'endDate'], inplace = True)
    #Index by the time deltas
    raw_data.index = pd.TimedeltaIndex(raw_data['time'])
        
    #Drop time
    raw_data.drop(columns = 'time', inplace=True)
    #Remove any duplicate indicies
    raw_data = raw_data[~raw_data.index.duplicated()]
        
    #Resample with interpolation
    raw_data = raw_data.resample('1 s').interpolate(method='time')
    
        
    # total number of windows wanted (preinitialize for speed)
    window_steps = [0]*num_windows
    for i in range(num_windows):
        #Find the bounds of the window
        start_time = (window_length - window_overlap)*i
        end_time = start_time + window_length
        
        #Get the most recent step count before the time
        start_steps = raw_data[ : '{} ms'.format(start_time)].iloc[-1]['numberOfSteps'] 
        end_steps = raw_data[ : '{} ms'.format(end_time)].iloc[-1]['numberOfSteps']
        # FIGURE OUT A WAY TO HANDLE NO STEP ERRORS
        print('start time {} and end time {}'.format(start_time/1000, end_time/1000))
        print('For sample {} start is {} and end is {}'.format(i, start_steps, end_steps))
        
        window_steps[i] = max(end_steps - start_steps, 0) #Removes the negative from the first data point from time wrap around error

    #Return final window_steps
    result = pd.Series(window_steps)

    return result

#Test the function
if __name__ == "__main__":
    
    from process_data import process_data
    
    ped_data_file = r"C:\Users\dwubu\Documents\mhc\pedometer_walk_dir\ee621e22-c7c2-45dc-b22d-3a9c59fe6e78\2648577.0"
    walk_data_file = r"C:\Users\dwubu\Desktop\accel_walk_dir\ee621e22-c7c2-45dc-b22d-3a9c59fe6e78\2648617.0"
    
    ped_data = pd.read_json(ped_data_file)
    walk_data = pd.read_json(walk_data_file)
    walk_data_windows = process_data(500, 99, walk_data_file)
    
    def compare_ped_predictions(df, idx):
        '''
        A plotting function for comparing the pedometer predictions for a window
        and the acceleometry of the window
        '''
        import matplotlib.pyplot as plt
        plt.figure()
        plt.plot(df['xwindows'].iloc[idx], label='x');
        plt.plot(df['ywindows'].iloc[idx], label='y');
        plt.plot(df['zwindows'].iloc[idx], label='z');
        plt.legend(loc='upper left')
        plt.title('Prediction : {}'.format(df['steps'].iloc[idx]))
        
    compare_ped_predictions(walk_data_windows, 3)
    compare_ped_predictions(walk_data_windows, 10)
    compare_ped_predictions(walk_data_windows, 21)

