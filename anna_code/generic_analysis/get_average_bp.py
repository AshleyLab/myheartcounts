data=open('blood_pressure','r').read().split('\n')
data.remove('') 
sub_dict=dict()
all_bp1=[]
all_bp2=[] 
for line in data[1::]:
    line=line.split('\t')
    subject=line[0]
    print str(line)
    print 'line 1:'+str(line[1])
    print 'line 2:'+str(line[2])
    if line[1]=="":
        continue
    if line[1].__contains__('NA'):
            continue
    if line[2].__contains__('NA'):
            continue
    bp1=[float(i) for i in line[1].split(',')]
    bp1=sum(bp1)/float(len(bp1))
    bp2=[float(i) for i in line[2].split(',')]
    bp2=sum(bp2)/float(len(bp2))
    sub_dict[subject]=[bp1,bp2]
    all_bp1.append(bp1)
    all_bp2.append(bp2)

outf=open('bp.summary','w')
outf.write('subject\tinstruction\tsystolic\n')
for s in sub_dict:
    outf.write(s+'\t'+str(sub_dict[s][0])+'\t'+str(sub_dict[s][1])+'\n')
mean_inst=sum(all_bp1)/float(len(all_bp1))
mean_sys=sum(all_bp2)/float(len(all_bp2))
print "instruction_mean:"+str(mean_inst)
print "systolic_mean:"+str(mean_sys)
