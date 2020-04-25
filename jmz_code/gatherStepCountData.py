#!/usr/bin/env python
# coding: utf-8

import pandas as pd
import numpy as np
import argparse
import time
from os import listdir
from os.path import isfile, join, exists
import csv

def parseArgs():
    parser = argparse.ArgumentParser(description='gather step count data from synapseCache')
    parser.add_argument('-idxFile', type=str, help='path to index file', default='indices600')
    parser.add_argument('-line', type=int, help='line containing indices to read')
    parser.add_argument('-outputFile', type=str, help='path to outputfile', default='')
    args = parser.parse_args()
    return args.idxFile, int(args.line), args.outputFile

def getIndicesFromPath(indexFile, line2Read):
    with open(indexFile, 'r') as fin:
        lines = fin.readlines()
    line = lines[line2Read].split()
    line = [int(x) for x in line]
    return line[0], line[1]

def getHealthKitCollectorSubset(startIndex, endIndex):
    healthKitLocationsFile = 'cardiovascular-HealthKitDataCollector-v1.tsv'
    healthKitCollector = pd.read_csv('/scratch/PI/euan/projects/mhc/data/tables/'+healthKitLocationsFile, sep='\t', low_memory=False)
    healthKitCollector = healthKitCollector.iloc[startIndex:endIndex,:]
    healthKitCollector = healthKitCollector[~healthKitCollector['data.csv'].isnull()]
    return healthKitCollector

def getFileLocation(healthKitCollector):
    """
    Returns list of healthCode, blob location and created on 
    """
    code2Location = []
    def getLastDigits(num, last_digits_count=3):
        return abs(num) % (10**last_digits_count)
    for i,row in healthKitCollector.iterrows():
        dataLoc = int(row['data.csv'])
        dataAbb = getLastDigits(dataLoc)
        code2Location.append([row['healthCode'],
                              '/scratch/PI/euan/projects/mhc/data/synapseCache/'+str(dataAbb)+'/'+str(dataLoc)+"/",
                              row['createdOn'][:10], str(dataLoc), row['appVersion'], row['phoneInfo']])
    return code2Location

def getFileList(path):
    """
    Returns files in specified path
    """
    if exists(path):
        fPath = [f for f in listdir(path) if isfile(join(path, f)) and ('.csv' in f and '.clean' not in f)]
        if len(fPath) == 0:
            return ''
        else:
            return fPath[0]
    else:
        return 'doesNOTexist'

def location2File(code2Location):
    """
    Returns list of healthcode and file name
    """
    code2File = []
    for i,item in enumerate(code2Location):
        try:
            fName = getFileList(item[1])
            code2File.append([item[0], item[1]+fName, item[2], item[3], item[4], item[5]]) #[healthCode, fileName, createdOn, blob, appVersion, phoneInfo]
        except:
            code2File.append(item) #[healthCode, fileName, createdOn, blob, appVersion, phoneInfo]
    return code2File

def readHealthKitFile(filePath):
    """
    Parses healthKit input file
    Parameters:
        filePath: absolute filepath to healthKitFile
    Returns:
        parsedData: data containing data lines in file or filePath if unable to find any data
    """
    parsedData = []
    if isfile(filePath) and (filePath[-4:] == '.tmp' or '.csv' in filePath):
        with open(filePath, 'r', errors='ignore') as fin:
            data = fin.readlines()
            for l in data:
                if l != 'datetime,type,value\n' and l != 'startTime,endTime,type,value,unit,source,sourceIdentifier\n' and\
	                l != 'startTime,endTime,type,value,unit,source,sourceIdentifier,appVersion\n':
                    lineToWrite = list(csv.reader([l], delimiter=',', quotechar='"'))[0]#[:5]
                    if len(lineToWrite) > 1 and 'HKQuantityTypeIdentifierStepCount' in lineToWrite: 
                        if len(lineToWrite) < 5:#data is valid but only has one timestamp
                            lineToWrite = [lineToWrite[0]] + ['NaN'] + lineToWrite[1:]
                        while len(lineToWrite) < 8:
                          lineToWrite.append('NaN')
                        parsedData.append(lineToWrite)
    if len(parsedData) == 0:
        parsedData = ['noStepCountFound']
    return parsedData

def parseHealthKitData(code2File, foutPath):
    """
    Parses the healthKitDataCollector
    """
    problemBlobs = []
    with open(foutPath, 'w') as fout:
        fout.write('healthCode\tblob\tcreatedOnCollector\tappVersion\tphoneInfo\ttimeStampStart\ttimeStampStop\ttype\tvalue\tunit\tsource\tsourceIdentifier\tappVersion\n')
        for i,u in enumerate(code2File):
            try:
                toWrite = readHealthKitFile(u[1])
                if toWrite == ['noStepCountFound']:
                    problemBlobs.append(u+toWrite)
                else:
                    toWrite = [[u[0], u[3], u[2], str(u[4]), str(u[5])] + content for content in toWrite]
                    for tw in toWrite:
                        fout.write('\t'.join(tw)+'\n')
            except:
                problemBlobs.append(u+['ExceptionRaised'])
    with open(foutPath + 'Errors', 'w') as fout:
       fout.write('healthCode\tblob\tpath\n')
       for pb in problemBlobs:
           fout.write('\t'.join([pb[0], pb[3], pb[1], pb[-1]])+'\n')
    return

def main():
    startTime = time.time()
    idxFile, line2Read, outputFile = parseArgs()
    startIdx, endIdx = getIndicesFromPath(idxFile, line2Read)
    if outputFile == '':
        outputFile = 'indeces' + f"{startIdx:07d}" + "to" + f"{endIdx:07d}"
    healthKitCollector = getHealthKitCollectorSubset(startIdx, endIdx)
    code2Location = getFileLocation(healthKitCollector)
    code2File = location2File(code2Location)
    writePath = './activityLines/' + str(outputFile)
    parseHealthKitData(code2File, writePath)
    endTime = time.time()
    print("Reading split %s to %s took %s seconds." %(str(startIdx), str(endIdx), str(round(endTime-startTime,3))))

if __name__ == "__main__":
    main()
