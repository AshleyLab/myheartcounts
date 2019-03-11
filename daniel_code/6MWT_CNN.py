# -*- coding: utf-8 -*-
"""
Created on Mon Feb 25 11:32:33 2019
6mwt CNN

Reads in a labelled dataset and a result table, and trains a CNN on the data

@author: dwubu
"""

import os
import numpy as np
import pandas as pd
import h5py
import keras
import threading
import math

from keras.models import Sequential
from keras.layers import Dense, Dropout, Flatten, Reshape, Input, BatchNormalization
from keras.layers import Conv1D, MaxPooling1D, GlobalAveragePooling1D
from keras.callbacks import ReduceLROnPlateau


#SET TO TRUE WHEN RUNNING ON SHERLOCK
on_sherlock = False

#Contains data for walk tests
if(on_sherlock):
    output_dir = "/scratch/PI/euan/projects/mhc/code/daniel_code/results"
    walk_data_file = "/scratch/PI/euan/projects/mhc/code/daniel_code/6mwt_windows/data_windows.hdf5"
    rest_data_file = "/scratch/PI/euan/projects/mhc/code/daniel_code/6mwt_windows/data_windows_rest.hdf5"
else:
    output_dir = r"C:\Users\dwubu\Desktop"
    walk_data_file = r"C:\Users\dwubu\Desktop\subset_data\data_windows.hdf5"
    rest_data_file = r"C:\Users\dwubu\Desktop\subset_data\data_windows_rest.hdf5"

# =============================================================================
# Split data files into validation and test
# =============================================================================
validation_split = 0.4

def split_data(file_path, split, new_folder):
    '''
    split_data(file_path, split)
    splits the data in the 'data' dataset of the hdf file at filepath
    with the given split ratio, between 0 and 1.
    Uses new_folder in the new filepath
    Returns a tuple with two filenames, the first with (1-split), the second with (split) percent of the data
    '''
    with h5py.File(file_path, 'r') as hdf_file:
        data = hdf_file['data']
        (num_samples, window_len, channels) = data.shape
        
        split_num = math.floor(num_samples * split)
        
        #Open and save the valdation set
        out_dir = os.path.join(os.path.dirname(file_path), new_folder)
        validation_path = os.path.join(out_dir, "validation.hdf5")
        
        with h5py.File(validation_path, 'w') as validation_file:
            validation_file.create_dataset('data', 
                                           (split_num, 
                                           window_len, 
                                           channels)
                                          )
                                           
            #validation_file['data'][:] = data[:split_num]
            for i in range(split_num):
                validation_file['data'][i] = data[i]
        
        #Open and save the test set
        test_path = os.path.join(out_dir, "test.hdf5")
        
        with h5py.File(test_path, 'w') as test_file:
            test_file.create_dataset('data', 
                                      (num_samples - split_num, 
                                      window_len, 
                                      channels)
                                     )
            #test_file['data'][:] = data[split_num : ]
            for i in range(split_num, num_samples):
                test_file['data'][i - split_num] = data[i]
                
        
        return (test_path, validation_path)
        


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
        self.lock = threading.Lock()
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
        
        with self.lock:
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
model.add(BatchNormalization())

#model.add(Conv1D(100, 20, activation='relu'))
#model.add(BatchNormalization())
model.add(MaxPooling1D(3))

#model.add(Conv1D(160, 20, activation='relu'))
#model.add(BatchNormalization())

model.add(Conv1D(160, 20, activation='relu'))
model.add(BatchNormalization())
model.add(GlobalAveragePooling1D())

model.add(Dropout(0.5))
model.add(Dense(40, activation='relu'))
model.add(BatchNormalization())

model.add(Dense(1, activation='sigmoid'))
print(model.summary())


#Loss function - taken from kerasAC.custom_losses  -   need to figure out weights before using
#def get_weighted_binary_crossentropy(w0_weights, w1_weights):
#    import keras.backend as K
#    # Compute the task-weighted cross-entropy loss, where every task is weighted by 1 - (fraction of non-ambiguous examples that are positive)
#    # In addition, weight everything with label -1 to 0
#    w0_weights=np.array(w0_weights);
#    w1_weights=np.array(w1_weights);
#    thresh=-0.5
#
#    def weighted_binary_crossentropy(y_true,y_pred):
#        weightsPerTaskRep = y_true*w1_weights[None,:] + (1-y_true)*w0_weights[None,:]
#        nonAmbig = K.cast((y_true > -0.5),'float32')
#        nonAmbigTimesWeightsPerTask = nonAmbig * weightsPerTaskRep
#        return K.mean(K.binary_crossentropy(y_pred, y_true)*nonAmbigTimesWeightsPerTask, axis=-1);
#    return weighted_binary_crossentropy; 

if(on_sherlock):
    from concise.metrics import tpr, tnr, fpr, fnr, precision, f1
    model_metrics = ['accuracy',tpr,tnr,fpr,fnr,precision,f1]
else:
    model_metrics = ['accuracy']

model.compile(loss='binary_crossentropy',
              optimizer='adam',
              metrics=model_metrics)


# =============================================================================
# Training the model
# =============================================================================


batch_size = 16

#Split the dataset
(walk_train, walk_validation) = split_data(walk_data_file, validation_split, 'walk')
(rest_train, rest_validation) = split_data(rest_data_file, validation_split, 'rest')


training_batch_generator = SixMWTSequence(walk_train, rest_train, batch_size)
validation_batch_generator = SixMWTSequence(walk_validation, rest_validation, batch_size)

num_training_samples = len(training_batch_generator)
num_validation_samples = len(validation_batch_generator)
num_epochs = 50

#Callbacks
reduce_lr = ReduceLROnPlateau(monitor='val_loss', factor=0.2,
                              patience=5, min_lr=0.001)

history = model.fit_generator(generator=training_batch_generator,
                              steps_per_epoch=(num_training_samples // batch_size),
                              epochs=num_epochs,
                              verbose=1,
                              callbacks = [reduce_lr],
                              validation_data=validation_batch_generator,
                              validation_steps=(num_validation_samples // batch_size),
                              use_multiprocessing=False, #Windows must be False, else true
                              workers=8,
                              max_queue_size=32)

#Clean up the temp files
del training_batch_generator
del validation_batch_generator
os.remove(walk_train)
os.remove(rest_train)
os.remove(walk_validation)
os.remove(rest_validation)

model.save(os.path.join(output_dir, "model.h5"))