#SCRIPT READS IN NAMES AND LIFE EXPECTANCY DATA FROM THE SSA AND DETERMINES THE GENDER AND MEDIAN AGE (AS WELL AS IQR) FOR ALL NAMES
#NOTE: ACTUARIAL TABLES ARE GIVEN TO NEAREST DECADE, SO THIS PROVIDES AN ESTIMATE AT THE DECADE LEVEL 
from Parameters import *
import sys
import numpy
import os 
from os import listdir 
from os.path import isfile,join,exists


def import_life_tables(external_data):
    fnames=[f for f in listdir(external_data) if isfile(join(external_data,f))]
    male_dict=dict()
    female_dict=dict()
    for f in fnames:
        print str(f) 
        if f.startswith('life_table') and f.endswith('.tsv'):
            data=open(external_data+f,'r').read().replace('\r\n','\n').split('\n')
            if '' in data:
                data.remove('')
            year=f.split('_')[-1].split('.')[0]
            cur_age=2015-int(year)
            print str(year) +":"+str(cur_age) 
            for line in data[2::]:
                #print str(line) 
                line=line.split('\t')
                age=int(line[0])
                if age==cur_age:
                    male_probability=float(line[2])/100000
                    female_probability=float(line[9])/100000 
                    male_dict[int(year)]=male_probability
                    female_dict[int(year)]=female_probability
    return male_dict,female_dict
                
def get_stats(name_to_ages):
    total=str(len(name_to_ages.keys()))
    #compute the median and iqr
    median_dict=dict()
    iqr_low=dict()
    iqr_high=dict()
    c=0
    for name in name_to_ages:
        c+=1 
        if c%100==0: 
            print str(c)+"/"+total 
        flat_list=[] 
        for age in name_to_ages[name]: 
            flat_list=flat_list+[age]*name_to_ages[name][age] 
        #print(str(flat_list))
        if len(flat_list)==0: 
            print str(name)+":"+str(name_to_ages[name]) 
            continue
        if name=="Anna":
            print str(name_to_ages[name])
        median_dict[name]=numpy.median(flat_list)
        iqr_low[name]=numpy.percentile(flat_list,25)
        iqr_high[name]=numpy.percentile(flat_list,75)
    return median_dict,iqr_low,iqr_high


def write_output(name_to_sex,median_dict,iqr_low_dict,iqr_high_dict,outputf):
    outf=open(outputf,'w')
    outf.write('Name\tMales\tFemales\tTotal\tMedianAge\t25thPercentile\t75thPercentile\n')
    for name in name_to_sex:
        if "M" in name_to_sex[name]: 
            males=str(name_to_sex[name]['M'])
        else: 
            males="0" 
        if "F" in name_to_sex[name]: 
            females=str(name_to_sex[name]['F']) 
        else: 
            females="0"  
        total=str(int(females)+int(males)) 
        outf.write(name+'\t'+males+'\t'+females+'\t'+total+"\t"+str(median_dict[name])+"\t"+str(iqr_low_dict[name])+'\t'+str(iqr_high_dict[name])+'\n')
        
    
def get_national_statistics(ssa_national,ssa_national_outf,external_data):
    male_freq_dict,female_freq_dict=import_life_tables(external_data)
    #print str(male_freq_dict) 
    #print str(female_freq_dict) 
    print "got life tables!" 
    name_to_sex=dict()
    name_to_ages=dict()
    
    for year in range(1910,2001):
        data=open(ssa_national+"yob"+str(year)+".txt",'r').read().split('\n')
        data.remove('')
        for line in data:
            line=line.split(",")
            name=line[0]
            sex=line[1]
            count=line[2]
            if name not in name_to_sex:
                name_to_sex[name]=dict() 
            if sex not in name_to_sex[name]: 
                name_to_sex[name][sex]=int(count) 
            else: 
                name_to_sex[name][sex]+=int(count)
            if sex=="F":
                num_alive=float(count)*female_freq_dict[10*(int(year)/10)]
            elif sex=="M":
                num_alive=float(count)*male_freq_dict[10*(int(year)/10)]
            if name not in name_to_ages:
                name_to_ages[name]=dict()
            cur_age=2015-year 
            if cur_age not in name_to_ages[name]: 
                name_to_ages[name][2015-year]=int(numpy.ceil(num_alive))
            else: 
                name_to_ages[name][2015-year]+=int(numpy.ceil(num_alive))
    print "Anna:"+str(name_to_ages["Anna"])
    print "parsed baby name statistics file" 
    median_dict,iqr_low_dict,iqr_high_dict=get_stats(name_to_ages)
    write_output(name_to_sex,median_dict,iqr_low_dict,iqr_high_dict,ssa_national_outf)
    

def get_state_statistics(ssa_state,ssa_state_outf,external_data):
    pass


def main():
    if len(sys.argv)<2:
        print "use -state flag to get statistics by state, -national flag to get national statistics"
        exit()
    if "-national" in sys.argv:
        get_national_statistics(ssa_national,ssa_national_outf,external_data)
    elif "-state" in sys.argv:
        get_state_statistics(ssa_state,ssa_state_outf,external_data)
    else:
        print "use -state flag to get statistics by state, -national flag to get national statistics"
        exit() 

if __name__=="__main__":
    main() 
