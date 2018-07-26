data=open('age.new','r').read().split('\n') 
while '' in data: 
    data.remove('') 
age=[float(i) for i in age] 
