import sys 

#CONVERSION FACTORS 
conversion_dict=dict() 
conversion_dict[0.70]=4.686
conversion_dict[0.71]=4.690 
conversion_dict[0.72]=4.702
conversion_dict[0.73]=4.714
conversion_dict[0.74]=4.727
conversion_dict[0.75]=4.739
conversion_dict[0.76]=4.751
conversion_dict[0.77]=4.764
conversion_dict[0.78]=4.776
conversion_dict[0.79]=4.788
conversion_dict[0.80]=4.801
conversion_dict[0.81]=4.813
conversion_dict[0.82]=4.824
conversion_dict[0.83]=4.838
conversion_dict[0.84]=4.850 
conversion_dict[0.85]=4.862
conversion_dict[0.86]=4.875
conversion_dict[0.87]=4.887
conversion_dict[0.88]=4.899
conversion_dict[0.89]=4.911
conversion_dict[0.90]=4.924
conversion_dict[0.91]=4.936
conversion_dict[0.92]=4.948
conversion_dict[0.93]=4.961
conversion_dict[0.94]=4.973
conversion_dict[0.95]=4.985
conversion_dict[0.96]=4.998
conversion_dict[0.97]=5.010
conversion_dict[0.98]=5.022
conversion_dict[0.99]=5.035
conversion_dict[1.00]=5.047

#ADD A COLUMN FOR 
data=open(sys.argv[1],'r').read().split('\n')
header=data[0].split('\t') 
vo2_col_index=header.index("VO2") 
rer_index=header.index('R') 

outf=open(sys.argv[1]+".WITHENERGY",'w')
outf.write('\t'.join(header)+'\t'+'Energy'+'\n')
outf.write(data[1]+'\t'+'kcal\min'+'\n') 
for line in data[2::]: 
    tokens=line.split('\t') 
    if len(tokens)==1: 
        continue 
    vo2=tokens[vo2_col_index]
    if vo2=="": 
        continue 
    if tokens[rer_index]=="": 
        continue 
    rer=round(float(tokens[rer_index]),2)
    rer=min(rer,1.00)
    rer=max(rer,0.70)
    multiplier=conversion_dict[rer] 
    energy=multiplier*(float(vo2)/1000)
    outf.write(line+'\t'+str(round(energy,1))+'\n')
