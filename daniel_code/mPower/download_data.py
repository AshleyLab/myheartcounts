#!/usr/bin/env python
# coding: utf-8

# # Download data from synapse for mPower

# In[1]:


import synapseclient
import synapseutils
import numpy as np
import pandas as pd
import pickle

# In[2]:


syn = synapseclient.login()


# In[3]:


mPowerWalkID = 'syn5511449'


# In[4]:


walkTable = syn.tableQuery('SELECT * FROM ' + mPowerWalkID)


# In[5]:


walkTable.asDataFrame()


# In[ ]:


def save_dict(di_, filename_):
    with open(filename_, 'wb') as f:
        pickle.dump(di_, f)


# In[ ]:


files = syn.downloadTableColumns(walkTable, "accel_walking_outbound.json.items")
save_dict(files, "accel_outbound.pkl")


# In[ ]:


files = syn.downloadTableColumns(walkTable, "accel_walking_return.json.items")
save_dict(files, "accel_return.pkl")


# In[ ]:


DMOutfiles = syn.downloadTableColumns(walkTable, "deviceMotion_walking_outbound.json.items")
save_dict(files, "DM_outbound.pkl")


# In[ ]:


DMReturnfiles = syn.downloadTableColumns(walkTable, "deviceMotion_walking_return.json.items")
save_dict(files, "DM_return.pkl")


# In[ ]:




