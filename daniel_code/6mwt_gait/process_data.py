# -*- coding: utf-8 -*-
"""
Created on Thu Dec 27 21:31:07 2018

Provides a single function, process_data, which does all the data preprocessing

Unifies the contents of make_windows.py, filter_windows.py, and butterworth.py

@author: dwubu
"""
# =============================================================================
# Import dependencies
# =============================================================================

import sys, os, errno
import numpy as np
import itertools as it
import h5py
import pandas as pd
from scipy.signal import butter, lfilter
    
# =============================================================================
# Change these vars
# =============================================================================

#Raw acceleometry data to read
in_directory = r"C:\Users\dwubu\Desktop\accel_rest_dir" #r"/scratch/PI/euan/projects/mhc/data/6mwt/accel_walk_dir"

#Place to save final data
out_directory = r"C:\Users\dwubu\Desktop\subset_data" #r"/scratch/users/danjwu/6mwt_windows
filename = "data_windows_rest.hdf5"

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
    
def moving_window(accelx, length, overlap, step=1):
    streams = it.tee(accelx, length)
    return zip(*[it.islice(stream, i, None, step + overlap) for stream, i in zip(streams, it.count(step=step))])

def normalize_dataset(dataframe):
    return (dataframe - dataframe.mean())

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

    #Return final dataframe
    df = pd.DataFrame({'healthCode': os.path.basename(os.path.normpath(data_dir)), 
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
            
#Process and save ~200GB of data to personal $SCRATCH
#The resulting hdf5 file is 6.8 GB, containing roughly 8100 6mwts
if __name__ == "__main__":
    

    
    #Length of window, in hundredths of seconds
    window_length = 200
    #overlap of subsequent windows, in hundredths of seconds
    window_overlap = 99
    
    #Initialize an hdf5 file to write to
    with h5py.File(os.path.join(out_directory, filename), 'w') as hdf:
        #dataset contains data of size (samples, window_length, num_dims)
        hdf_data = hdf.create_dataset('data', (1, window_length, 3),  maxshape=(None, window_length, 3))
    
        
        for dirpath, dirnames, filename in os.walk(in_directory):
            i = 0
            for file in filename:
                #Commented out - on local storage, I put all the files in one place, so i want multiple files from the same folder
                #df = process_data(window_length, window_overlap, os.path.join(dirpath, file))
                #save_data(hdf_data, df)
                while (i < 1):
                    #For sherlock cluster - get one test per healthcode
            # this is so that there is only one file per healthCode
                    df = process_data(window_length, window_overlap, os.path.join(dirpath, file))
                    save_data(hdf_data, df)
                    i += 1
                                
        #Whoops we added an extra empty space for a window, trim it and close the file
        hdf_data.resize(hdf_data.shape[0] - 1, axis = 0)
        hdf.close()