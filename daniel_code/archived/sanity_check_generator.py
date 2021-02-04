# -*- coding: utf-8 -*-
"""
Created on Sun Mar 10 19:41:19 2019

Sanity Check Generator
Defines a function that plots windows and labels 
from a generator to make sure it's working

@author: dwubu
"""

import matplotlib.pyplot as plt
import numpy as np

def sanity_check(generator):
    
    for i in range(len(generator)):
        
        data, label = generator[i]
        
        for j in range(len(label)):
            plt.figure(1)
            plt.clf()
            plt.plot(data[j])
            plt.title(label[j])
            plt.pause(0.2)


def compare_results(generator, model):
    
    for i in range(len(generator)):
        
        data, label = generator[i]
        
        predictions = model.predict(data)
        predictions = np.round(predictions).astype(int)
        
        for j in range(len(label)):
            if(label[j] != predictions[j][0]):
                plt.figure(1)
                plt.clf()
                plt.plot(data[j])
                plt.title("Labelled {} but predicted {}".format(label[j], predictions[j][0]))
                plt.pause(0.5)