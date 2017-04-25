sample=open('imdb_truth_data.txt','r').read().split('\n')
while '' in sample:
    sample.remove('')
stats=open('ssa_national_summary.txt','r').read().split('\n')
while '' in stats:
    stats.remove('')
###########################################################
outf=open('qc_results.txt','w')
stat_dict=dict() 
for line in stats[1::]:
    line=line.split('\t') 
    name=line[0] 
    stat_dict[name]=line[1::] 
notfound=0 
#keep track of  how many predictions were correct at each confidence level 
correct_age_10=dict()
correct_age_IQR=dict() 
correct_sex=dict()

tp_males=dict()
fp_males=dict()

total_age=dict()
total_sex=dict()

confidence_vals=set() 

for line in sample[1::]:
    #print str(line) 
    line=line.split('\t')
    name=line[1] 
    if name not in stat_dict: 
        notfound+=1
        print str(name) 
    else: 
        predicted=stat_dict[name]
        true_age=int(line[3])
        if true_age > 100:
            continue 
        true_sex=line[2] 
        predicted_males=int(predicted[0]) 
        predicted_females=int(predicted[1]) 
        predicted_total=int(predicted[2]) 
        predicted_median=float(predicted[3])
        predicted_25=float(predicted[4]) 
        predicted_75=float(predicted[5]) 
        confidence=predicted_total #CONFIDENCE DEFINED AS TOTAL NUMBER OF SUBJECTS
        #print str(confidence) 
        confidence_vals.add(confidence) 
        if confidence not in total_age:
            total_age[confidence]=1
        else:
            total_age[confidence]+=1
        if confidence not in total_sex:
            total_sex[confidence]=1
        else:
            total_sex[confidence]+=1
        if predicted_males> predicted_females:
            predicted_sex="M"
        else:
            predicted_sex="F"
        if predicted_sex==true_sex:
            if confidence not in correct_sex:
                correct_sex[confidence]=1
            else:
                correct_sex[confidence]+=1
        if (predicted_sex=="M") and (true_sex=="M"):
            if confidence not in tp_males:
                tp_males[confidence]=1
            else:
                tp_males[confidence]+=1
        if (predicted_sex=="M") and (true_sex=="F"):
            if confidence not in fp_males:
                fp_males[confidence]=1
            else:
                fp_males[confidence]+=1
                    
        delta_age=abs(predicted_median-true_age)
        if delta_age<11:
            if confidence not in correct_age_10:
                correct_age_10[confidence]=1
            else:
                correct_age_10[confidence]+=1
        if (true_age >=predicted_25) and (true_age <= predicted_75):
            if confidence not in correct_age_IQR:
                correct_age_IQR[confidence]=1
            else:
                correct_age_IQR[confidence]+=1
#WRITE THE RESULTS
outf.write("Confidence\tCorrectSex\tTotalSex\tCorrectAge10Years\tCorrectAgeInIQR\tTotalAge\tTruePosMales\tFalsePosMales\n")
for confidence in confidence_vals:
    if confidence not in correct_sex:
        correct_sex_value=0
    else:
        correct_sex_value=correct_sex[confidence]
    if confidence not in correct_age_10:
        correct_age_10_value=0
    else:
        correct_age_10_value=correct_age_10[confidence]
    if confidence not in correct_age_IQR:
        correct_age_iqr_value=0
    else:
        correct_age_iqr_value=correct_age_IQR[confidence]
    if confidence not in tp_males:
        tp_male_value=0
    else:
        tp_male_value=tp_males[confidence]
    if confidence not in fp_males:
        fp_male_value=0
    else:
        fp_male_value=fp_males[confidence]
    
    outf.write(str(confidence)+'\t'+str(correct_sex_value)+'\t'+str(total_sex[confidence])+'\t'+str(correct_age_10_value)+'\t'+str(correct_age_iqr_value)+'\t'+str(total_age[confidence])+'\t'+str(tp_male_value)+'\t'+str(fp_male_value)+'\n')
    
