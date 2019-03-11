# -*- coding: utf-8 -*-
"""
Created on Sun, March 3rd, 2019

Provides a single function, process_data, which does the data preprocessing
Built to read the jsons in walk_data_dir

Unifies the contents of make_windows.py, filter_windows.py, butterworth.py

Creates an HDF file organized by healthcode datasets containing windows

@author: Daniel Wu
"""
# =============================================================================
# Import dependencies
# =============================================================================

import sys, os, errno
import numpy as np
import itertools as it
import h5py
import pandas as pd
from datetime import datetime
from scipy.signal import butter, lfilter
    
# =============================================================================
# Change these vars
# =============================================================================

on_sherlock = False
want_pedometer_data = False

#Raw acceleometry data to read
if(on_sherlock):
    in_directory = r"/scratch/PI/euan/projects/mhc/data/6mwt/accel_walk_dir"
    out_directory = r"/scratch/PI/euan/projects/mhc/code/daniel_code"

else:
    in_directory = r"C:\Users\dwubu\Desktop\accel_walk_dir"
    out_directory = r"C:\Users\dwubu\Desktop\subset_data" 
    
#Place to save final data
filename = "data_windows_walk.hdf5"


# =============================================================================
# Helper functions for applying the lowpass filter
# =============================================================================

def butter_lowpass(lowcut, fs, order=5):
    nyq = 0.5 * fs
    low = lowcut / nyq
    b, a = butter(order, low, btype='low')
    return b, a


def butter_lowpass_filter(data, lowcut, fs, order=5):
    b, a = butter_lowpass(lowcut, fs, order=order)
    y = lfilter(b, a, data)
    return y

# =============================================================================
# Helper functions for data slicing and normalization
# =============================================================================
    
#def moving_window(accelx, length, overlap, step=1):
#    streams = it.tee(accelx, length)
#    return zip(*[it.islice(stream, i, None, step + overlap) for stream, i in zip(streams, it.count(step=step))])

def moving_window(data, length, overlap):
    shape = (data.size - length + 1, length)
    strides = data.strides * 2
    view = np.lib.stride_tricks.as_strided(data, shape=shape, strides=strides)[0::length - overlap]
    return view.copy()


def normalize_dataset(dataframe):
    return (dataframe - dataframe.mean())

# =============================================================================
# PEDOMETER - Unused
# =============================================================================

# =============================================================================
# Helper function for processing the time string
# =============================================================================
def format_time(time_str):
    return datetime.strptime(time_str, '%Y-%m-%dT%H:%M:%S%z')    

# =============================================================================
# Beefy preprocessing function for pedometer data
# =============================================================================
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
    
    # total number of windows wanted (preinitialize for speed)
    window_steps = [0]*num_windows
    for i in range(num_windows):
        #Find the bounds of the window
        start_time = (window_length - window_overlap)*i
        end_time = start_time + window_length
        
        #Convert to ms
        start_time *= 10
        end_time *= 10
        
        #Get the most recent step count before the time
        start_steps = raw_data[ : '{} ms'.format(start_time)].iloc[-1]['numberOfSteps'] 
        end_steps = raw_data[ : '{} ms'.format(end_time)].iloc[-1]['numberOfSteps']
        # FIGURE OUT A WAY TO HANDLE NO STEP ERRORS
        
        window_steps[i] = max(end_steps - start_steps, 0) #Removes the negative from the first data point from time wrap around error

    #Return final window_steps
    result = pd.Series(window_steps)

    return result

# =============================================================================
# Beefy preprocessing function
# =============================================================================

