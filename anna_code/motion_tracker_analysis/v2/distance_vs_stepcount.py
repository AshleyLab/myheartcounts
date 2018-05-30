import argparse
def parse_args():
    parser=argparse.ArgumentParser(description="plot step count vs distance travelled")
    parser.add_argument("--distance_file")
    parser.add_argument("--step_file")
    parser.add_argument("--outf")
    return parser.parse_args()

def main():
    args=parse_args()
    distance_data=open(args.distance_file,'r').read().strip().split('\n')
    step_data=open(args.step_file,'r').read().strip().split('\n')
    subject_dict=dict()
    for line in step_data[1::]:
        tokens=line.split('\t')
        subject=tokens[0]
        if tokens[1]=="NA":
            state="NA"
        else:
            state=tokens[2]
        if state=="NA": 
            state="NotEnrolled"
        step_count=tokens[6]
        day=tokens[3]
        if subject not in subject_dict:
            subject_dict[subject]=dict()
        if day not in subject_dict[subject]:
            subject_dict[subject][day]=dict()
        subject_dict[subject][day]['steps']=step_count
        subject_dict[subject][day]['intervention']=state
    for line in distance_data[1::]:
        tokens=line.split('\t')
        subject=tokens[0]
        if tokens[1]=="NA":
            state="NA"
        else:
            state=tokens[2]
        if state=="NA": 
            state="NotEnrolled"
        distance=tokens[6]
        day=tokens[3]
        if subject not in subject_dict:
            subject_dict[subject]=dict()
        if day not in subject_dict[subject]:
            subject_dict[subject][day]=dict()
        subject_dict[subject][day]['distance']=distance
        subject_dict[subject][day]['intervention']=state
    outf=open(args.outf,'w')
    outf.write("Distance\tSteps\tIntervention\n")
    for subject in subject_dict:
        for day in subject_dict[subject]:
            if 'distance' in subject_dict[subject][day]: 
                cur_distance=subject_dict[subject][day]['distance']
            else:
                continue 
            if "steps" in subject_dict[subject][day]: 
                cur_steps=subject_dict[subject][day]['steps']
            else:
                continue
            intervention=subject_dict[subject][day]['intervention']
            outf.write(cur_distance+'\t'+cur_steps+'\t'+intervention+'\n')
            
    
if __name__=="__main__":
    main()
    
