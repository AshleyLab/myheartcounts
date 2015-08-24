import math 

#Estimates 10 year risk score & heart age for MHC subjects from the "NonTimeSeries.txt" file (passed in as the parameter) 
from Parameters import * 

#coefficients and formula from doi:10.1161/01.cir.0000437741.48606.98
coefficient_file="coefficients_10year_risk.csv"
baseline_file="baseline_life_expectancies.csv"


#Get the limits for all values 
limits=dict() 
limits['age']=[20,79] 
limits['totalchol']=[130,320]
limits['hdl']=[20,100] 
limits['systolicbp']=[90,200]

#Optimal values 
optimal=dict() 
optimal['totalchol']=170
optimal['hdl']=50 
optimal['systolicbp']=110 
optimal['diabetes']='FALSE' 
optimal['smoking']='FALSE' 
optimal['hypertension']='FALSE' 

def get_coefficients(): 
    coef_dict=dict() 
    data=open(coefficient_file,'r').read().split('\n')
    if '' in data:
        data.remove('')
    sexvals=data[0].split('\t')
    racevals=data[1].split('\t')
    for line in data[2::]:
        line=line.split('\t')
        feature=line[0]
        for i in range(1,len(racevals)):
            race=racevals[i]
            sex=sexvals[i]
            if race not in coef_dict:
                coef_dict[race]=dict()
            if sex not in coef_dict[race]:
                coef_dict[race][sex]=dict()
            coef_dict[race][sex][feature]=float(line[i]) 
    return coef_dict 

#calculates baseline survival rates for 10 years out from subject's current age. 
def get_baseline():
    baseline_dict=dict() 
    data=open(baseline_file,'r').read().split('\n')
    if '' in data: 
        data.remove('')
    racevals=data[0].split('\t')
    sexvals=data[1].split('\t')
    for line in data[2::]:
        line=line.split('\t')
        age=int(line[0])
        for i in range(6,len(racevals)):
            race=racevals[i]
            sex=sexvals[i]
            if race not in baseline_dict:
                baseline_dict[race]=dict()
            if sex not in baseline_dict[race]:
                baseline_dict[race][sex]=dict()
            baseline_dict[race][sex][age]=float(line[i])/1000
    outf=open('baseline.txt','w')
    outf.write('Race\tSex\tAge\tBaseline\n')
    for race in baseline_dict:
        for sex in baseline_dict[race]:
            for age in baseline_dict[race][sex]:
                survival=baseline_dict[race][sex][age]
                outf.write(race+'\t'+sex+'\t'+str(age)+'\t'+str(survival)+'\n')
    return baseline_dict 

