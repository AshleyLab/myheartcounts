# -*- coding: utf-8 -*-
"""
Created on Thu Dec 27 21:42:42 2018

Python script to be run on the sherlock cluster, which iterates through all 
the MHC 2.0 6 minute walk test dataset, and trains a model on it

Precondition: reads from an hdf5 file containing a 'data' group of shape
(num_samples, window_length, 3) containing all the windows.

Run process_data.py on the walk_data, then the rest_data
Change output_dir, walk_data_file, and rest_data_file vars below to point
at those files

CURRENTLY SHOWING STRANGE ERROR when run on cluster, no error locally
OSError: Can't read data (wrong B-tree signature)
Suspect file close error?

@author: Daniel Wu
"""
import os
import numpy as np
import pandas as pd
import h5py
import keras

from keras.models import Sequential
from keras.layers import Dense, Dropout, Flatten, Reshape, Input
from keras.layers import Conv1D, MaxPooling1D, GlobalAveragePooling1D


#Contains data for walk tests
output_dir = r"C:\Users\dwubu\Desktop" #"/scratch/users/danjwu/results"
walk_data_file = r"C:\Users\dwubu\Desktop\subset_data\data_windows.hdf5"#"/scratch/users/danjwu/6mwt_windows/data_windows.hdf5"
rest_data_file = r"C:\Users\dwubu\Desktop\subset_data\data_windows_rest.hdf5"#"/scratch/users/danjwu/6mwt_windows/data_windows_rest.hdf5"
            
# =============================================================================
# Data generator
# =============================================================================
class SixMWTSequence(keras.utils.Sequence):
    '''
    SixMWTSequence
    Extends keras inbuilt sequence to create a data generator
    Saves on RAM by loading data from hdf5 files in memory
    __del__ way of closing files isn't great - find a better way sometime
    '''
    def __init__(self, walk_data_path, rest_data_path, batch_size):
        #Open up files
        self.walk_file = h5py.File(walk_data_path, 'r')        
        self.rest_file = h5py.File(rest_data_path, 'r')
        self.walk_data = self.walk_file['data']
        self.rest_data = self.rest_file['data']
        
        self.batch_size = batch_size
        
        #Find the number of walk_data_points per batch
        self.num_walk_points = int((self.walk_data.shape[0]/(self.walk_data.shape[0] + self.rest_data.shape[0])) * self.batch_size)
        self.num_rest_points = self.batch_size - self.num_walk_points


    def __len__(self):
        #Find how many batches fit in our dataset
        #This "crops" out a couple datapoints not divisible by the batch at the end
        return min(
                int(self.walk_data.shape[0]/self.num_walk_points),
                int(self.rest_data.shape[0]/self.num_rest_points))

    def __getitem__(self, idx):
        
        #Grab the batch members
        batch_x = np.concatenate((self.walk_data[idx * self.num_walk_points : (idx + 1) * self.num_walk_points], 
                                  self.rest_data[idx * self.num_rest_points : (idx + 1) * self.num_rest_points]))

        #Generate the labels
        batch_y = np.concatenate(([1]*self.num_walk_points, [0]*self.num_rest_points))
        
        return batch_x, batch_y
    
    def __del__(self):
        self.walk_file.close()
        self.rest_file.close()
    

# =============================================================================
# Machine Learning Model        
# =============================================================================
 

model = Sequential()
# ENTRY LAYER
model.add(Conv1D(100, 20, activation='relu', input_shape=(200, 3)))
model.add(Conv1D(100, 20, activation='relu'))
model.add(MaxPooling1D(3))
model.add(Conv1D(160, 20, activation='relu'))
model.add(Conv1D(160, 20, activation='relu'))
model.add(GlobalAveragePooling1D())
model.add(Dropout(0.5))
model.add(Dense(40, activation='relu'))
model.add(Dense(1, activation='sigmoid'))
print(model.summary())


model.compile(loss='binary_crossentropy',
              optimizer='adam',
              metrics=['accuracy'])



# =============================================================================
# Training the model
# =============================================================================

batch_size = 16

training_batch_generator = SixMWTSequence(walk_data_file, rest_data_file, batch_size)
#VALIDATION IS TODO
#validation_batch_generator = SixMWTSequence(validation_filenames, validation_labels, batch_size)

num_training_samples = len(training_batch_generator)
num_validation_samples = 0
num_epochs = 20

model.fit_generator(generator=training_batch_generator,
                    steps_per_epoch=(num_training_samples // batch_size),
                    epochs=num_epochs,
                    verbose=1,
                    #validation_data=validation_batch_generator,
                    #validation_steps=(num_validation_samples // batch_size),
                    use_multiprocessing=True,
                    workers=16,
                    max_queue_size=32)

### Version with all data loaded into memory
#with h5py.File(walk_data_file, 'r') as walk_file:
#    with h5py.File(rest_data_file, 'r') as rest_file:
#        x_train = np.concatenate((walk_file['data'][:], rest_file['data'][:]), axis=0)
#        y_train = np.concatenate((np.array([1] * len(walk_file['data'][:])), np.array([0] * len(rest_file['data'][:]))))
#
#BATCH_SIZE = 32
#EPOCHS = 20
#
##Currently arbitrarily taking 521 walk points and 100 rest points as validation
##This is a bad split, but lazy
#history = model.fit(x_train[521:-100],
#                    y_train[521:-100],
#                    batch_size=BATCH_SIZE,
#                    epochs=EPOCHS,
#                    validation_split=0,
#                    validation_data=(np.concatenate((x_train[:521], x_train[-100:]), axis = 0), 
#                                     np.concatenate((y_train[:521], y_train[-100:]), axis = 0)))

model.save(os.path.join(output_dir, "model.h5"))