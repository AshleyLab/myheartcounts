#cleans up common errors when parsing healthkit files 
import argparse 
import re
def parse_args():  
    parser=argparse.ArgumentParser(description="clean up common errors when parsing healthkit files")
    parser.add_argument("file_list")
    return parser.parse_args() 

def main(): 
    args=parse_args() 
    files=open(args.file_list,'r').read().strip().split('\n')
    for f in files: 
        data=open(f,'r').read().strip().split('\n')
        outf=open(f+'.filtered','w') 
        header="startTime,endTime,type,value,unit,source,sourceIdentifier"
        first_line=data[0] 
        #1. make sure there is a header 
        outf.write(header+'\n') 
        for line in data: 
            tokens=line.split(',') 
            #2. make sure there are no stray header fields 
            if tokens[0].startswith('startTime'): 
                continue 
            #3. make sure all lines contain appropriate number of tokens 
            if len(tokens)!=7: 
                continue 
            #4. remove non-alpha-numeric characters from last two tokens  
            tokens[5]=re.sub(r'\W+','',tokens[5])
            tokens[6]=re.sub(r'\W+','',tokens[6])
            outf.write(','.join(tokens)+'\n')





if __name__=="__main__": 
    main() 
