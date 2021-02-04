# -*- coding: utf-8 -*-
"""
Created on Sun Mar  3 21:26:35 2019

Python script to be run on the sherlock cluster, which iterates through selected healthcodes in 
the MHC 2.0 6 minute walk test dataset, and trains a model on it

Precondition: reads from an hdf5 file containing groups labeled by healthcode of shape
(num_samples, window_length, 3) containing all the windows from that healthcode.

Run preprocess_data.py on the walk_data, and extract_filter_data.py on the resulting data file
Change output_dir, data_file vars below to point at those files

TODO:
    Make this work with local filepaths
    implement class weights
    play around with model architecture
    Speed up training - overhead is load/strs
    hyperparameter tuning

@author: Daniel Wu
"""
import os
import numpy as np
import pandas as pd
import h5py
import keras
import threading
import pickle
import random

from keras.models import Sequential
from keras.layers import Dense, Dropout, Flatten, Reshape, Input, BatchNormalization
from keras.layers import Conv1D, MaxPooling1D, GlobalAveragePooling1D
from keras.callbacks import ReduceLROnPlateau, EarlyStopping, TensorBoard

from sklearn.utils import class_weight

# =============================================================================
# PARAMETERS
# =============================================================================
labels_of_interest = ["heartAgeDataGender"]  #["heartCondition"]

#File locations
output_dir = "/scratch/PI/euan/projects/mhc/code/daniel_code/results"
label_table_file = "/scratch/PI/euan/projects/mhc/code/daniel_code/combined_health_label_table.pkl"
train_data_path = r"/scratch/PI/euan/projects/mhc/code/daniel_code/filtered_windows/filtered_train.hdf5"
val_data_path = r"/scratch/PI/euan/projects/mhc/code/daniel_code/filtered_windows/filtered_validation.hdf5"

#Training metrics
from concise.metrics import tpr, tnr, fpr, fnr, precision, f1
model_metrics = ['accuracy',tpr,tnr,fpr,fnr,precision,f1]

#Training parameters
batch_size = 256
canMultiprocess = False

# =============================================================================
# Data generator
# =============================================================================
def extract_labels(labels, label_table_path):
    '''
    Returns a dataframe indexed by healthCodes with columns of requested labels
    taken from the label table file
    '''
    label_df = pickle.load(open(label_table_path, 'rb')) 
    label_df = label_df[labels]
    return label_df.dropna()

def parse_label(code, label_df):
    """
    Helper function that parses the labels on survey data for a given code
    """
    if labels_of_interest == ["heartCondition"]:
        text_label = label_df.loc[code]
        
        #textlabel for heartCondition is a True False boolean
        if text_label.bool():
            return 1
        else:
            return 0
        
    if labels_of_interest == ["heartAgeDataGender"]:
        
        text_label = label_df.loc[code]
        
        #heartAgeDataGender is a string '["HKBiologicalSex[fe]?male"]'
        #Not sure how to handle "other" right now - return 0.5? Assume 50/50 for now
        if text_label[0] == '["HKBiologicalSexMale"]':
            return 1
        elif text_label[0] == '["HKBiologicalSexFemale"]':
            return 0
        else:
            print("Uh-oh, there's a weird gender: {}".format(text_label[0]))
            return random.randint(0,1)
        
        
    