def process_data(window_length, window_overlap, data_dir):
    '''
    Master function for the windowing and preprocessing of MHC acceleometry data.
    
    Chops data into windows of specified window_length and window_overlap
    from the data_dir, and returns a pandas dataframe containing the windows.
    
    Arguments:
        window_length: the length of each data window, 
        in hundredths of a second
        
        window_overlap: the data overlap, in hundredths of a second, 
        of a window with its subsequent window
    
        data_dir: which contains the path to a SINGLE
        file of gait acceleometry data from the MHC 2.0 dataset.
    '''
    
    #Read in JSON
    raw_data = pd.read_json(data_dir).set_index('timestamp')
    
    #Process the user-generated acceleometry data
    #Put into array form
    x = np.asarray(raw_data.x)
    y = np.asarray(raw_data.y)
    z = np.asarray(raw_data.z)
        
    #Make Windows
    x_ = list(moving_window(x, window_length, window_overlap))
    y_ = list(moving_window(y, window_length, window_overlap))
    z_ = list(moving_window(z, window_length, window_overlap))
    
    #Apply Butterworth Lowpass
    lowcut = 5
    fs = 100
    for i in range(len(x_)):
        x_[i] = butter_lowpass_filter(x_[i], lowcut, fs)
        y_[i] = butter_lowpass_filter(y_[i], lowcut, fs)
        z_[i] = butter_lowpass_filter(z_[i], lowcut, fs)
        
    #Healthcode is the directory name
    healthCode = data_dir.split(os.sep)[-2]
    #Embed pedometer data
    if(want_pedometer_data):
        #Calculate pedometer steps
        step_data = process_pedometer_data(window_length, window_overlap, len(x_), ped_directory)   #WHAT IS PEDOMETER DIR
    
        #Define final dataframe
        df = pd.DataFrame({'healthCode': healthCode, 
                           'xwindows': x_, 'ywindows': y_, 'zwindows': z_, 'steps': step_data}, columns=['healthCode', 'xwindows', 
                           'ywindows', 'zwindows', 'steps']).set_index('healthCode')
    else:
        #Define final dataframe
        df = pd.DataFrame({'healthCode': healthCode, 
                           'xwindows': x_, 'ywindows': y_, 'zwindows': z_}, columns=['healthCode', 'xwindows', 
                           'ywindows', 'zwindows']).set_index('healthCode')
        
    return df

def save_data(hdf_dataset, df):
    '''Takes a dataframe df containing 'xwindows', 'ywindows', 'zwindows'
       properties which contain acceleometry data.
       Saves these windows in hdf_dataset, an open h5py File.dataset.
    '''
    #Go through each window in the dataframe
    for index, series in df.iterrows():
        #Isolate a nparray of just the x, y, z, acceleometry of size (3, window_length)
        window = np.swapaxes([series['xwindows'], series['ywindows'], series['zwindows']], 0, 1)
        print("saving window number {}".format(hdf_dataset.shape[0] - 1))
        hdf_dataset[hdf_dataset.shape[0] - 1,:,:] = window
        hdf_dataset.resize((hdf_dataset.shape[0] + 1), axis = 0)
        hdf_dataset.flush()
            
##Process and save ~200GB of data to $SCRATCH
##The resulting hdf5 file is 6.8 GB, containing roughly 8100 6mwts
if __name__ == "__main__":
    
    #Length of window, in hundredths of seconds
    window_length = 200
    #overlap of subsequent windows, in hundredths of seconds
    window_overlap = 99
    
    #Initialize an hdf5 file to write to
    with h5py.File(os.path.join(out_directory, filename), 'w') as hdf:
        #dataset contains data of size (samples, window_length, num_dims)
        
        
        for dirpath, dirnames, filename in os.walk(in_directory):
            i = 0
            for file in filename:

                
                #Commented out - on local storage, I put all the files in one place, so i want multiple files from the same folder
                #df = process_data(window_length, window_overlap, os.path.join(dirpath, file))
                #save_data(hdf_data, df)
                
                while (i < 1):
                                    
                    healthCode = dirpath.split(os.sep)[-1]
                    print("Processing healthcode {}".format(healthCode))
                    
                    hdf_data = hdf.create_dataset(healthCode, (1, window_length, 3),  maxshape=(None, window_length, 3))
                    
                    #For sherlock cluster - get one test per healthcode
                    df = process_data(window_length, window_overlap, os.path.join(dirpath, file))
                    save_data(hdf_data, df)
                    i += 1
                                
                    #Whoops we added an extra empty space for a window, trim it and close the file
                    hdf_data.resize(hdf_data.shape[0] - 1, axis = 0)