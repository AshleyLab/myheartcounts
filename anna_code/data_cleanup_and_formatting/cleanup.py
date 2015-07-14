#READS THROUGH BLOBS IN INPUT FILE AND PERFORMS THE FOLLOWING FILTERING STEPS: 
#1.) REMOVE ANY LINES NOT STARTING WITH "2015" 
#2.) SORT BY TIMESTAMP 
#3.) REMOVE ANY FULLY DUPLICATED ENTRIES 
#4.) WRITE TO FILE WITH SUFFIX .clean  
from Parameters import * 
from os import listdir 
from os.path import isfile,join 


#reads in a datafile and splits by line 
#replace '\r\n' with '\n' for Linux & Windows compatible newline characters 
def split_lines(fname): 
	data=open(fname,'r').read().replace('\r\n','\n').split('\n')
	if '' in data:
		data.remove('') 

        return data

#reads in a blob file specified with hash notation in a table file 
def parse_blob(blob_hash,force): 
        top_dir=blob_hash[-3::].lstrip('0') 
        if top_dir=="": 
                top_dir='0' 
        full_dir=synapse_dir+top_dir+'/'+blob_hash
        csv_files=[f for f in listdir(full_dir) if isfile(join(full_dir,f))]
	#CHECK TO SEE IF THERE IS ALREADY A .clean FILE IN THIS DIRECTORY AND SKIP BY DEFAULT 
	if force==False: 
		has_clean_file=False 
		for f in csv_files: 
			if f.endswith('.clean'): 
				has_clean_file=True 
				break 
		if has_clean_file: #DO NOT OVERWRITE EXISTING CLEAN FILES 
			return None,None
        for f in csv_files: 
                if f.startswith('.'): 
                        continue 
                if f.endswith('.tmp')==False: 
                        continue 
                else: 
                        #subprocess.check_output(['mv', full_dir+'/'+f+'.clean.clean',full_dir+'/'+f+'.clean'])
                        return split_lines(full_dir+'/'+f),full_dir+'/'+f 

def main(): 	
    force=False 
    if "-f" in sys.argv: 
	    force=True 
	    print "Since the -f flag was passed, existing .clean files will be overwritten"  
    else: 
	    print "By default, the script will ignore blob entries that already contain a .clean file. To override these files, call the script with the flag -f" 
    valid_line_start="2015" #assume all data collected in 2015 
    for f in blob_csv_formats: 
        print str(f) 
        data=split_lines(table_dir+f) 
        counter=0 
        for line in data[1::]:
                line=line.split('\t')     
                counter+=1 
                if counter%1000==0: 
                        print "COUNTER:"+str(counter) 
                blobname=line[8]
                if blobname=="NA": 
                        continue 
                try:        
                        blob,blobfilename=parse_blob(blobname,force) 
			if blob==None: 
				continue 
                        outf=open(blobfilename+'.clean','w')                         
                        header=blob_headers[f] 
                        outf.write(header+'\n') 
                        blob.sort() #sort by timestamp (the first entry) 
                        last_line=None 
                        for blob_line in blob: 
                                if blob_line.startswith(valid_line_start):
				#check to see if there is a repeat date entry! 
					bad_index=find(valid_line_start,10,len(line))
					if bad_index > -1: 
						blob_line=blob_bline[0:bad_index]+'\n'+blob_line[bad_index::]
                                        if last_line==None: 
                                                outf.write(blob_line+'\n') 
                                                last_line=blob_line.split('\n')[-1]  
                                        elif blob_line!=last_line: #there are duplicate entries in the blobs, we only want to record them once 
                                                outf.write(blob_line+'\n') 
                                                last_line=blob_line.split('\n')[-1] 
                except:
                        print str(blobname) #print out any blob names that could not be filtered and continue 
                        continue 

if __name__=="__main__": 
	main() 