def parse_inputs(): 
    data=open(survey_summary_file,'r').read().split('\n') 
    if '' in data: 
        data.remove('') 
    subject_dict=dict() 

    #GET INDICES FOR FIELDS USED TO CALCULATE HEART AGE! 
    header=data[1].split('\t') 
    cholesterol_index=header.index('heartAgeDataTotalCholesterol') 
    age_index=header.index('Age') 
    sex_index=header.index('Sex') 
    race_index=header.index('heartAgeDataEthnicity') 
    cholesterol_index=header.index('heartAgeDataTotalCholesterol') 
    hdl_index=header.index('heartAgeDataHdl') 
    diastolic_bp_index=header.index('heartAgeDataSystolicBloodPressure') #MIGHT BE MIXUP WITH BLOOD PRESSURE INSTRUCTION systolic_bp_index=header.index('bloodPressureInstruction')
    systolic_bp_index=header.index("bloodPressureInstruction") #NOT USED FOR 10 year risk, but is used for lifetime risk
    hypertension_index=header.index('heartAgeDataHypertension')
    diabetes_index=header.index('heartAgeDataDiabetes') 
    smoking_index=header.index('smokingHistory')
    meds_index=header.index('medications_to_treat')
    rf1=header.index('riskfactors1')
    rf2=header.index('riskfactors2')
    rf3=header.index('riskfactors3')
    rf4=header.index('riskfactors4') 
    labels=['age','sex','race','totalchol','hdl','systolicbp','diabetes','smoking','hypertension','meds','diastolic','riskfactors1','riskfactors2','riskfactors3','riskfactors4']
    
    indices=[age_index,sex_index,race_index,cholesterol_index,hdl_index,systolic_bp_index,diabetes_index,smoking_index,hypertension_index,meds_index,diastolic_bp_index,rf1,rf2,rf3,rf4 ]
    print str(len(labels))
    print str(len(indices))
    
    for line in data[2::]: 
        line=line.split('\t') 
        subject=line[0]
        subdict=dict()
        skip=False 
        for i in range(len(labels)): 
            label=labels[i] 
            indexval=indices[i]
            value=line[indexval]
            if value=="":
                skip=True 
                continue 
            if value=="NA":
                skip=True 
                continue #subject must have all values for 10year risk calculation 
            if label=="sex":
                if value=="Other":
                    skip=True 
                    continue # not sure how to handle individuals who identify as "Other"
            #make sure the values are within the allowed limits for analysis!!
            if label=="age":
                value=int(value) 
                value=max([value,limits['age'][0]])
                value=min([value,limits['age'][1]])
            elif label=="totalchol":
                value=float(value) 
                value=max([value,limits['totalchol'][0]])
                value=min([value,limits['totalchol'][1]])
            elif label=="hdl":
                value=float(value) 
                value=max([value,limits['hdl'][0]])
                value=min([value,limits['hdl'][1]])
            elif label=="systolicbp":
                value=float(value) 
                value=max([value,limits['systolicbp'][0]])
                value=min([value,limits['systolicbp'][1]])
            elif label=="diastolic":
                value=float(value)
            elif label=="riskfactors1":
                value=float(value)
            elif label=="riskfactors2":
                value=float(value)
            elif label=="riskfactors3":
                value=float(value)
            elif label=="riskfactors4":
                value=float(value)
                
            subdict[label]=value
        if len(subdict.keys())==15:
            subject_dict[subject]=subdict 
    return subject_dict   

def get_10year_baseline(baseline_vals,age,sex,race):
    age=int(age)
    #print "age:"+str(age) 
    endval=age+10
    subdict=baseline_vals[race][sex]
    #print "subdict:"+str(subdict) 
    max_pre=0
    min_post=100
    between_keys=[] 
    for entry in subdict:
        if entry<=age:
            if entry>=max_pre:
                max_pre=entry
        elif entry>=endval:
            if entry<min_post:
                min_post=entry
        else:
            between_keys.append(entry)
    between_keys.append(max_pre)
    between_keys.append(min_post)
    between_keys.sort()
    print "between keys:"+str(between_keys) 
    survival=1
    for k in between_keys:
        survival=survival*(1-float(subdict[k]))
    if race=="White":
        if sex=="Male":
            return 0.9144
        else:
            return 0.9665
    else:
        if sex=="Male":
            return 0.8954
        else:
            return 0.9533
    #return survival 

