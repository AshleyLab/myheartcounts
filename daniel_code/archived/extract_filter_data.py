# -*- coding: utf-8 -*-
"""
Created on Sat Jun 15 19:09:19 2019


Python script to be run on the sherlock cluster, which iterates through data files
reformats and filters out relevant healthcodes

Organizes hdf files into a flat heirarchy, does train/val/test split, and removes 
healthcodes which don't have labels

Run preprocess_data.py on the walk_data,
Change output_dir, data_file vars below to point at those files

@author: Daniel Wu
"""
import os
import h5py
import math
import pickle




# =============================================================================
# Extract only the needed data into a file
# =============================================================================

def extract_labels(labels, label_table_path):
    '''
    Returns a dataframe indexed by healthCodes with columns of requested labels
    taken from the label table file
    '''
    label_df = pickle.load(open(label_table_path, 'rb')) 
    label_df = label_df[labels]
    return label_df.dropna()
        

def extract_records(healthCodes, data_path, out_path):
    '''
    Extracts the all of the healthcodes in healthCodes
    from the data_file, aggregates and labels healthcode windows, 
    and saves to a new hdf5 file with datasets representing a single window.
    '''
    
    #Open files
    with h5py.File(data_path, 'r') as data_file, h5py.File(out_path, 'a') as new_file:
        
        #Go through the keys of the old file 
        valid_codes = set(healthCodes)
        counter = 0
        for code in data_file.keys():
            #If the healthcode is valid, copy into new file
            if code in valid_codes:
                
                #Put each window as its own dataset in HDF
                for i in range(data_file[code].shape[0]):
                
                    d = new_file.create_dataset(str(counter), data = data_file[code][i])
                    d.attrs["healthCode"] = code
                    counter += 1

def extract_data(data_file, out_file_name):
    """
    Wrapper function that extracts the labelled data from the 6mwt results
    and splits the data
    
    Returns an HDF5 file containing all the filtered data
    and a dataframe containing the labels for the healthcodes inside
    
    """
    #Get labels
    label_df = extract_labels(labels = labels_of_interest, label_table_path = label_table_file)
    healthCodes = label_df.index.tolist()
    
    #Make a temporary data file in the same folder
    out_path = os.path.dirname(data_file) + os.sep + out_file_name
    #Extract the records out from the 
    extract_records(healthCodes, data_file, out_path)
    
# =============================================================================
# Split data files into validation and test
# =============================================================================

def split_data(file_path, val_split, test_split):
    '''
    split_data(file_path, val_split, test_split)
    splits the data in the hdf file at filepath
    with the given split ratio, between 0 and 1.
    Uses new_folder in the new filepath
    Returns a tuple with three filenames, train, val, test
    '''
    
    with h5py.File(file_path, 'r') as hdf_file:
        
        health_codes = list(hdf_file.keys())
        num_val = math.floor(len(health_codes) * val_split)
        num_test = math.floor(len(health_codes) * test_split)
        num_train = len(health_codes) - num_val - num_test
        
        #Make the split
        train_codes = health_codes[: num_train]
        validation_codes = health_codes[num_train : num_train + num_val]
        test_codes = health_codes[num_train + num_val : ]
        
        #Define paths
        out_dir = os.path.dirname(file_path)
        train_path = os.path.join(out_dir, "train_unfiltered.hdf5")
        validation_path = os.path.join(out_dir, "validation_unfiltered.hdf5")
        test_path = os.path.join(out_dir, "test_unfiltered.hdf5")

        #Open and save the train set
        with h5py.File(train_path, 'w') as train_file:

            for code in train_codes:
                hdf_file.copy(code, train_file)
        
        #Open and save the validation set
        with h5py.File(validation_path, 'w') as validation_file:
            
            for code in validation_codes:
                hdf_file.copy(code, validation_file)
                
        #Open and save the test set
        with h5py.File(test_path, 'w') as test_file:

            for code in test_codes:
                hdf_file.copy(code, test_file)
        
    return train_path, validation_path, test_path
        
    
if __name__ == "__main__":

    
    # =============================================================================
    # PARAMETERS
    # =============================================================================
    validation_split = 0.2
    test_split = 0.1
    labels_of_interest = ["heartAgeDataGender"]  #["heartCondition"]
    
    #File locations
    data_file = "/scratch/PI/euan/projects/mhc/code/daniel_code/filtered_windows/data_windows_walk.hdf5"
    label_table_file = "/scratch/PI/euan/projects/mhc/code/daniel_code/combined_health_label_table.pkl"
    
    # =============================================================================
    # Begin data processing and filtering
    # =============================================================================
    
    #Split the dataset
    print("Beginning data split with {}/{}/{} ratio".format(100*(1-validation_split - test_split), 100*validation_split, 100*test_split))
    out_dir = os.path.dirname(data_file)
    walk_train, walk_validation, walk_test = split_data(data_file, validation_split, test_split)

    print("Finished data splitting at {}, beginning to filter the training data".format(out_dir))

    #Filter the training data
    out_path = os.path.dirname(walk_train) + os.sep + "filtered_train.hdf5"
    extract_data(walk_train, "filtered_train.hdf5")
    
    print("Finished data filtering at {}, beginning to filter the validation data".format(out_path))
        
    #Filter the validation data
    out_path = os.path.dirname(walk_validation) + os.sep + "filtered_validation.hdf5"
    extract_data(walk_validation, "filtered_validation.hdf5")
    
    print("Finished data filtering at {}, beginning to filter the test data".format(out_path))

    #Filter the test data
    out_path = os.path.dirname(walk_test) + os.sep + "filtered_test.hdf5"
    extract_data(walk_test, "filtered_test.hdf5")
    
    print("Finished data filtering at {}, all done!".format(out_path))
    

