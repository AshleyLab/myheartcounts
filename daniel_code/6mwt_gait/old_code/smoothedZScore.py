# -*- coding: utf-8 -*-
"""
Created on Sat Nov 24 19:45:45 2018

Finds significant local maxima in time series, returns an array of the time points
Based on StackExchange

@author: dwubu
"""

# Implementation of algorithm from https://stackoverflow.com/a/22640362/6029703
import numpy as np
import pylab

def thresholding_algo(y, lag, threshold, influence):
    signals = np.zeros(len(y))
    filteredY = np.array(y)
    avgFilter = [0]*len(y)
    stdFilter = [0]*len(y)
    avgFilter[lag - 1] = np.mean(y[0:lag])
    stdFilter[lag - 1] = np.std(y[0:lag])
    for i in range(lag, len(y)):
        if abs(y[i] - avgFilter[i-1]) > threshold * stdFilter [i-1]:
            if y[i] > avgFilter[i-1]:
                signals[i] = 1
            else:
                signals[i] = -1

            filteredY[i] = influence * y[i] + (1 - influence) * filteredY[i-1]
            avgFilter[i] = np.mean(filteredY[(i-lag+1):i+1])
            stdFilter[i] = np.std(filteredY[(i-lag+1):i+1])
        else:
            signals[i] = 0
            filteredY[i] = y[i]
            avgFilter[i] = np.mean(filteredY[(i-lag+1):i+1])
            stdFilter[i] = np.std(filteredY[(i-lag+1):i+1])

    return dict(signals = np.asarray(signals),
                avgFilter = np.asarray(avgFilter),
                stdFilter = np.asarray(stdFilter))
    
    
    
def findPeaks(data):
    '''
    My original function to produce a vector of positive extreme locations
    '''
    # Settings: lag = 30, threshold = 4, influence = 0
    lag = 30
    threshold = 4
    influence = 0
    
    # Run algo with settings from above
    result = thresholding_algo(data, lag=lag, threshold=threshold, influence=influence)
    
    filteredData = result["signals"]
    
    maxima = []
    
    for i in range(len(filteredData) - 1):
        #Check if this is the first i
        if filteredData[i] == 0 and abs(filteredData[i+1]) == 1:
            maxima.append(i + 1)
            
    return maxima
    
#DEMO
if __name__ == "__main__":
     
    # Data
    #y = np.array([1,1,1.1,1,0.9,1,1,1.1,1,0.9,1,1.1,1,1,0.9,1,1,1.1,1,1,1,1,1.1,0.9,1,1.1,1,1,0.9,
    #       1,1.1,1,1,1.1,1,0.8,0.9,1,1.2,0.9,1,1,1.1,1.2,1,1.5,1,3,2,5,3,2,1,1,1,0.9,1,1,3,
    #       2.6,4,3,3.2,2,1,1,0.8,4,4,2,2.5,1,1,1])
    
    
    window_directory_str = 'C:/Users/dwubu/Desktop/6mwtWindows'
    window_directory = os.fsencode(window_directory_str)
    
    
    for filename in os.listdir(window_directory):
        
        #Read in the hdf of each file
        filepath = os.path.join(window_directory.decode(), filename.decode())
        data = pd.read_hdf(filepath)
        
        
        #Indent later to do more than one data file    
        for index, series in data.iterrows():
            #For each window
            pass
        
# =============================================================================
#         Set data metric
# =============================================================================
        #y = series['zwindows']
        #Testing euclidean
        y = np.sqrt(np.power(x, 2) + np.power(y, 2) + np.power(z,2))
    
    
    
    # Settings: lag = 30, threshold = 5, influence = 0
    lag = 30
    threshold = 4
    influence = 0
    
    # Run algo with settings from above
    result = thresholding_algo(y, lag=lag, threshold=threshold, influence=influence)
        
    #plot algorithm
    plt.figure()
    plt.plot(np.arange(1, len(y)+1), y, label='data')
    plt.plot(np.arange(1, len(y)+1),
                   result["avgFilter"], label='avg filter')
        
    plt.plot(np.arange(1, len(y)+1),
                   result["avgFilter"] + threshold * result["stdFilter"], color="green")
        
    plt.plot(np.arange(1, len(y)+1),
               result["avgFilter"] - threshold * result["stdFilter"], color="green")
    plt.legend()
    plt.title('z-score smoothing')
    
    #Plot signals
    plt.figure()
    plt.step(np.arange(1, len(y)+1), result["signals"])
    plt.title('Signals')
    plt.ylim(-1.5, 1.5)

    #Plot only first point of positive peaks
    filteredData = [0]*len(y)
    peaks = findPeaks(y)
    
    for i in range(len(y)):
        if i in peaks:
            filteredData[i] = 1
        
    pylab.figure()
    pylab.step(np.arange(1, len(y)+1), filteredData, color="red", lw=2)
    pylab.show()
