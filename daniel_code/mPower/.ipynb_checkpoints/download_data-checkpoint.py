#!/usr/bin/env python
# coding: utf-8

# # Download data from synapse for mPower

import synapseclient
import synapseutils
import numpy as np
import pandas as pd
import json

syn = synapseclient.login()

mPowerWalkID = 'syn5511449'

walkTable = syn.tableQuery('SELECT * FROM ' + mPowerWalkID)

files = syn.downloadTableColumns(walkTable, "accel_walking_outbound.json.items")

DMOutfiles = syn.downloadTableColumns(walkTable, "deviceMotion_walking_outbound.json.items")

DMReturnfiles = syn.downloadTableColumns(walkTable, "deviceMotion_walking_return.json.items")