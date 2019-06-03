#!/usr/bin/env python
# coding: utf-8

import pandas as pd
import numpy as np
import argparse
import time

def parseArgs():
    parser = argparse.ArgumentParser(description='parse a step count file split')
    parser.add_argument('-fpath', type=str, help='prefix of path of file to read')
    parser.add_argument('-idxPath', type=str, help='path of index file to read', default='indices600')
    parser.add_argument('-line', type=int, help='line from idxPath file to read')
    args = parser.parse_args()
    if args.fpath is None:
        args.fpath = './activityLines/indeces'
    return args.fpath, args.idxPath, args.line

def getIndices(idxPath, lineIdx, formatted=True):
    with open(idxPath, 'r') as fin:
        lines = fin.readlines()
    line = lines[lineIdx].split()
    line = [int(x) for x in line]
    if formatted:
        line = [f"{x:07d}" for x in line]
    return line[0], line[1]

def assignActivityMatrix(start, end, timeIndexes, steps):
    """
    Returns 
    """
    start = pd.Timestamp(start)
    if end == 'NaN':
        return [(timeIndexes[start.floor(freq='30T').time()], steps)]
    end = pd.Timestamp(end)
    diff = (end-start)/pd.Timedelta('1 minute')
    if start.floor(freq='30T') == end.floor(freq='30T'):
        times = [(timeIndexes[start.floor(freq='30T').time()], 1)]
    else:
        times = [(timeIndexes[start.floor(freq='30T').time()], ((end.floor(freq='30T')-start)/pd.Timedelta('1 minute'))/diff),
                (timeIndexes[end.floor(freq='30T').time()], ((end-end.floor(freq='30T'))/pd.Timedelta('1 minute'))/diff)]
    stepsByTime = []
    for t in times:
        stepsByTime.append([t[0], t[1]*steps])
    return stepsByTime

def makeTimeDictionary():
    return {x:i for i,x in enumerate([x.time() for x in pd.date_range(pd.Timestamp.now().date(), periods=48, freq='30min')])}

def parseFile(readPath, writePath, timeDictionary):
    data={}
    userDays = set()
    badlines = []
    with open(writePath,'w') as fout:
        labels = ['healthCode', 'date', 'blob', 'numDataPoints', 'appVersionTable', 'appVersionFile', 'phoneInfo', 'source', 'sourceID'] + [str(x) for x in timeDictionary.keys()]
        fout.write('\t'.join(labels) + '\n')
    with open(writePath+'Bad', 'w') as fout:
        fout.write('bad line' + '\n')
    with open(readPath, 'r') as fin:
        for i,line in enumerate(fin):
            if i > 0 and line!= '': 
                try:
                    line = line.split("\n")[0].split("\t")
                    while len(line) < 13:
                        line.append('NaN')
                #print(line[5])
                    date = str(pd.Timestamp(line[5]).date())
                    key = (line[0], date, line[11])#(healthCode, startDate, sourceIdentifier
                    result = assignActivityMatrix(line[5], line[6], timeDictionary, float((line[8])))
                    if key not in userDays:
                        data[key] = [np.zeros((48,)), line[1], 0, line[3], line[4], line[10], line[12]]#data, blob, lineCount, appVersion from healthKit table, phoneInfo from healthKit table, appversion from healthKit file
                        userDays.add(key)
                    for r in result:
                        data[key][0][r[0]] += r[1]
                    data[key][2] += 1
                except:
                    badlines.append(line)
        
    with open(writePath,'a') as fout:
        for k,v in data.items():
            toWrite = [k[0], k[1], v[1], v[2], v[3], v[6], v[4], v[5], k[2]] + list(v[0])
            toWrite = [str(x) for x in toWrite]
            fout.write('\t'.join(toWrite) + '\n')
    with open(writePath+'Bad', 'a') as fout:
        for b in badlines:
            toWrite = [str(x) for x in b]
            fout.write('\t'.join(toWrite) + '\n')
    return

def main():
    startTime = time.time()
    readPath, idxPath, line = parseArgs()
    start, end = getIndices(idxPath, line)
    readPath += start + "to" + end
    writePath = './parsedActivityLines/parsedActivityLines' + start+"to"+end
    timeDict = makeTimeDictionary()
    parseFile(readPath, writePath, timeDict)
    endTime = time.time()
    print("Reading split from %s to %s took %s seconds." %(str(int(start)),str(int(end)), str(round(endTime-startTime,3))))
if __name__ == "__main__":
    main()