#from Lloyd-Jones et al, doi: 10.1161/CIRCULATIONAHA.105.548206
def calculate_lifetime_risk(subject_dict):
    non_optimal_risk_factors=0
    elevated_risk_factors=0
    major_risk_factors=0
    
    #get the parameters for the subject 
    age=subject_dict['age']
    sex=subject_dict['sex']
    chol=float(subject_dict['totalchol'])
    hdl=float(subject_dict['hdl'])
    systolicbp=float(subject_dict['systolicbp'])
    diastolicbp=float(subject_dict['diastolic']) 
    diabetes=subject_dict['diabetes']
    smoking=subject_dict['smoking']
    hypertension=subject_dict['hypertension']
    meds=subject_dict['meds']
    #Major risk factors 
    if smoking=="TRUE":
        major_risk_factors+=1
    if diabetes=="TRUE":
        major_risk_factors+=1
    if str(meds)==2:
        major_risk_factors+=1 
    if (chol >=240):
        major_risk_factors+=1
    if (systolicbp >=160):
        major_risk_factors+=1
    if (diastolicbp >=100):
        major_risk_factors+=1
        
    #Non-optimal risk factors 
    if (chol >=180) and (chol<=199): 
        non_optimal_risk_factors+=1
    if (systolicbp >=120) and (systolicbp <=139):
        non_optimal_risk_factors+=1
    if (diastolicbp >=80) and (diastolicbp<=89):
        non_optimal_risk_factors+=1
        
    #Elevated risk factors 
    if (chol >=200) and (chol<=239): 
        elevated_risk_factors+=1
    if (systolicbp >=140) and (systolicbp <=159):
        elevated_risk_factors+=1
    if (diastolicbp >=90) and (diastolicbp<99):
        elevated_risk_factors+=1

    #Risk based on number and severity of predictors
    #prediction returned as [75 year risk, 95 year risk]
    #all optimal
    if sum([non_optimal_risk_factors,elevated_risk_factors,major_risk_factors])==0:
        if sex=="Male":
            return [5.2,5.27]
        else:
            return [8.2,8.2]
    elif sum([elevated_risk_factors,major_risk_factors])==0:
        if sex=="Male":
            return [17.6,36.4]
        else:
            return [6.9,26.9]
    elif major_risk_factors==0:
        if sex=="Male":
            return [26.0,45.5]
        else:
            return [14.6,39.1]
    elif major_risk_factors==1:
        if sex=="Male":
            return [37.6,50.4]
        else:
            return [18.0,38.8]
    else:
        if sex=="Male":
            return [53.2,68.9]
        else:
            return [37.7,50.2]


def calculate_10year_risk_components(subject_dict,coefficients,baseline_vals):
    #get the parameters for the subject
    #print str(subject_dict) 
    age=subject_dict['age']
    sex=subject_dict['sex']
    race=subject_dict['race']
    if race!="Black":
        race="White" #Formula for "White" will be used for anyone who does not self-identify as Black
    chol=subject_dict['totalchol']
    hdl=subject_dict['hdl']
    systolicbp=subject_dict['systolicbp']
    diabetes=subject_dict['diabetes']
    smoking=subject_dict['smoking']
    hypertension=subject_dict['hypertension']
    print str(subject_dict) 
    meds=subject_dict['meds']
    
    baseline=get_10year_baseline(baseline_vals,age,sex,race)
    return calculate_10year_risk_components_subroutine(age,sex,race,chol,hdl,systolicbp,diabetes,smoking,hypertension,meds,coefficients,baseline)

#derives a lookup table for 10year risk using optimal values
def calculate_optimal(baseline_dict,average_components,coefficients):
    optimal_dict=dict()
    for race in ['Black','White']:
        optimal_dict[race]=dict() 
        for sex in ['Male','Female']:
            optimal_dict[race][sex]=dict() 
            for age in range(20,100):
                baseline=get_10year_baseline(baseline_dict,age,sex,race)
                values=calculate_10year_risk_components_subroutine(age,sex,race,optimal['totalchol'],optimal['hdl'],optimal['systolicbp'],optimal['diabetes'],optimal['smoking'],optimal['hypertension'],1,coefficients,baseline)
                #print str(values)
                riskval=calculate_10year_risk(values,average_components)
                if riskval in optimal_dict[race][sex]:
                    optimal_dict[race][sex][riskval].append(age)
                else:
                    optimal_dict[race][sex][riskval]=[age]
    #print "OPTIMAL DICT:"+str(optimal_dict)
    #FOR TESTING:
    outf=open('optimal_10year.txt','w')
    outf.write('Race\tSex\tAge\tRisk\n')
    for race in optimal_dict:
        for sex in optimal_dict[race]:
            for riskval in optimal_dict[race][sex]:
                ages=optimal_dict[race][sex][riskval] 
                outf.write(race+'\t'+sex+'\t'+','.join([str(i) for i in ages])+'\t'+str(riskval)+'\n')
    return optimal_dict 
    
    
