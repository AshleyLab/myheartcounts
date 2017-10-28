from os import listdir
from os.path import isfile,isdir,join
from distutils.dir_util import copy_tree 
hr_walk_dir="/scratch/PI/euan/projects/mhc/data/6mwt/heart_rate_walk_dir"
hr_rest_dir="/scratch/PI/euan/projects/mhc/data/6mwt/heart_rate_rest_dir"
hr_walk_filtered_dir="/scratch/PI/euan/projects/mhc/data/6mwt/heart_rate_walk_dir_FILTERED"
hr_rest_filtered_dir="/scratch/PI/euan/projects/mhc/data/6mwt/heart_rate_rest_dir_FILTERED"

subject_dict=dict()

walk_subject_dirs=[d for d in listdir(hr_walk_dir)if isdir(join(hr_walk_dir,d))]
rest_subject_dirs=[d for d in listdir(hr_rest_dir) if isdir(join(hr_rest_dir,d))]
print("got walk_subject_dirs and rest_subject_dirs") 
for subject in walk_subject_dirs:
    test_files=[f for f in listdir(join(hr_walk_dir,subject)) if isfile(join(hr_walk_dir,subject,f))]
    for f in test_files:
        data=open(join(hr_walk_dir,subject,f)).read()
        if ((data.startswith('null')==False) and (len(data)>3)):
            print(join(hr_walk_dir,subject))
            copy_tree(join(hr_walk_dir,subject),join(hr_walk_filtered_dir,subject))
            if subject not in subject_dict:
                subject_dict[subject]=dict()
            subject_dict[subject]['walk']=True
            
print("copied over walk dirs with hr data")

for subject in rest_subject_dirs:
    test_files=[f for f in listdir(join(hr_rest_dir,subject)) if isfile(join(hr_rest_dir,subject,f))]
    for f in test_files:
        data=open(join(hr_rest_dir,subject,f)).read()
        if ((data.startswith('null')==False) and (len(data)>3)):
            print(f) 
            copy_tree(join(hr_rest_dir,subject),join(hr_rest_filtered_dir,subject))
            if subject not in subject_dict:
                subject_dict[subject]=dict()
            subject_dict[subject]['rest']=True
outf=open("SubjectsWithHeartRateDataFor6MW.txt",'w')
outf.write("Subject\tWalkHR\tRestHR\n")
for subject in subject_dict:
    outf.write(subject)
    if "walk" in subject_dict[subject]:
        outf.write('\tTrue')
    else:
        outf.write('\tFalse')
    if "rest" in subject_dict[subject]:
        outf.write('\tTrue')
    else:
        outf.write('\tFalse')
    outf.write('\n')
    
        


