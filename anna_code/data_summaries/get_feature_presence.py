from Parameters import * 
from helpers import * 
from os import listdir,walk 
from os.path import isfile,join 
import os 

def main(): 
    #subjects 
    subjects=open(subject_file,'r').read().split('\n') 
    if '' in subjects: 
        subjects.remove('') 
    feature_dict=dict() 
    #6 Minute Walk
    feature_dict['6MinuteWalk']=dict() 
    subdirs=[x[0] for x in os.walk(walktables)]
    for sdir in subdirs: 
        print str(sdir) 
        s_end=sdir.split('/')[-1]
        feature_dict['6MinuteWalk'][s_end]=dict() 
        subject_files=[f for f in listdir(sdir) if isfile(join(sdir,f))]
        for sfile in subject_files: 
            #print str(sfile) 
            sname=sfile.split('.')[0] 
            #entries=len(open(sdir+"/"+sfile,'r').read().split('\n')) 
            entries=1
            feature_dict['6MinuteWalk'][sdir.split('/')[-1]][sname]=entries
    print "parsed 6 minute walk!" 
    #HealthKit
    feature_dict['HealthKit']=dict() 
    subdirs=[x[0] for x in os.walk(healthkit_tables)]
    for sdir in subdirs: 
        print str(sdir) 
        s_end=sdir.split('/')[-1] 
        feature_dict['HealthKit'][s_end]=dict() 
        subject_files=[f for f in listdir(sdir) if isfile(join(sdir,f))]
        for sfile in subject_files: 
            sname=sfile.split('.')[0] 
            #entries=len(open(sdir+"/"+sfile,'r').read().split('\n')) 
            entries=1
            feature_dict['HealthKit'][s_end][sname]=entries 
    print "parsed healthkit!" 

    #Cardiovascular Displacement 
    feature_dict['CardiovascularDisp']=dict() 
    subdirs=[x[0] for x in os.walk(cardio_disp_table)]
    for sdir in subdirs: 
        print str(sdir) 
        s_end=sdir.split('/')[-1]
        feature_dict['CardiovascularDisp'][s_end]=dict() 
        subject_files=[f for f in listdir(sdir) if isfile(join(sdir,f))]
        for sfile in subject_files: 
            sname=sfile.split('.')[0] 
            #entries=len(open(sdir+"/"+sfile,'r').read().split('\n')) 
            entries=1
            feature_dict['CardiovascularDisp'][s_end][sname]=entries 
    print "parsed cardiovascular displacement!" 

    #MotionTracker 
    feature_dict['MotionTracker']=dict() 
    subdirs=[x[0] for x in os.walk(motiontracker_tables)]
    for sdir in subdirs: 
        print str(sdir) 
        s_end=sdir.split('/')[-1]
        feature_dict['MotionTracker'][s_end]=dict() 
        subject_files=[f for f in listdir(sdir) if isfile(join(sdir,f))]
        for sfile in subject_files: 
            sname=sfile.split('.')[0] 
            #entries=len(open(sdir+"/"+sfile,'r').read().split('\n')) 
            entries=1
            feature_dict['MotionTracker'][s_end][sname]=entries 
    print "parsed motiontracker!" 
    #SURVEY FEATURES 
    survey=open(survey_summary_file,'r').read().split('\n') 
    header1=survey[0].split('\t') 
    header2=survey[1].split('\t')
    for i in range(1,len(header1)): 
        h1=header1[i] 
        h2=header2[i] 
        if h1 not in feature_dict: 
            feature_dict[h1]=dict() 
        feature_dict[h1][h2]=dict() 
    for line in survey[2::]: 
        line=line.split('\t') 
        subject=line[0] 
        for i in range(1,len(line)): 
            h1=header1[i] 
            h2=header2[i] 
            val=line[i] 
            if val!="NA": 
                feature_dict[h1][h2][subject]=1 
    print "parsed survey features!" 

    #SUMMARIZE BY SUBJECT 
    outf=open(feature_presence_absence_file,'w') 
    feat1_all=[] 
    feat2_all=[] 
    for feat1 in feature_dict: 
        for feat2 in feature_dict[feat1]: 
            feat1_all.append(feat1) 
            feat2_all.append(feat2) 
    outf.write('#File\t'+'\t'.join(feat1_all)+'\n')
    outf.write('Feature\t'+'\t'.join(feat2_all)+'\n') 
    for subject in subjects:
        outf.write(subject) 
        for i in range(len(feat1_all)): 
            f1=feat1_all[i] 
            f2=feat2_all[i] 
            if subject in feature_dict[f1][f2]: 
                outf.write('\t'+str(feature_dict[f1][f2][subject]))
            else: 
                outf.write('\t0') 
        outf.write('\n') 

            
if __name__=="__main__": 
    main() 
