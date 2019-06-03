#!/usr/bin/env python
# coding: utf-8

import pandas as pd
import numpy as np
from os import listdir, mkdir
from os.path import isfile, join, exists
import argparse 
import time

def parseArgs():
    parser = argparse.ArgumentParser(description='Process core motion file by indexes')
    parser.add_argument('--writePath', type=str, help='output file path within ./data/')
    parser.add_argument('--indexFilePath', type=str, help='path to file containing indices to analyze')
    parser.add_argument('--listIdx', type=int, help='index of indexlist file to analyze')
    args = parser.parse_args()
    return args.writePath, args.indexFilePath, args.listIdx
def getIndices(indexFilePath, index):
    with open(indexFilePath,'r') as fin:
        lines=fin.readlines()
        line = lines[index]
    line = line.split()
    return int(line[0]), int(line[1])
    
def readBlobLocations(start, end):
    motionLocationsFile = 'cardiovascular-motionActivityCollector-v1.tsv'
    activityCollector = pd.read_csv('/scratch/PI/euan/projects/mhc/data/tables/'+motionLocationsFile, sep='\t')
    activityCollector = activityCollector.iloc[start:end,:]
    activityCollector = activityCollector[~activityCollector['data.csv'].isnull()]
    return activityCollector

def convertBlobToFileLocation(activityCollector):
    
    #activities: not available, automotive, stationary, walking, running, cycling
    code2FileLocation = []
    def getLastDigits(num, last_digits_count=3):
        return abs(num) % (10**last_digits_count)
    for i,row in activityCollector.iterrows():
        dataLoc = int(row['data.csv'])
        dataAbb = getLastDigits(dataLoc)
        code2FileLocation.append([row['healthCode'], 
                              '/scratch/PI/euan/projects/mhc/data/synapseCache/'+str(dataAbb)+'/'+str(dataLoc)+"/", 
                              row['uploadDate'], str(dataLoc), row['appVersion'], row['phoneInfo']])
    return code2FileLocation

def getFileList(path):
    """
    Returns name of file in specified path
    """
    if exists(path):
        fPath = [f for f in listdir(path) if isfile(join(path, f)) and ('.csv' in f)]
        if len(fPath) == 0:
            return ''
        else:
            return fPath[0]
    else:
        return 'doesNOTexist'
def getFullPaths(code2FileLocation):
    """
    Get full paths of files
    """
    code2File = []
    for i,item in enumerate(code2FileLocation):
        fName = getFileList(item[1])
        code2File.append([item[0], item[1]+fName, item[2], item[3], item[4], item[5]])#healthcode, filepath, uploaddate, blob, appversion, phoneInfo
    return code2File

def getActivitySummary(fileContents, blobNumber, activityDict, timeDict):
    """
    Returns a dictionary mapping activity types from a core motion collector activity files
    """

    dates = set()
    activities = {}
    fileContents = [l.split('\n')[0].split(',') for l in fileContents]
    fileContents = [x for x in fileContents if (len(x) == 3)] # check there is no error in the line
    for i,l in enumerate(fileContents):
        # if (line correct length) and (confidence = medium/high)
        if (l[2] == '1' or l[2] == '2'):
            if len(l[0]) == 25 and (i+1<len(fileContents) and len(fileContents[i+1][0]) == 25):
                start = pd.Timestamp(l[0]).tz_convert('GMT')
                end = pd.Timestamp(fileContents[i+1][0]).tz_convert('GMT')
                duration = (end-start)/pd.Timedelta('1 minute')
                if duration < 15 and duration > 0:
                    startDate = start.date()
                    times = assignActivityMatrix(start, end, timeDict)
                    if startDate not in dates:
                        dates.add(startDate)
                        activities[startDate] = [np.zeros((6,48)), blobNumber, 0]
                    activities[startDate][2] += 1
                    for t in times:
                        activities[startDate][0][activityDict[l[1]]][t[0]] += t[1]
    return activities

def assignActivityMatrix(start, end, timeIndexes):
    """
    Returns 
    """
    if start.floor(freq='30T') == end.floor(freq='30T'):
        times = [(timeIndexes[start.floor(freq='30T').time()], (end-start)/pd.Timedelta('1 minute'))]
    else:
        times = [(timeIndexes[start.floor(freq='30T').time()], (end.floor(freq='30T')-start)/pd.Timedelta('1 minute')),
                (timeIndexes[end.floor(freq='30T').time()], (end-end.floor(freq='30T'))/pd.Timedelta('1 minute'))]
    return times

def writeResults(code2File, writePath, writePathError):
    fileNotFound = []
    timeDictionary = {x:i for i,x in enumerate([x.time() for x in pd.date_range(pd.Timestamp.now().date(), periods=48, freq='30min')])}
    activityDict = {'not available':0, 'stationary':1, 'walking':2, 'running':3, 'cycling':4, 'automotive':5}

    with open(writePath, 'w') as fout:
        labels = ['healthCode', 'blob', 'appVersion', 'phoneInfo', 'date', 'activity', 'numDataPoints'] + [str(x) for x in timeDictionary.keys()]
        fout.write('\t'.join(labels) + '\n')
        for i,u in enumerate(code2File):
            if '.csv' in u[1]:
                try:
                    with open(u[1], 'r', errors='ignore') as fin:
                        activities = getActivitySummary(fin.readlines(), u[3], activityDict, timeDictionary)
                        for k,v in activities.items():
                            for a in activityDict.keys():
                                toWrite = [u[0], u[3], u[4], u[5], str(k), a, v[2]] + list(v[0][activityDict[a]])
                                fout.write('\t'.join([str(x) for x in toWrite])+'\n')
                except:
                    print("Error at blob " + str(u[3]))
                    fileNotFound.append(u)
            else:
                fileNotFound.append(u)

    with open(writePathError, 'w') as fout:
        fout.write('healthCode\tBlob\n')
        for f in fileNotFound:
            toWrite = [f[0], f[3]]
            fout.write('\t'.join(toWrite) + '\n')
def main():
    startTime = time.time()
    writePath, indexFilePath, index = parseArgs()
    start, end = getIndices(indexFilePath, index)
    if not exists('./data/'+writePath):
        mkdir('./data/'+writePath)
    writePath = './data/' + writePath +'/'+ writePath + '{:03d}'.format(start) + 'to' + '{:03d}'.format(end)
    writePathError = writePath + 'Errors'
    activityCollector = readBlobLocations(start, end)
    code2FileLocation = convertBlobToFileLocation(activityCollector)
    code2File = getFullPaths(code2FileLocation)
    writeResults(code2File, writePath, writePathError)
    endTime = time.time()
    print("Total time taken for index %s to %s: %s" %(str(start),str(end),str(round(endTime-startTime,4))))
if __name__ == "__main__":
    main()
