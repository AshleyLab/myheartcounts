from Parameters import *
from os import listdir 
from os.path import isfile,join
from helpers import * 
files=[f for f in listdir(intermediate_results_dir) if isfile(join(intermediate_results_dir,f))]
outf=open(intermediate_results_dir+'card_disp_summary.tsv','w')
master_dict=dict()
features=[]
for f in files:
    if f.startswith('card_disp_summary.tsv_'):
        print str(f) 
        data=split_lines(intermediate_results_dir+f)
        #print str(data) 
        header=data[0].split('\t')
        print "header length:"+str(len(header)) 
        for line in data[1::]:
            line=line.split('\t')
            print "line length:"+str(len(line))
            subject =line[0]
            master_dict[subject]=dict()
            for i in range(1,len(line)):
                print str(i) 
                feature=header[i]
                if feature not in features: 
                    features.append(feature) 
                value=line[i]
                if feature not in master_dict[subject]:
                    master_dict[subject][feature]=value
features=list(features) 
outf.write('Subject')
for feature in features:
    outf.write('\t'+feature)
outf.write('\n')
for subject in master_dict:
    outf.write(subject)
    for feature in features:
        if feature in master_dict[subject]:
            outf.write('\t'+master_dict[subject][feature])
        else:
            outf.write('\t')
    outf.write('\n')
    
        
