import sys 

def main(): 

    oldfile=open(sys.argv[1],'r').read().split('\n') 
    if '' in oldfile: 
        oldfile.remove('') 

    newfile=open(sys.argv[2],'r').read().split('\n')
    if '' in newfile: 
        newfile.remove('') 
    
    all_ages=dict() 
    nummales=0 
    numfemales=0 
    num_known_age=0 
    num_known_sex=0

    #unknown in old dataset, known in new dataset
    num_new_age=0 
    num_new_sex=0 

    old_data=dict() 


    for line in oldfile[2::]: 
        line=line.split('\t') 
        person=line[0] 
        age=line[1] 
        sex=line[3] 
        old_data[person]=[age,sex] 
    
    for line in newfile[2::]: 
        line=line.split('\t') 
        person=line[0] 
        age=line[1] 
        sex=line[3] 
        if sex=="Male": 
            nummales+=1 
            num_known_sex+=1 
        elif sex=="Female": 
            numfemales+=1 
            num_known_sex+=1 
        if age!="NA": 
            if age not in all_ages: 
                all_ages[age]=1 
            else: 
                all_ages[age]+=1 
            num_known_age+=1 
        #check against old data 
        if age!="NA":
            if person in old_data: 
                print str(old_data[person]) 
                oldvals=old_data[person] 
                old_age=oldvals[0] 
                old_sex=oldvals[1] 
                if old_age=="NA": 
                    num_new_age+=1 
                if (old_sex=="NA") and (sex!="NA"): 
                    num_new_sex+=1 
    print "Males:"+str(nummales)
    print "Females:"+str(numfemales) 
    print "Known Age:"+str(num_known_age) 
    print "Known Sex:"+str(num_known_sex) 
    print "New Age:"+str(num_new_age) 
    print "New Sex:"+str(num_new_sex) 
    outf=open('age_hist.txt','w') 
    ages=[int(i) for i in all_ages.keys()] 
    ages.sort() 
    for age in ages: 
        outf.write(str(age)+'\t'+str(all_ages[str(age)])+'\n')

if __name__=="__main__": 
    main() 
