# -*- coding: utf-8 -*-
"""
Created on Sun Nov  4 19:10:34 2018

Extracts valid windows from 6mwt data
Passes data through a butterworth lowpass filter

@author: dwubu
"""
import os
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt

def hann(window):
    '''
    hann
    Applies a hanning window function to the passed vector
    '''
    return np.hanning(len(window))*window

def ihann(window):
    '''
    hann
    Inverts the hanning window function to the passed vector
    '''
    return window/np.hanning(len(window))


# =============================================================================
# Functions for applying the bandpass filter
# =============================================================================

from butterworth import butter_bandpass_filter, butter_lowpass_filter

#%%
# =============================================================================
# Begin Main
# =============================================================================

window_directory_str = 'C:/Users/dwubu/Desktop/6mwtInhouseWindows/Rest'
window_directory = os.fsencode(window_directory_str)

final_directory = 'C:/Users/dwubu/Desktop/6mwtInhouseFiltered/Rest'



for filename in os.listdir(window_directory):
    
    #Read in the hdf of each file
    filepath = os.path.join(window_directory.decode(), filename.decode())
    data = pd.read_hdf(filepath)
    
    x_ = []
    y_ = []
    z_ = []
    
    for index, series in data.iterrows():
        #For each window
        x = series['xwindows']
        y = series['ywindows']
        z = series['zwindows']
        
        #Apply Butterworth lowpass
        lowcut = 5
        fs = 100
        x = butter_lowpass_filter(x, lowcut, fs)
        y = butter_lowpass_filter(y, lowcut, fs)
        z = butter_lowpass_filter(z, lowcut, fs)
        
        x_.append(x)
        y_.append(y)
        z_.append(z)

    # =============================================================================
    # Saving to a file
    # =============================================================================

    if not os.path.exists(final_directory):          
        os.makedirs(final_directory)
    
    df = pd.DataFrame({'healthCode': index, 
                       'xwindows': x_, 'ywindows': y_, 'zwindows': z_}, columns=['healthCode', 'xwindows', 
                        'ywindows', 'zwindows']).set_index('healthCode')
    
    df.to_hdf(final_directory + '/' + os.path.splitext(filename)[0].decode() +'.h5', key='df', mode='w')

#%%
# =============================================================================
# Take a closer look at the data
# =============================================================================
#print(index)
#print("=====================================================================")
##Print original data    
#plt.figure()
#plt.title("Original Data")
#plt.plot(series['xwindows'], label = 'x')
#plt.plot(series['ywindows'], label = 'y')
#plt.plot(series['zwindows'], label = 'z') 
#plt.legend()   
#plt.show()
#
#
#
##Extract data
#x = series['xwindows']
#y = series['ywindows']
#z = series['zwindows']
#
#unfilteredEuclidean = np.sqrt(np.power(x, 2) + np.power(y, 2) + np.power(z,2))
#
#
##Apply Butterworth lowpass
#lowcut = 5
#fs = 100
#x = butter_lowpass_filter(x, lowcut, fs)
#y = butter_lowpass_filter(y, lowcut, fs)
#z = butter_lowpass_filter(z, lowcut, fs)
#
#plt.figure()
#plt.title("Butterworth Filtered")
#plt.plot(x, label = 'x')
#plt.plot(y, label = 'y')
#plt.plot(z, label = 'z')
#euclidean = np.sqrt(np.power(x, 2) + np.power(y, 2) + np.power(z,2))
#plt.plot(euclidean, label = 'euclidean')
#plt.legend()
#plt.show()
#
#
#plt.figure()
#plt.title("Euclidean Distance Comparison")
#euclidean = np.sqrt(np.power(x, 2) + np.power(y, 2) + np.power(z,2))
#plt.plot(unfilteredEuclidean, label='unfiltered')
#plt.plot(euclidean, label='filtered')
#plt.legend()
#plt.show()

    #Frequency transformed data, hann windowed
#x = np.fft.fft(hann(x))
#y = np.fft.fft(hann(y))
#z = np.fft.fft(hann(z))
#
#plt.figure()
#plt.title("FFT Transform")
#plt.plot(abs(x[1:]), label = 'x')
#plt.plot(abs(y[1:]), label = 'y')
#plt.plot(abs(z[1:]), label = 'z')
#plt.legend()
#plt.show()



#plt.figure()
#plt.title("Inverse Transform")
#plt.plot(abs(np.fft.ifft(x)))
#plt.plot(abs(np.fft.ifft(y)))
#plt.plot(abs(np.fft.ifft(z)))
#plt.show()

#final_data = pd.Dataframe
