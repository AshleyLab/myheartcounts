
import pickle 
#GET LIST OF ALL KNOWN SUBJECTS!!
subjects=open('/home/annashch/intermediate_results/subjects.txt','r').read().split('\n') 
subjects.remove('') 

p=open('acceleration_rest.pickle','r') 
acceleration_rest_dict=pickle.load(p) 

p=open('acceleration_walk.pickle','r')
acceleration_walk_dict=pickle.load(p) 

p=open('device_rest.pickle','r') 
deviceMotion_rest_dict=pickle.load(p) 

p=open('device_walk.pickle','r') 
deviceMotion_walk_dict=pickle.load(p) 

p=open('hr_r.pickle','r') 
hr_dict_rest=pickle.load(p) 

p=open('hr_w.pickle','r') 
hr_dict_walk=pickle.load(p) 

p=open('pedometer.pickle','r') 
pedometer_dict=pickle.load(p) 

p=open('displacement_6min.pickle','r')
d6min_disp_dict=pickle.load(p) 

outf=open('/home/annashch/6min_walk.tsv','w') 
outf.write('Subject\tDisplacement_StartTime\tDisplacement_EndTime\tDisplacement_Entries\tDisplacement_Sessions\tDisplacement_Granularity\t')
outf.write('Pedometer_StartTime\tPedometer_EndTime\tPedometer_Entries\tPedometer_Sessions\t')
outf.write('AccelerationWalk_StartTime\tAccelerationWalk_EndTime\tAccelerationWalk_Entries\tAccelerationWalk_Sessions\t')
outf.write('AccelerationRest_StartTime\tAccelerationRest_EndTime\tAccelerationRest_Entries\tAccelerationRest_Sessions\t') 
outf.write('HRWalk_Entries\tHRWalk_Sessions\t') 
outf.write('HRRest_Entries\tHRRest_Sessions\t') 
outf.write('deviceMotionWalk_StartTime\tdeviceMotionWalk_EndTime\tdeviceMotionWalk_Entries\tdeviceMotionWalk_Sessions\t') 
outf.write('deviceMotionRest_StartTime\tdeviceMotionRest_EndTime\tdeviceMotionRest_Entries\tdeviceMotionRest_Sessions\n')
for s in subjects: 
        outf.write(s) 
        if s in d6min_disp_dict:
                outf.write('\t'+str(d6min_disp_dict[s][2])+'\t'+str(d6min_disp_dict[s][3])+'\t'+str(d6min_disp_dict[s][0])+'\t'+str(d6min_disp_dict[s][1])+'\t'+str(d6min_disp_dict[s][4]))
        else: 
                outf.write('\tNA\tNA\t0\t0\tNA') 
        if s in pedometer_dict: 
                outf.write('\t'+str(pedometer_dict[s][2])+'\t'+str(pedometer_dict[s][3])+'\t'+str(pedometer_dict[s][0])+'\t'+str(pedometer_dict[s][1]))
        else: 
                outf.write('\tNA\tNA\t0\t0') 
        if s in acceleration_walk_dict: 
                outf.write('\t'+str(acceleration_walk_dict[s][2])+'\t'+str(acceleration_walk_dict[s][3])+'\t'+str(acceleration_walk_dict[s][0])+'\t'+str(acceleration_walk_dict[s][1]))
        else: 
                outf.write('\tNA\tNA\t0\t0') 
        if s in acceleration_rest_dict: 
                outf.write('\t'+str(acceleration_rest_dict[s][2])+'\t'+str(acceleration_rest_dict[s][3])+'\t'+str(acceleration_rest_dict[s][0])+'\t'+str(acceleration_rest_dict[s][1]))
        else: 
                outf.write('\tNA\tNA\t0\t0') 
        if s in hr_dict_walk: 
                outf.write('\t'+str(hr_dict_walk[s][0])+'\t'+str(hr_dict_walk[s][1]))
        else: 
                outf.write('\t0\t0') 
        if s in hr_dict_rest: 
                outf.write('\t'+str(hr_dict_rest[s][0])+'\t'+str(hr_dict_rest[s][1]))
        else: 
                outf.write('\t0\t0') 
        if s in deviceMotion_walk_dict: 
                outf.write('\t'+str(deviceMotion_walk_dict[s][2])+'\t'+str(deviceMotion_walk_dict[s][3])+'\t'+str(deviceMotion_walk_dict[s][0])+'\t'+str(deviceMotion_walk_dict[s][1]))
        else: 
                outf.write('\tNA\tNA\t0\t0') 
        if s in deviceMotion_rest_dict: 
                outf.write('\t'+str(deviceMotion_rest_dict[s][2])+'\t'+str(deviceMotion_rest_dict[s][3])+'\t'+str(deviceMotion_rest_dict[s][0])+'\t'+str(deviceMotion_rest_dict[s][1]))
        else: 
                outf.write('\tNA\tNA\t0\t0')                                                 

        outf.write('\n') 
