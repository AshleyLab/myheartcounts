from Parameters import * 
from os import listdir 
from os.path import isfile,join 
import sys 

new_table_files=[f for f in listdir(table_dir) if isfile(join(table_dir,f))]
current_files=open(table_master_list,'r').read().split('\n') 
if '' in current_files: 
    current_files.remove('') 
new_table_files=set(new_table_files) 
current_files=set(current_files) 
diff_files=new_table_files-current_files 
if len(diff_files)==0: 
    print "No new table files found!" 
else: 
    print "new files:"
    for f in diff_files: 
        print str(f) 
outf=open(table_master_list,'w') 
for f in new_table_files: 
    outf.write(f+'\n') 

