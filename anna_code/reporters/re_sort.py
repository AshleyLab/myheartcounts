import sys 
data=open(sys.argv[1],'r').read().split('\n') 
while '' in data: 
    data.remove('') 
map_dict=dict() 
map_dict['1']='1'
map_dict['4']='2'
map_dict['2']='3' 
map_dict['3']='4'
map_dict['5']='5' 
outf=open(sys.argv[2],'w') 
for line in data: 
    tokens=line.split('\t') 
    tokens[2]=map_dict[tokens[2]]
    outf.write('\t'.join(tokens)+'\n') 
