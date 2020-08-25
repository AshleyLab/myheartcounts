library(synapser)
library(tidyverse)
library(lubridate)
library(zipcode)
data(zipcode)
uk_zipcodes <- read.csv('uk.postcodes')

#takes in table data from synapse and stores relevant columns
read_syn_table <- function(syn_id) {
  q <- synTableQuery(paste('select "healthCode","recordId","createdOn",',
                           '"appVersion","phoneInfo"',
                           'from', syn_id))
  return(q$asDataFrame()) #stores synapse table data as a dataframe within R
}

#takes in dataframe, adds two new columns (id, activity), excludes two existing columns (row_id, row_version)
curate_table <- function(synId, activity_name) {
  #excludes Row_id and Row_version from given dataframe
  #creates new columns in dataframe: one for name of the activity, the other for the table's ID number
  df <- read_syn_table(synId) %>%
    select(-ROW_ID, -ROW_VERSION) %>%  
    mutate(activity = activity_name,
           originalTableId = synId)
}

#applies curate_table to each dataframe then binds them on top of one another
curate_my_heart_counts <- function() {
  Six_Minute_Walk_Test_SchemaV4_v2 <- curate_table("syn11073669", "Six_Minute_Walk_Test_SchemaV4_v2")
  Six_Minute_Walk_Test_SchemaV4_v6 <- curate_table("syn12182118", "Six_Minute_Walk_Test_SchemaV4_v6")
  
  ActivitySleep_v2 <- curate_table("syn20259285", "ActivitySleep_v2")
  
  Adequacy_of_activity_mindset_measure_v1 <- curate_table("syn18103106", "Adequacy_of_activity_mindset_measure_v1")
  Adequacy_of_activity_mindset_measure_v2 <- curate_table("syn18143711", "Adequacy_of_activity_mindset_measure_v2")
  
  Covid_19_recurrent_survey_v1 <- curate_table("syn21983892", "Covid_19_recurrent_survey_v1")
  
  Covid_19_survey_v1 <- curate_table("syn21906135", "Covid_19_survey_v1")
  Covid_19_survey_v2 <- curate_table("syn21983891", "Covid_19_survey_v2")
  
  Default_Health_Data_Record_Table <- curate_table("syn20259187", "Default_Health_Data_Record_Table")
  
  Diet_survey_cardio_SchemaV2_v2 <- curate_table("syn21913727", "Diet_survey_cardio_SchemaV2_v2")
  
  Exercise_process_mindset_measure_v1 <- curate_table("syn18103105", "Exercise_process_mindset_measure_v1")
  Exercise_process_mindset_measure_v2 <- curate_table("syn18143709", "Exercise_process_mindset_measure_v2")
  
  ExternalIdentifier_v1 <- curate_table("syn20999816", "ExternalIdentifier_v1")
  
  HealthKitClinicalDocumentsCollector_v1 <- curate_table("syn21998877", "HealthKitClinicalDocumentsCollector_v1")
  
  HealthKitClinicalRecordsCollector_v1 <- curate_table("syn21052093", "HealthKitClinicalRecordsCollector_v1")
  
  Heart_Rate_Recovery_v1 <- curate_table("syn20259194", "Heart_Rate_Recovery_v1")
  
  Heart_Rate_Training_v1 <- curate_table("syn20838398", "Heart_Rate_Training_v1")
  
  Illness_mindset_inventory_v1 <- curate_table("syn18103107", "Illness_mindset_inventory_v1")
  Illness_mindset_inventory_v2 <- curate_table("syn18143712", "Illness_mindset_inventory_v2")
  
  NonIdentifiableDemographicsTask_v3 <- curate_table("syn21455306", "NonIdentifiableDemographicsTask_v3")
  
  Reconsent_v1 <- curate_table("syn21372278", "Reconsent_v1")
  
  Resting_Heart_Rate_v1 <- curate_table("syn21163687", "Resting_Heart_Rate_v1")
  
  Vaping_and_smoking_survey_v1 <- curate_table("syn18103108", "Vaping_and_smoking_survey_v1")
  Vaping_and_smoking_survey_v2 <- curate_table("syn18143710", "Vaping_and_smoking_survey_v2")
  Vaping_and_smoking_survey_v3 <- curate_table("syn21913717", "Vaping_and_smoking_survey_v3")
  
  cardiovascular_2_APHHeartAge_7259AC18_D711_47A6_ADBD_6CFCECDED1DF_v1 <- curate_table("syn3458936", "cardiovascular_2_APHHeartAge_7259AC18_D711_47A6_ADBD_6CFCECDED1DF_v1")
  cardiovascular_2_APHHeartAge_7259AC18_D711_47A6_ADBD_6CFCECDED1DF_v2 <- curate_table("syn4586968", "cardiovascular_2_APHHeartAge_7259AC18_D711_47A6_ADBD_6CFCECDED1DF_v2")
  
  cardiovascular_23andmeTask_v1 <- curate_table("syn5814622", "cardiovascular_23andmeTask_v1")
  
  cardiovascular_6_Minute_Walk_Test_SchemaV4_v1 <- curate_table("syn4857044", "cardiovascular_6_Minute_Walk_Test_SchemaV4_v1")
  
  cardiovascular_6MWT_Displacement_Data_v1 <- curate_table("syn4214144", "cardiovascular_6MWT_Displacement_Data_v1")
  
  cardiovascular_6MinuteWalkTest_v2 <- curate_table("syn3458480", "cardiovascular_6MinuteWalkTest_v2")
  
  cardiovascular_ABTestResults_v1 <- curate_table("syn7188351", "cardiovascular_ABTestResults_v1")
  
  cardiovascular_ActivitySleep_v1 <- curate_table("syn3420264", "cardiovascular_ActivitySleep_v1")
  
  cardiovascular_AwsClientIdTask_v1 <- curate_table("syn5587024", "cardiovascular_AwsClientIdTask_v1")
  
  cardiovascular_Diet_survey_cardio_v1 <- curate_table("syn3420518", "cardiovascular_Diet_survey_cardio_v1")
  
  cardiovascular_Diet_survey_cardio_SchemaV2_v1 <- curate_table("syn4894971", "cardiovascular_Diet_survey_cardio_SchemaV2_v1")
  
  cardiovascular_HealthKitDataCollector_v1 <- curate_table("syn3560085", "cardiovascular_HealthKitDataCollector_v1")
  
  cardiovascular_HealthKitSleepCollector_v1 <- curate_table("syn3560086", "cardiovascular_HealthKitSleepCollector_v1")
  
  cardiovascular_HealthKitWorkoutCollector_v1 <- curate_table("syn3560095", "cardiovascular_HealthKitWorkoutCollector_v1")
  
  cardiovascular_NonIdentifiableDemographics_v1 <- curate_table("syn3786875", "cardiovascular_NonIdentifiableDemographics_v1")
  
  cardiovascular_NonIdentifiableDemographicsTask_v2 <- curate_table("syn3917840", "cardiovascular_NonIdentifiableDemographicsTask_v2")
  
  cardiovascular_appVersion <- curate_table("syn3420239", "cardiovascular_appVersion")
  
  cardiovascular_daily_check_v1 <- curate_table("syn3420261", "cardiovascular_daily_check_v1")
  cardiovascular_daily_check_v2 <- curate_table("syn7248938", "cardiovascular_daily_check_v2")
  
  cardiovascular_day_one_v1 <- curate_table("syn3420238", "cardiovascular_day_one_v1")
  
  cardiovascular_displacement_v1 <- curate_table("syn4095792", "cardiovascular_displacement_v1")
  
  cardiovascular_heart_risk_and_age_v1 <- curate_table("syn7248937", "cardiovascular_heart_risk_and_age_v1")
  
  cardiovascular_motionActivityCollector_v1 <- curate_table("syn4536838", "cardiovascular_motionActivityCollector_v1")
  
  cardiovascular_motionTracker_v1 <- curate_table("syn3420486", "cardiovascular_motionTracker_v1")
  
  cardiovascular_par_q_quiz_v1 <- curate_table("syn3420257", "cardiovascular_par_q_quiz_v1")
  
  cardiovascular_risk_factors_v1 <- curate_table("syn3420385", "cardiovascular_risk_factors_v1")
  
  cardiovascular_risk_factors_SchemaV2_v1 <- curate_table("syn4703171", "cardiovascular_risk_factors_SchemaV2_v1")
  
  cardiovascular_satisfied_v1 <- curate_table("syn3420615", "cardiovascular_satisfied_v1")
  
  cardiovascular_satisfied_SchemaV2_v1 <- curate_table("syn4857042", "cardiovascular_satisfied_SchemaV2_v1")
  cardiovascular_satisfied_SchemaV3_v1 <- curate_table("syn4929530", "cardiovascular_satisfied_SchemaV3_v1")
  
  watchMotionActivityCollector_v1 <- curate_table("syn20563457", "watchMotionActivityCollector_v1")
  
  #binds dataframes on top of one another, creating one HUGE dataframe
  my_heart_counts <- bind_rows(
    Six_Minute_Walk_Test_SchemaV4_v2, 
    Six_Minute_Walk_Test_SchemaV4_v6,
    ActivitySleep_v2, 
    Adequacy_of_activity_mindset_measure_v1, 
    Adequacy_of_activity_mindset_measure_v2,
    Covid_19_recurrent_survey_v1, 
    Covid_19_survey_v1,
    Covid_19_survey_v2,
    Default_Health_Data_Record_Table, 
    Diet_survey_cardio_SchemaV2_v2, 
    Exercise_process_mindset_measure_v1,
    Exercise_process_mindset_measure_v2,
    ExternalIdentifier_v1, 
    HealthKitClinicalDocumentsCollector_v1, 
    HealthKitClinicalRecordsCollector_v1, 
    Heart_Rate_Recovery_v1, 
    Heart_Rate_Training_v1, 
    Illness_mindset_inventory_v1,
    Illness_mindset_inventory_v2,
    NonIdentifiableDemographicsTask_v3, 
    Reconsent_v1, 
    Resting_Heart_Rate_v1, 
    Vaping_and_smoking_survey_v1,
    Vaping_and_smoking_survey_v2,
    Vaping_and_smoking_survey_v3,
    cardiovascular_2_APHHeartAge_7259AC18_D711_47A6_ADBD_6CFCECDED1DF_v1,
    cardiovascular_2_APHHeartAge_7259AC18_D711_47A6_ADBD_6CFCECDED1DF_v2,
    cardiovascular_23andmeTask_v1, 
    cardiovascular_6_Minute_Walk_Test_SchemaV4_v1, 
    cardiovascular_6MWT_Displacement_Data_v1, 
    cardiovascular_6MinuteWalkTest_v2, 
    cardiovascular_ABTestResults_v1, 
    cardiovascular_ActivitySleep_v1, 
    cardiovascular_AwsClientIdTask_v1, 
    cardiovascular_Diet_survey_cardio_v1, 
    cardiovascular_Diet_survey_cardio_SchemaV2_v1, 
    cardiovascular_HealthKitDataCollector_v1, 
    cardiovascular_HealthKitSleepCollector_v1, 
    cardiovascular_HealthKitWorkoutCollector_v1, 
    cardiovascular_NonIdentifiableDemographics_v1,
    cardiovascular_NonIdentifiableDemographicsTask_v2,
    cardiovascular_appVersion, 
    cardiovascular_daily_check_v1,
    cardiovascular_daily_check_v2,
    cardiovascular_day_one_v1, 
    cardiovascular_displacement_v1, 
    cardiovascular_heart_risk_and_age_v1, 
    cardiovascular_motionActivityCollector_v1, 
    cardiovascular_motionTracker_v1, 
    cardiovascular_par_q_quiz_v1, 
    cardiovascular_risk_factors_v1, 
    cardiovascular_risk_factors_SchemaV2_v1, 
    cardiovascular_satisfied_v1, 
    cardiovascular_satisfied_SchemaV2_v1,
    cardiovascular_satisfied_SchemaV3_v1,
    watchMotionActivityCollector_v1) %>%
    as_tibble() 
  #changes dataframe into tibble format for cleaner look
  print("finished bind rows")
  return(my_heart_counts)
}