def calculate_10year_risk_components_subroutine(age,sex,race,chol,hdl,systolicbp,diabetes,smoking,hypertension,meds,coefficients,baseline):
    ln_age=math.log(int(age))
    ln_age_coef=coefficients[race][sex]['ln_age']
    product1=ln_age*float(ln_age_coef) 
    #print "product1:"+str(product1)
    
    ln_age_squared=ln_age*ln_age
    ln_age_squared_coef=coefficients[race][sex]['ln_age_squared']
    product2=ln_age_squared*float(ln_age_squared_coef) 
    #print "product2:"+str(product2)
    
    ln_chol=math.log(int(chol))
    ln_chol_coef=coefficients[race][sex]['ln_chol']
    product3=ln_chol*float(ln_chol_coef) 
    #print "product3:"+str(product3)
    
    ln_age_ln_chol=ln_age*ln_chol
    ln_age_ln_chol_coef=coefficients[race][sex]['ln_age_ln_chol']
    product4=ln_age_ln_chol*float(ln_age_ln_chol_coef)
    #print "product4:"+str(product4)
    
    ln_hdl=math.log(int(hdl))
    ln_hdl_coef=coefficients[race][sex]['ln_hdl']
    product5=ln_hdl*float(ln_hdl_coef)
    #print "product5:"+str(product5) 
    
    ln_age_ln_hdl=ln_age*ln_hdl
    ln_age_ln_hdl_coef=coefficients[race][sex]['ln_age_ln_hdl']
    product6=ln_age_ln_hdl*float(ln_age_ln_hdl_coef)
    #print "product6:"+str(product6) 

    #do they have a treatment for hypertension?
    if (hypertension=="TRUE") and (meds=="2"):
        #have treated hypertension
        ln_treated_systolic=math.log(int(systolicbp))
        ln_treated_systolic_coef=coefficients[race][sex]['ln_treated_systolic']
        product7=float(ln_treated_systolic_coef)*ln_treated_systolic
        
        ln_age_ln_treated_systolic=ln_age*ln_treated_systolic
        ln_age_ln_treated_systolic_coef=coefficients[race][sex]['ln_age_ln_treated_systolic']
        product8=ln_age_ln_treated_systolic*float(ln_age_ln_treated_systolic_coef)
    else:
        #does not have treated hypertension
        ln_untreated_systolic=math.log(int(systolicbp))
        ln_untreated_systolic_coef=coefficients[race][sex]['ln_untreated_systolic']
        product7=float(ln_untreated_systolic_coef)*ln_untreated_systolic

        ln_age_ln_untreated_systolic=ln_age*ln_untreated_systolic
        ln_age_ln_untreated_systolic_coef=coefficients[race][sex]['ln_age_ln_untreated_systolic']
        product8=ln_age_ln_untreated_systolic*float(ln_age_ln_untreated_systolic_coef)
    #print "product7:"+str(product7)
    #print "product8:"+str(product8)
    
    if smoking=="TRUE":
        smoking=1
    else:
        smoking=0
    smoker_coef=coefficients[race][sex]['smoker']
    product9=smoking*float(smoker_coef)
    #print "product9:"+str(product9) 
    ln_age_smoker=ln_age*smoking
    ln_age_smoker_coef=coefficients[race][sex]['ln_age_smoker']
    product10=ln_age_smoker*float(ln_age_smoker_coef)
    #print "product10:"+str(product10)
    
    if diabetes=="TRUE":
        diabetes=1
    else:
        diabetes=0
    diabetes_coef=coefficients[race][sex]['diabetes']
    product11=diabetes*diabetes_coef
    #print "product11:"+str(product11)
    
    individual_sum=sum([product1,product2,product3,product4,product5,product6,product7,product8,product9,product10,product11])
    #print "individual sum:"+str(individual_sum)
    
    #group_mean=mean_vals[race][sex]
    #print "group mean:"+str(group_mean)

    #print "baseline:"+str(baseline) 
    #risk=(1-baseline)*math.exp(individual_sum-group_mean)
    #print "10-year risk:"+str(risk) 
    #return risk
    return [race,age,sex,individual_sum,baseline] 


