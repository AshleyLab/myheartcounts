# -*- coding: utf-8 -*-
"""
Created on Wed Dec  5 21:18:13 2018

Walking Classifier
A simple 1D Convolutional Neural Network for classifying whether
triaxial acceleometry data represents walking or not. 

Great resource:
https://blog.goodaudience.com/introduction-to-1d-convolutional-neural-networks-in-keras-for-time-sequences-3a7ff801a2cf

@author: dwubu
"""

from matplotlib import pyplot as plt
import numpy as np
import pandas as pd
import os

from sklearn import metrics
from sklearn import preprocessing

from keras.models import Sequential
from keras.layers import Dense, Dropout, Flatten, Reshape, Input, LSTM
from keras.layers import BatchNormalization, Activation
from keras.layers import Conv1D, MaxPooling1D, GlobalAveragePooling1D

# =============================================================================
# Import File Data and assemble dataset
# =============================================================================

def makeDatasets(window_directory_str):
    '''makeDatasets
    Reads in files to a dataset
    Returns a single dataframe containing all x, y, and z windows of the files
    '''
    all_data = []

    for filename in os.listdir(window_directory_str):
        
        window_directory = os.fsencode(window_directory_str)
        
        #Read in the hdf of each file, add it to the dataframe - viable for small datasets
        filepath = os.path.join(window_directory.decode(), filename)
        data = pd.read_hdf(filepath)
        for index, series in data.iterrows():
            window = [series['xwindows'], series['ywindows'], series['zwindows']]
            
            #Reshape to size (window_length, 3)
            window = np.swapaxes(window, 0, 1)
            #Normalize between 0 and 1
            #window = preprocessing.MinMaxScaler().fit_transform(window)            
            #Add to complete data container
            all_data.append(window)
    
    return np.asarray(all_data)

# =============================================================================
# Load in the data
# =============================================================================

#Get the walk data
data_dir = r'C:/Users/dwubu/Desktop/6mwtInhouseFiltered/Walk'
#data_dir = r'C:/Users/dwubu/Desktop/6mwtInhouseWindows/Walk' #Unfiltered
walk_data = makeDatasets(data_dir)

#Get the rest data
data_dir = r'C:/Users/dwubu/Desktop/6mwtInhouseFiltered/Rest'
#data_dir = r'C:/Users/dwubu/Desktop/6mwtInhouseWindows/Rest' #Unfiltered
rest_data = makeDatasets(data_dir)

#DUMMY REST DATA
#rest_data = np.random.rand(1000, 200, 3)
#for i in range(len(rest_data)):
#    rest_data[i] = preprocessing.MinMaxScaler().fit_transform(rest_data[i])

x_train = np.concatenate((walk_data, rest_data), axis=0)
y_train = np.concatenate((np.array([1] * len(walk_data)), np.array([0] * len(rest_data))))

# =============================================================================
# Define Model Architecture        
# =============================================================================
 
model = Sequential()
#Apparently there's a paper that says BatchNormalization is best before activation
model.add(Conv1D(100, 10, input_shape=(200, 3)))
model.add(BatchNormalization())
model.add(Activation('relu'))

#OLD MODEL which overfits
#model.add(Conv1D(100, 10, activation='relu', input_shape=(200, 3)))
#model.add(Conv1D(100, 10, activation='relu'))
#model.add(MaxPooling1D(3))

#model.add(Conv1D(160, 10, activation='relu'))
#model.add(Conv1D(160, 10, activation='relu'))

model.add(GlobalAveragePooling1D())
model.add(Dropout(0.8))
#Output layer - 0 is resting, 1 is walking
model.add(Dense(1, activation='sigmoid'))
print(model.summary())


model.compile(loss='binary_crossentropy',
              optimizer='adam',
              metrics=['accuracy'])

BATCH_SIZE = 32
EPOCHS = 20

#Currently arbitrarily taking 521 walk points and 100 rest points as validation
#This is a bad split, but lazy
history = model.fit(x_train[521:-100],
                    y_train[521:-100],
                    batch_size=BATCH_SIZE,
                    epochs=EPOCHS,
                    validation_split=0,
                    validation_data=(np.concatenate((x_train[:521], x_train[-100:]), axis = 0), 
                                     np.concatenate((y_train[:521], y_train[-100:]), axis = 0)))
#%%
# =============================================================================
# Plot Training History
# =============================================================================
plt.plot(history.history['loss'])
plt.plot(history.history['val_loss'])
plt.title('Model Loss')
plt.ylabel('Loss')
plt.xlabel('Epoch')
plt.legend(['train', 'test'], loc='upper left')
plt.show()