#adds columns to mhc df which show length of engagement by Week and Day intervals
mutate_participant_week_day <- function(engagement) {
  #print(engagement)
  print("mpwd running")
  first_activity <- engagement %>%
    group_by(healthCode) %>% #takes dataframe and arranges into grouped tables (by healthCode) which are then treated individually
    summarise(first_activity_time = min(createdOn, na.rm=T)) #finds minimum createdOn time and adds it to table 
  engagement <- inner_join(engagement, first_activity) #joins concurrent rows between first_activity and engagement, cutting out repeat healthCodes and leaving the one with the first (earliest) entry 
  engagement <- engagement %>%
    mutate(
      seconds_since_first_activity = createdOn - first_activity_time, #subtracts first activity time from createdOn to find how long user has been active then plugs into a variable
      participantWeek = as.integer(
        floor(as.numeric(
          as.duration(seconds_since_first_activity), "weeks"))), #converts seconds to weeks as an integer
      participantDay = as.integer(
        floor(as.numeric(
          as.duration(seconds_since_first_activity), "days"))) + 1 #converts seconds to days as an integer (+1?)
    ) %>%
    select(-first_activity_time, -seconds_since_first_activity) #removes two intermediary columns from engagement df
  }

#adds a column indicating the type of task for each activity
mutate_task_type <- function(engagement_data) {
  print("mtt running")
  engagement_data %>%
    mutate(taskType = case_when(
      activity == "Six_Minute_Walk_Test_SchemaV4_v2" ~ "active-sensor",
      activity == "Six_Minute_Walk_Test_SchemaV4_v6" ~ "active-sensor",
      activity == "ActivitySleep_v2" ~ "survey",
      activity == "Adequacy_of_activity_mindset_measure_v1" ~ "survey",
      activity == "Adequacy_of_activity_mindset_measure_v2" ~ "survey",
      activity == "Covid_19_recurrent_survey_v1" ~ "survey",
      activity == "Covid_19_survey_v1" ~ "survey",
      activity == "Covid_19_survey_v2" ~ "survey",
      activity == "Default_Health_Data_Record_Table" ~ "passive-sensor",
      activity == "Diet_survey_cardio_SchemaV2_v2" ~ "survey",
      activity == "Exercise_process_mindset_measure_v1" ~ "survey", 
      activity == "Exercise_process_mindset_measure_v2" ~ "survey", 
      activity == "ExternalIdentifier_v1" ~ "survey", 
      activity == "HealthKitClinicalDocumentsCollector_v1" ~ "passive-sensor", 
      activity == "HealthKitClinicalRecordsCollector_v1" ~ "passive-sensor", 
      activity == "Heart_Rate_Recovery_v1" ~ "active-sensor", 
      activity == "Heart_Rate_Training_v1" ~ "active-sensor", 
      activity == "Illness_mindset_inventory_v1" ~ "survey", 
      activity == "Illness_mindset_inventory_v2" ~ "survey", 
      activity == "NonIdentifiableDemographicsTask_v3" ~ "demographic", 
      activity == "Reconsent_v1" ~ "Reconsent-v1", 
      activity == "Resting Heart Rate_v1" ~ "active-sensor", 
      activity == "Vaping_and_smoking_survey_v1" ~ "survey", 
      activity == "Vaping_and_smoking_survey_v2" ~ "survey", 
      activity == "Vaping_and_smoking_survey_v3" ~ "survey", 
      activity == "cardiovascular_2_APHHeartAge_7259AC18_D711_47A6_ADBD_6CFCECDED1DF_v1" ~ "survey", 
      activity == "cardiovascular_2_APHHeartAge_7259AC18_D711_47A6_ADBD_6CFCECDED1DF_v2" ~ "survey", 
      activity == "cardiovascular_23andmeTask_v2" ~ "survey", 
      activity == "cardiovascular_6_Minute_Walk_Test_SchemaV4_v1" ~ "active-sensor", 
      activity == "cardiovascular_6MWT_Displacement_Data_v1" ~ "active-sensor", 
      activity == "cardiovascular_6MinuteWalkTest_v2" ~ "active-sensor", 
      activity == "cardiovascular_ABTestResults_v1" ~ "survey", 
      activity == "cardiovascular_ActivitySleep_v1" ~ "survey", 
      activity == "cardiovascular_AwsClientIdTask_v1" ~ "cardiovascular_AwsClientIdTask_v1", 
      activity == "cardiovascular_Diet_survey_cardio_v1" ~ "survey", 
      activity == "cardiovascular_Diet_survey_cardio_SchemaV2_v1" ~ "survey", 
      activity == "cardiovascular_HealthKitDataCollector_v1" ~ "passive-sensor", 
      activity == "cardiovascular_HealthKitSleepCollector_v1" ~ "passive-sensor", 
      activity == "cardiovascular_HealthKitWorkoutCollector_v1" ~ "passive-sensor", 
      activity == "cardiovascular_NonIdentifiableDemographics_v1" ~ "demographic", 
      activity == "cardiovascular_NonIdentifiableDemographicsTask_v2" ~ "demographic", 
      activity == "cardiovascular_appVersion" ~ "cardiovascular-appVersion", 
      activity == "cardiovascular_daily_check_v1" ~ "survey", 
      activity == "cardiovascular_daily_check_v2" ~ "survey", 
      activity == "cardiovascular_day_one_v1" ~ "survey", 
      activity == "cardiovascular_displacement_v1" ~ "passive-sensor", 
      activity == "cardiovascular_heart_risk_and_age_v1" ~ "survey", 
      activity == "cardiovascular_motionActivityCollector_v1" ~ "passive-sensor", 
      activity == "cardiovascular_motionTracker_v1" ~ "passive-sensor", 
      activity == "cardiovascular_par_q_quiz_v1" ~ "survey", 
      activity == "cardiovascular_risk_factors_v1" ~ "survey", 
      activity == "cardiovascular_risk_factors_SchemaV2_v1" ~ "survey", 
      activity == "cardiovascular_satisfied_v1" ~ "survey", 
      activity == "cardiovascular_satisfied_SchemaV2_v1" ~ "survey", 
      activity == "cardiovascular_satisfied_SchemaV3_v1" ~ "survey", 
      activity == "watchMotionActivityCollector_v1" ~ "passive-sensor"))
}