def get_heart_age(subject_dict,risk_10year,optimal_vals):
    age=subject_dict['age']
    sex=subject_dict['sex']
    race=subject_dict['race']
    if race!="Black":
        race="White" #Formula for "White" will be used for anyone who does not self-identify as Black
    optimal_vals=optimal_vals[race][sex]
    #print 'risk10year:'+str(risk_10year) 
    min_age_for_risk=100 
    for riskval in optimal_vals:
        #print "riskval:"+str(riskval) 
        if riskval >=risk_10year:
            #print " riskval >=risk_10year" 
            age_for_risk=optimal_vals[riskval]
            #print "age_for_risk:"+str(age_for_risk) 
            if min(age_for_risk) < min_age_for_risk:
                min_age_for_risk=min(age_for_risk)
    #print "MIN AGE FOR RISK:"+str(min_age_for_risk) 
    return min_age_for_risk
                
def get_heart_age_OLD(subject_dict,risk_10year,coef_dict,baseline_vals,average_components):
    age=subject_dict['age']
    sex=subject_dict['sex']
    race=subject_dict['race']
    
    if race!="Black":
        race="White" #Formula for "White" will be used for anyone who does not self-identify as Black
    c=math.log(optimal['totalchol'])*coef_dict[race][sex]['ln_chol']
    chol=optimal['totalchol'] 
    h=math.log(optimal['hdl'])*coef_dict[race][sex]['ln_hdl']
    hdl=optimal['hdl'] 
    s=math.log(optimal['systolicbp'])*coef_dict[race][sex]['ln_untreated_systolic']
    systolic=optimal['systolicbp'] 
    baseline=get_10year_baseline(baseline_vals,age,sex,race)
    group_mean=average_components[race][sex][age] 
    #group_mean=mean_vals[race][sex]
    #Use quadratic formula to get ln(HeartAge) for women
    if sex=="Female": 
        A=coef_dict[race][sex]['ln_age_squared']
        B=coef_dict[race][sex]['ln_age']+coef_dict[race][sex]['ln_age_ln_chol']*math.log(chol)+coef_dict[race][sex]['ln_age_ln_hdl']*math.log(hdl) + coef_dict[race][sex]['ln_age_ln_untreated_systolic']*math.log(systolic)
        print "risk:"+str(risk_10year)
        print "1-baseline:"+str(1-baseline)
        print "group mean:"+str(group_mean)
        print "c:"+str(c)
        print "h:"+str(h)
        print "s:"+str(s)
        
        C=-math.log(risk_10year)+math.log(1-baseline)-group_mean+c+h+s
        print "A:"+str(A)
        print "B:"+str(B)
        print "C:"+str(C) 
        heart_age=math.exp((-1*B+math.sqrt(B*B-4*A*C))/2*A)
        heart_age_minus=math.exp((-1*B-math.sqrt(B*B-4*A*C))/2*A)
        print "girl heart age+:"+str(heart_age)
        print "girl heart age-:"+str(heart_age_minus) 
    else:
        #Different formula to calculate heart age for men
        heart_age=math.exp((group_mean+math.log(1-risk_10year)/math.log(baseline)-c-h-s)*(1.0/(c+h+coef_dict[race][sex]['ln_age'])))
    return heart_age 