class SixMWTSequence(keras.utils.Sequence):
    '''
    SixMWTSequence
    Extends keras inbuilt sequence to create a data generator
    Saves on RAM by loading data from hdf5 files in memory
    __del__ way of closing files isn't great - find a better way sometime
    '''
    def __init__(self, data_file, batch_size, label_df):
        #Open up file
        self.lock = threading.Lock()
        self.file = data_file
        
        #Track labels and batch size
        self.labels = label_df
        self.batch_size = batch_size
        
        #Calculate length of points - len is too memory intensive
        self.num_data = 0
        for code in self.file.keys():
            self.num_data += 1
            
        #Partition the dataset into batches
        self.length = self.num_data // self.batch_size

    def __len__(self):
        #Find how many batches fit in our dataset
        #This "crops" out a couple datapoints not divisible by the batch at the end
        return self.length

    def __getitem__(self, idx):
        
        with self.lock:
            
            #Get the batch members
            batch_x = [self.file[str(i)][:] for i in range(idx*self.batch_size, (idx + 1)*self.batch_size)]
            batch_y = [parse_label(self.file[str(i)].attrs["healthCode"], self.labels) for i in range(idx*self.batch_size, (idx + 1)*self.batch_size)]
   
            #Convert to array
            batch_x = np.asarray(batch_x)
            batch_y = np.asarray(batch_y)
            
            return batch_x, batch_y
        
#    def __del__(self):
        #self.file.close()    

# =============================================================================
# Defining the CNN
# =============================================================================

model = Sequential()
# ENTRY LAYER
model.add(Conv1D(100, 20, activation='relu', input_shape=(200, 3)))
model.add(BatchNormalization())

model.add(Conv1D(100, 20, activation='relu'))
model.add(BatchNormalization())
model.add(MaxPooling1D(3))

model.add(Conv1D(160, 20, activation='relu'))
model.add(BatchNormalization())

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



#Define optimizer
adam = keras.optimizers.Adam(lr=0.01) #Default is 0.001

model.compile(loss='binary_crossentropy',
              optimizer=adam,
              metrics=model_metrics)

# =============================================================================
# Training the model
# =============================================================================


label_df = extract_labels(labels_of_interest, label_table_file)

print("Loading filtered data")
with h5py.File(train_data_path, 'r') as filtered_train_file, h5py.File(val_data_path, 'r') as filtered_validation_file:
    
    training_batch_generator = SixMWTSequence(filtered_train_file, batch_size, label_df)
    validation_batch_generator = SixMWTSequence(filtered_validation_file, batch_size, label_df)
    
    num_training_samples = len(training_batch_generator)
    num_validation_samples = len(validation_batch_generator)
    print("There are {} training samples and {} validation samples".format(num_training_samples, num_validation_samples))
    
    num_epochs = 1000
    
    #Calculate class weights from 100 batches
    temp = np.array([])
    num_smpls = min(100, len(training_batch_generator))
    rand_idxs = random.sample(list(range(len(training_batch_generator))), num_smpls)
    for batch_num in rand_idxs:
        _, temp_y = training_batch_generator[batch_num]
        temp = np.concatenate((temp, temp_y))
    class_weights = dict(enumerate(class_weight.compute_class_weight('balanced',
                                                     np.unique(temp),
                                                     temp)))
    
    print("Our class weights are {}".format(class_weights))
    
    #Callbacks
    reduce_lr = ReduceLROnPlateau(monitor='val_loss', factor=0.2,
                                  patience=5, min_lr=1e-7)
    
    early_stop = EarlyStopping(patience=7)
    
    tb = TensorBoard(log_dir=os.path.join(output_dir, 'logs'))
    
    history = model.fit_generator(generator=training_batch_generator,
                                  epochs=num_epochs,
                                  verbose=2,
                                  callbacks = [reduce_lr, early_stop, tb],
                                  validation_data=validation_batch_generator,
                                  class_weight=class_weights,
                                  use_multiprocessing=canMultiprocess, 
                                  workers=4,
                                  max_queue_size=32,
                                  shuffle=True)
    
    print("Finished training, beginning cleanup.")
    #Clean up the temp files
    del training_batch_generator
    del validation_batch_generator

#Save history and model
with open(os.path.join(output_dir, 'train_history.pkl'), 'wb') as file_pi:
        pickle.dump(history.history, file_pi)
model.save(os.path.join(output_dir, "model.h5"))

print("All done, results saved in {}".format(output_dir))