mutate_task_frequency <- function(engagement_data) {
  print("mtf running")
  engagement_data %>%
    mutate(taskFrequency = case_when(
      activity %in% c("daily_check_survey", "six_minute_walk_activity") ~ "daily",
      activity %in% c("cardio_diet_survey", "risk_factor_survey",
                      "activity_and_sleep_survey", "satisfied_survey",
                      "aph_heart_age_survey", "par_q_survey",
                      "day_one_survey", "demographics") ~ "baseline",
      startsWith(activity, "health_kit") ~ "continuous",
      activity == "motion_tracker" ~ "continuous"))
}

#edits zipcode df to be used as a frame of reference for which zip3 values correspond to which state
demographics_tz_from_zip_prefix <- function() {
  #parsed from satisfied survey (quality of life)
  demographics1 <- synTableQuery(paste(
    "select healthCode, zip from", "syn3420615"))
  
  demog_df1=demographics1$asDataFrame() #saves demographics table as a dataframe
  demog_colnames1=colnames(demog_df1) #stores column names in demog_colnames
  demog_colnames1[demog_colnames1=="zip"]="zip3" #renames zip column as zip3
  colnames(demog_df1)=demog_colnames1 #resets column names back to demog_colnames after editing a column
  
  demog_df1 <- demog_df1 %>%
    mutate(zip3 = str_sub(zip3, 1, 3))
  
  demographics2 <- synTableQuery(paste(
    "select healthCode, zip from", "syn4857042"))
  
  demog_df2=demographics2$asDataFrame() #saves demographics table as a dataframe
  demog_colnames2=colnames(demog_df2) #stores column names in demog_colnames
  demog_colnames2[demog_colnames2=="zip"]="zip3" #renames zip column as zip3
  colnames(demog_df2)=demog_colnames2
  
  demog_df2 <- demog_df2 %>%
    mutate(zip3 = str_sub(zip3, 1, 3))
  
  demographics3 <- synTableQuery(paste(
    "select healthCode, zip, numericZip from", "syn4929530"))
  
  demog_df3=demographics3$asDataFrame() #saves demographics table as a dataframe
  
  demographics3_uk_zips_na=which(is.na(demog_df3$numericZip))
  demog_df3$numericZip[demographics3_uk_zips_na]=demog_df3$zip[demographics3_uk_zips_na]
  demog_df3$zip= NULL
  
  demog_colnames3=colnames(demog_df3) #stores column names in demog_colnames
  demog_colnames3[demog_colnames3=="numericZip"]="zip3" #renames zip column as zip3
  colnames(demog_df3)=demog_colnames3
  
  demog_df3 <- demog_df3 %>%
    mutate(zip3 = str_sub(zip3, 1, 3))
  
  #print(head(demog_df1))
  #print(head(demog_df2))
  #print(head(demog_df3))
  demographics=rbind(demog_df1, demog_df2, demog_df3)
  
  demographics <- demographics %>%
    select(-ROW_ID, -ROW_VERSION) %>% #remove ROW ID, VERSION columns
    distinct(healthCode, zip3) #removes repeat zipcodes
  
  app_zip <- zipcode %>%
    mutate(zip3 = str_sub(zip, 1, 3)) %>% #creates new colum with first 3 numbers of zipcodes
    group_by(zip3) %>% #rows with same zip3 value are stored together
    summarise(lat = median(latitude), long = median(longitude)) #creates table with zip3s, median latitudes and longitudes
  #print(head(app_zip))
  
  zip_state <- zipcode %>%
    mutate(zip3 = str_sub(zip, 1, 3)) %>% #creates new column with first 3 numbers of zipcodes
    count(zip3, state) %>% #keeps a count of amount of states stored for each uinque zip3, state combination
    group_by(zip3) %>% 
    slice(which.max(n)) %>% #state which has most instances of given zipcode is kept
    select(zip3, state) #finalizes the table only keeping zipcodes and their corresponding state
  #print(head(zip_state))
  
  zip_state_uk <- uk_zipcodes %>%
    mutate(zip3 = str_sub(Postcode, 1, 3)) %>%
    mutate(state = "UK") %>%
    mutate(lat = 53, long = 2) %>%
    select(zip3, state, lat, long) %>%
    distinct(zip3, .keep_all = TRUE)
  
  zip_code_hk <- data.frame(
    zip3 = "hk", lat = 22, long = 114, state = "hk")
  #print(head(zip_code_hk))
  
  timezones <- purrr::map2( 
    app_zip$lat, app_zip$long, lutz::tz_lookup_coords, method = "fast") %>% #goes over corresponding lat/long then return timezone for given combination
    unlist()
  app_zip <- app_zip %>% mutate(timezone = timezones) #adds timezones to app_zip table (which has zips, lats and longs)
  
  demographics$zip3=as.character(demographics$zip3)
  
  us_lat_long=merge(app_zip,zip_state,by='zip3')
  
  zip_state_uk$timezone="UK" 
  zip_code_hk$timezone="HK"
  zip_to_lat_long=rbind(zip_code_hk, us_lat_long, zip_state_uk)
  
  demographics <- demographics %>% merge(zip_to_lat_long, by='zip3', all.x = TRUE) 
  #print(head(demographics))
  
  occurences <- table(unlist(demographics$state))
  
  travelers <- demographics %>% #checks if timezones ever switch
    group_by(healthCode) %>%
    summarize(n_tz = n_distinct(timezone)) %>% #counts distinct timezones
    filter(n_tz > 1) #return df with only information for people with 2+ timezones
  demographics <- demographics %>%
    filter(!(healthCode %in% travelers$healthCode)) #returns table with every row that does not meet traveler qualification
}

