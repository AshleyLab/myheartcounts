all_subjects=open('../subjects.txt','r').read().split('\n') 
if '' in all_subjects: 
    all_subjects.remove('')
dem_subjects=open('../dem.subjects','r').read().split('\n') 
if '' in dem_subjects: 
    dem_subjects.remove('') 
heart_subjects=open('../heart.subjects','r').read().split('\n') 
if '' in heart_subjects: 
    heart_subjects.remove('') 
heart_subjects=set(heart_subjects) 
dem_subjects=set(dem_subjects) 
all_subjects=set(all_subjects) 

both=heart_subjects.intersection(dem_subjects) 
dem_heart_union=heart_subjects.union(dem_subjects) 
neither=all_subjects - dem_heart_union 
only_heart=heart_subjects - dem_subjects 
only_dem = dem_subjects - heart_subjects 
print "total:"+str(len(all_subjects))
print "both"+str(len(both)) 
print "neither:"+str(len(neither) )
print "only heartage:"+str(len(only_heart)) 
print "only dem:"+str(len(only_dem)) 

