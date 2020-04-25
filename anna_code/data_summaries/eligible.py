data=open('age.new','r').read().strip().split('\n') 
good=0 
low=0 
high=0 
for line in data: 
    if float(line) < 40: 
        low+=1 
    elif float(line)> 79: 
        high+=1 
    else: 
        good+=1 
print "low:"+str(low) 
print "high:"+str(high) 
print "good:"+str(good) 