mutate_local_time <- function(engagement) {
  print("mlt running")
  demographics <- demographics_tz_from_zip_prefix()
  engagement <- engagement %>%
    left_join(demographics, by="healthCode") #adds data from demographics table to engagement (mhc) table
  #print(head(engagement))
  local_time <- purrr::map2(engagement$createdOn, engagement$timezone, with_tz) %>% 
    purrr::map(as.character) %>%
    unlist() 
  #print(head(local_time))
  engagement <- engagement %>% dplyr::mutate(
    createdOnLocalTime = local_time,
    createdOnLocalTime = ifelse(is.na(timezone), NA, createdOnLocalTime)) %>% #if the timezone is NA, then put NA as the value in the column otherwise use the created variable
    select(-zip3, -lat, -long) #excludes zip3, lat, and long columns
  return(engagement)
}

curate_my_heart_counts_metadata <- function(engagement) {
  demographics2 <- synTableQuery("select * from syn3917840")$asDataFrame() %>%
    select(NonIdentifiableDemographics.json.patientCurrentAge, NonIdentifiableDemographics.patientCurrentAge,
           NonIdentifiableDemographics.json.patientBiologicalSex, NonIdentifiableDemographics.patientBiologicalSex,
           healthCode, phoneInfo, createdOn)
  #print(head(demographics2))
  
  demographics3 <- synTableQuery("select * from syn21455306")$asDataFrame() %>%
    select(NonIdentifiableDemographics.json.patientCurrentAge, NonIdentifiableDemographics.patientCurrentAge,
           NonIdentifiableDemographics.json.patientBiologicalSex, NonIdentifiableDemographics.patientBiologicalSex,
           healthCode, phoneInfo, createdOn)
  #print(head(demographics3))
  
  demographics=do.call("rbind", list(demographics2, demographics3)) # combines demographics dataframes (one on top of the other)
  #print(head(demographics))
  
  na_fields_sex=which(is.na(demographics$NonIdentifiableDemographics.json.patientBiologicalSex))
  demographics$NonIdentifiableDemographics.json.patientBiologicalSex[na_fields_sex]=demographics$NonIdentifiableDemographics.patientBiologicalSex[na_fields_sex]
  demographics$NonIdentifiableDemographics.patientBiologicalSex= NULL
  
  na_fields_age=which(is.na(demographics$NonIdentifiableDemographics.json.patientCurrentAge))
  demographics$NonIdentifiableDemographics.json.patientCurrentAge[na_fields_age]=demographics$NonIdentifiableDemographics.patientCurrentAge[na_fields_age]
  demographics$NonIdentifiableDemographics.patientCurrentAge= NULL
  
  df <- demographics %>%
    dplyr::rename(age = NonIdentifiableDemographics.json.patientCurrentAge, 
                  gender = NonIdentifiableDemographics.json.patientBiologicalSex) %>% #renames age and gender tables
    dplyr::mutate(age_group = cut(age, breaks=c(17,29,39,49, 59, 120))) %>% #makes grouping for age (i.e 45 -> 40-49)
    arrange(desc(createdOn)) %>% #organize df by createdOn values in order
    distinct(healthCode, .keep_all = T) %>% #finds first occurence of HC, keeps that row along will every other variable 
    dplyr::select(healthCode, age,age_group, gender, phoneInfo) #keeps specified vars
  
  #integrate the heartCondition
  #See - https://github.com/Sage-Bionetworks/mhealth-engagement-analysis/issues
  diseaseStatus <- synTableQuery("select * from syn3420257")$asDataFrame() %>%
    dplyr::mutate(createdOn = as.Date(lubridate::ymd_hms(createdOn))) %>% #creates createdOn column with organized y/m/s 
    arrange(desc(createdOn)) %>% #orders from earliest date
    distinct(healthCode, .keep_all = T) %>%
    dplyr::select(healthCode, heartCondition) %>% #simple df with ordered, distinct HealthCode (by date) and heart condition
    dplyr::rename(caseStatus = heartCondition) #renames heartcondition variable
  df = merge(df, diseaseStatus, all=T)
  
  ##Add state info
  state.metadata = data.frame(state.name = state.name,
                              state.abb = state.abb,
                              state.region = state.region) %>%
    dplyr::mutate(state.name = as.character(state.name),
                  state.abb = as.character(state.abb),
                  state.region = as.character(state.region))
  state.metadata <- rbind(state.metadata, c('District of Columbia', 'DC', 'South'), 
                          c('United Kingdom', 'UK', 'Europe'), c('Hong Kong', 'hk', 'Asia'), 
                          c('United States', 'AA', 'Territory'), c('United States', 'AP', 'Territory'), 
                          c('United States', 'GU', 'Territory'), c('United States', 'PR', 'Territory'))
  
  my_heart_counts_states <- engagement %>%
    group_by(healthCode) %>%
    arrange(createdOn) %>%
    summarise(state = state[1]) %>%
    left_join(state.metadata, by = c("state" = "state.abb")) %>%
    mutate(state = stringr::str_to_title(state.name)) %>%
    select(-state.name)
  df <- merge(df, my_heart_counts_states, by="healthCode", all=T)
  
  
  tmp_find_last_val <- function(x){
    x <-  na.omit(as.character(x))
    ifelse(length(x) == 0, 'NA', x[length(x)])
  }
  
  #race
  additionDemogData <- synTableQuery("select * from syn7248937")$asDataFrame() %>%
    dplyr::transmute(healthCode = healthCode,
                     createdOn = lubridate::ymd_hms(createdOn),
                     race = heartAgeDataEthnicity,
                     age.fromHeartAgeSurvey = as.numeric(heartAgeDataAge),
                     gender.fromHeartAgeSurvey  = as.character(heartAgeDataGender)) %>%
    dplyr::distinct(healthCode, race, age.fromHeartAgeSurvey, gender.fromHeartAgeSurvey, .keep_all=T) %>%
    dplyr::group_by(healthCode) %>%
    dplyr::arrange(createdOn) %>%
    dplyr::summarise(race = tmp_find_last_val(race),
                     gender.fromHeartAgeSurvey = tmp_find_last_val(gender.fromHeartAgeSurvey),
                     age.fromHeartAgeSurvey = tmp_find_last_val(age.fromHeartAgeSurvey)) %>%
    dplyr::mutate(gender.fromHeartAgeSurvey = ifelse(gender.fromHeartAgeSurvey == 'NA', NA, gender.fromHeartAgeSurvey),
                  age.fromHeartAgeSurvey = ifelse(age.fromHeartAgeSurvey == 'NA', NA, age.fromHeartAgeSurvey))
  
  #Fix race col
  additionDemogData <- additionDemogData %>%
    dplyr::mutate(race = case_when(
      race %in% c('Alaska Native', 'American Indian') ~ 'AIAN',
      race == 'Hispanic' ~ 'Hispanic/Latinos',
      race == 'White' ~ 'Non-Hispanic White',
      race == 'Black' ~ 'African-American/Black',
      race == 'I prefer not to indicate an ethnicity' ~ 'Prefer not to answer',
      race == 'Pacific Islander' ~ 'Hawaiian or other Pacific Islander',
      TRUE ~ race
    ))
  
  #merge race and other engagement data
  df <- merge(df, additionDemogData, all.x=T)
  
  #replace missing values from additionalDemogData
  to.replace <- is.na(df$gender)
  df$gender[to.replace] =  df$gender.fromHeartAgeSurvey[to.replace]
  df$gender.fromHeartAgeSurvey <- NULL
  
  to.replace <- is.na(df$age)
  df$age[to.replace] <-  df$age.fromHeartAgeSurvey[to.replace]
  df$age.fromHeartAgeSurvey <- NULL
  df['study'] = 'MyHeartCounts'
  
  return(as_tibble(df))
  print(as_tibble(df))
}