def get_average_components(component_dict):
    mean_components=dict()
    for subject in component_dict:
        race=component_dict[subject][0]
        age=component_dict[subject][1]
        sex=component_dict[subject][2]
        component_sum=component_dict[subject][3]
        if race not in mean_components:
            mean_components[race]=dict()
        if sex not in mean_components[race]:
            mean_components[race][sex]=dict()
        ages=range(age-5,age+6)
        if 30 in ages:
            ages.remove(30) 
        for age in ages:
            if age not in mean_components[race][sex]:
                mean_components[race][sex][age]=[component_sum]
            else:
                mean_components[race][sex][age].append(component_sum)
    for race in mean_components:
        for sex in mean_components[race]:
            for age in mean_components[race][sex]:
                if race=="White":
                    if sex=="Male":
                        mean_components[race][sex][age]=61.18
                    else:
                        mean_components[race][sex][age]=-29.18
                else:
                    if sex=="Male":
                        mean_components[race][sex][age]=19.54
                    else:
                        mean_components[race][sex][age]=86.61
                #mean_components[race][sex][age]=sum(mean_components[race][sex][age])/len(mean_components[race][sex][age])
    #Fill in any missing values for age with the immediately preceding age value
    last_age=None
    for race in ['Black','White']:
        for sex in ['Male','Female']: 
            for age in range(20,100):
                if age in mean_components[race][sex]:
                    last_age=age
                else:
                    #print "ELSE:"+str(age) 
                    mean_components[race][sex][age]=mean_components[race][sex][last_age]
                    #print str(mean_components[race][sex][age])
    return mean_components

def calculate_10year_risk(values,average_components):
    race=values[0]
    age=values[1]
    sex=values[2]
    component_sum=values[3]
    baseline=values[4]
    #print "race:"+str(race)+", sex:"+str(sex)+", age:"+str(age) 
    mean_val=average_components[race][sex][age]
    risk=(1-baseline)*math.exp(component_sum-mean_val)
    risk=min([0.99,risk])
    #print "race:"+str(race)+","+"age:"+str(age)+","+"sex:"+str(sex)+","+"risk:"+str(risk)+","+"component_sum:"+str(component_sum)+","+"mean_val:"+str(mean_val)  
    return round(risk*100,2) 
    
def main(): 
    subject_dict=parse_inputs()
    coef_dict=get_coefficients()
    baseline_dict=get_baseline()
    result_dict=dict() 
    component_dict=dict() 
    for subject in subject_dict: 
        risk_10year_components=calculate_10year_risk_components(subject_dict[subject],coef_dict,baseline_dict)
        component_dict[subject]=risk_10year_components 
    average_components=get_average_components(component_dict)
    optimal_dict=calculate_optimal(baseline_dict,average_components,coef_dict) 
    for subject in component_dict:
        risk_10year=calculate_10year_risk(component_dict[subject],average_components)
        lifetime_risk=calculate_lifetime_risk(subject_dict[subject])
        heart_age=get_heart_age(subject_dict[subject],risk_10year,optimal_dict)        
        result_dict[subject]=[subject_dict[subject]['age'],risk_10year,lifetime_risk[0],lifetime_risk[1],heart_age]
    outf=open('HeartAgeRelatedPredictions.txt','w')

    outf.write('Subject\tAge\t10YearRisk\tLifetimeRisk75\tLifetimeRisk95\tHeartAge\tSex\tRace\tTotalCholesterol\tHDL\tSystolicBP\tDiabetes\tSmoking\tHypertension\tMeds\tDiastolic\tRiskFactors1\tRiskFactors2\tRiskFactors3\tRiskFactors4\n')
    for subject in result_dict:
        outf.write(subject+'\t'+'\t'.join([str(i) for i in result_dict[subject]])+'\t'+subject_dict[subject]['sex']+'\t'+str(subject_dict[subject]['race'])+'\t'+str(subject_dict[subject]['totalchol'])+'\t'+str(subject_dict[subject]['hdl'])+'\t'+str(subject_dict[subject]['systolicbp'])+'\t'+str(subject_dict[subject]['diabetes'])+'\t'+str(subject_dict[subject]['smoking'])+'\t'+str(subject_dict[subject]['hypertension'])+'\t'+str(subject_dict[subject]['meds'])+'\t'+str(subject_dict[subject]['diastolic'])+'\t'+str(subject_dict[subject]['riskfactors1'])+'\t'+str(subject_dict[subject]['riskfactors2'])+'\t'+str(subject_dict[subject]['riskfactors3'])+'\t'+str(subject_dict[subject]['riskfactors4'])+'\n')
        
        
if __name__=="__main__": 
    main() 
