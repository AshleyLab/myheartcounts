import argparse
import pandas as pd
def parseArgs():
    parser = argparse.ArgumentParser(description='test')
    parser.add_argument('-readPath', type=str, help='reference to absolute file path to read indices from (e.g. synapse table). activity = motion activity collector', default='activity')
    parser.add_argument('-writePath', type=str, help='file path to write indices to')
    parser.add_argument('-n', type=int, help='number of splits to generate')
    args = parser.parse_args()
    if args.readPath == 'activity':	
        read = '/scratch/PI/euan/projects/mhc/data/tables/cardiovascular-motionActivityCollector-v1.tsv'
    else:
        read = args.readPath
    return read, args.writePath, args.n
def getDataLength(read):
    data = pd.read_csv(read, sep='\t')	
    return data.shape[0]
def splitIndices(length, n):
    indexList = [x for x in range(length)]
    splitIndexes = [indexList[i:i+n] for i in range(0, len(indexList), n)]
    return [(x[0], x[-1]+1) for x in splitIndexes]
def main():
    read, write, n = parseArgs()
    length = getDataLength(read)
    numSplits = int(length/n)
    indexSplits = splitIndices(length, numSplits)
    with open('./'+write,'w') as fout:
        for i in indexSplits:
            fout.write(' '.join([str(i[0]), str(i[1])])+'\n')       
if __name__ == "__main__":
    main()