main <- function() {
  synLogin() #logs you into synapse
  print("logged in") 
  
  df=curate_my_heart_counts()
  saveRDS(df, "df.rds")
  #create and saves curate_mhc dataframe and names it "df"
  
  #df <- readRDS("df.rds")
  #loads df into R to avoid having to curate tables with each run (comment out prev 2 lines after running once)
  
  my_heart_counts <- df %>% #df gets piped into 3 functions to manipulate the dataframe
    mutate_participant_week_day() %>%
    mutate_local_time() %>% # adds zipcodes from satisfied survey
    mutate_task_type() #adds column showing type of task
  print("executed curate_my_heart_counts") 
  saveRDS(my_heart_counts, "mhc_new.rds")
  
  my_heart_counts_metadata=curate_my_heart_counts_metadata(my_heart_counts)
  print("executed curate_my_heart_counts_metadata") 
  
  saveRDS(my_heart_counts_metadata, "mhc_metadata.rds")
  #my_heart_counts_metadata <- readRDS("mhc_metadata.rds")
  
  my_heart_counts %>%
    mutate(study = "MyHeartCounts", hourOfDayUTC = lubridate::hour(createdOn)) %>%
    select(study, uid = healthCode, dayInStudy = participantDay,
           hourOfDayUTC, taskType) %>%
    write_tsv("MyHeartCounts_engagement.tsv")
  print("wrote engagement info")
  my_heart_counts_metadata %>%
    select(study, uid = healthCode, age_group, gender, diseaseStatus = caseStatus,
           state, race_ethnicity = race) %>%
    write_tsv("MyHeartCounts_metadata.tsv")
  print("wrote metadata") 
}

main()
