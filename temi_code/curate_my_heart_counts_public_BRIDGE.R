library(synapser)
library(tidyverse)
library(lubridate)
library(zipcode)
data(zipcode)


read_syn_table <- function(syn_id) {
  q <- synTableQuery(paste('select "healthCode","recordId","createdOn",',
                           '"appVersion","phoneInfo"',
                           'from', syn_id))
  return(q$asDataFrame())
  print(q$asDataFrame())
}

curate_table <- function(synId, activity_name) {
  df <- read_syn_table(synId) %>%
        select(-ROW_ID, -ROW_VERSION) %>%
        mutate(activity = activity_name,
               originalTableId = synId)
}

curate_my_heart_counts <- function() {
  day_one_survey <- curate_table("syn3420238", "day_one_survey")
  print("ran curate_table on day_one_survey")
  save(day_one_survey,file="day_one_survey.Rdata")
  
  par_q_survey <- curate_table("syn3420257", "par_q_survey")
  print("ran 2")
  save(par_q_survey,file="par_q_survey.Rdata")
  
  daily_check_survey <- curate_table("syn7248938", "daily_check_survey")
  print("ran 3")
  save(daily_check_survey,file="daily_check_survey.Rdata")
  
  a_and_s_survey <- curate_table("syn3420264", "activity_and_sleep_survey")
  print("ran 4")
  save(a_and_s_survey,file="a_and_s_survey.Rdata")
  
  risk_factor_survey <- curate_table("syn3420385", "risk_factor_survey")
  print("ran 5")
  save(risk_factor_survey,file="risk_factor_survey.Rdata")
  
  cardio_diet_survey <- curate_table("syn3420518", "cardio_diet_survey")
  print("ran 6")
  save(cardio_diet_survey,file="cardio_diet_survey.Rdata")
  
  satisfied_survey <- curate_table("syn3420615", "satisfied_survey")
  print("ran 7")
  save(satisfied_survey,file="satisfied_survey.Rdata")
  
  aph_heart_age_survey <- curate_table("syn3458936", "aph_heart_age_survey")
  print("ran 8")
  save(aph_heart_age_survey,file="aph_heart_age_survey.Rdata")
  
  six_minute_walk <- curate_table("syn3458480", "six_minute_walk_activity")
  print("ran 9")
  save(six_minute_walk,file="six_minute_walk.Rdata")

  
  demographics1 <- curate_table("syn3786875", "demographics")
  demographics2 <- curate_table("syn3917840", "demographics")
  demographics3 <- curate_table("syn21455306", "demographics")
  print("ran 10")
  demographics=do.call("rbind", list(demographics1, demographics2, demographics3))
  save(demographics,file="demographics.Rdata")
  
  health_kit_data <- curate_table("syn3560085", "health_kit_data")
  print("ran 11")
  save(health_kit_data,file="health_kit_data.Rdata")
  
  health_kit_sleep <- curate_table("syn3560086", "health_kit_sleep")
  print("ran 12")
  save(health_kit_sleep,file="health_kit_sleep.Rdata")
  
  health_kit_workout <- curate_table("syn3560095", "health_kit_workout")
  print("ran 13")
  save(health_kit_workout,file="health_kit_workout.Rdata")
  
  motion_tracker <- synTableQuery("select * from syn4536838")$asDataFrame() %>%
    select(recordId, healthCode, createdOn) %>%
    mutate(activity = "motion_tracker",
           originalTableId = "syn4536838")
  print("ran 14")
  save(motion_tracker,file="motion_tracker.Rdata")

  my_heart_counts <- bind_rows(
    day_one_survey, par_q_survey, daily_check_survey, a_and_s_survey,
    risk_factor_survey, cardio_diet_survey, satisfied_survey,
    aph_heart_age_survey, six_minute_walk, demographics, health_kit_data,
    health_kit_sleep, health_kit_workout, motion_tracker) %>%
    as_tibble()
  print("ran 15")
  return(my_heart_counts)
  print(my_heart_counts)
}

mutate_participant_week_day <- function(engagement) {
  print("engagement")
  first_activity <- engagement %>%
    group_by(healthCode) %>%
    summarise(first_activity_time = min(createdOn, na.rm=T))
  print("first_activity")
  engagement <- inner_join(engagement, first_activity)
  print("inner join")
  engagement <- engagement %>%
    mutate(
      seconds_since_first_activity = createdOn - first_activity_time,
      participantWeek = as.integer(
          floor(as.numeric(
            as.duration(seconds_since_first_activity), "weeks"))),
      participantDay = as.integer(
        floor(as.numeric(
          as.duration(seconds_since_first_activity), "days"))) + 1
    ) %>%
    select(-first_activity_time, -seconds_since_first_activity)
  head(engagement)
  return(engagement)
}

mutate_task_type <- function(engagement_data) {
  engagement_data %>%
    mutate(taskType = case_when(
      activity == "6-Minute Walk Test_SchemaV4-v2" ~ "active-sensor",
      activity == "6-Minute Walk Test_SchemaV4-v6" ~ "active-sensor",
      activity == "ActivitySleep-v2" ~ "survey",
      activity == "Adequacy_of_activity_mindset_measure-v1" ~ "survey",
      activity == "Adequacy_of_activity_mindset_measure-v2" ~ "survey",
      activity == "Covid_19_recurrent_survey-v1" ~ "survey",
      activity == "Covid_19_survey-v1" ~ "survey",
      activity == "Covid_19_survey-v2" ~ "survey",
      activity == "Default Health Data Record Table" ~ "passive-sensor",
      activity == "Diet_survey_cardio_SchemaV2-v2" ~ "survey",
      activity == "Exercise_process_mindset_measure-v1" ~ "survey", 
      activity == "Exercise_process_mindset_measure-v2" ~ "survey", 
      activity == "ExternalIdentifier-v1" ~ "survey", 
      activity == "HealthKitClinicalDocumentsCollector-v1" ~ "passive-sensor", 
      activity == "HealthKitClinicalRecordsCollector-v1" ~ "passive-sensor", 
      activity == "Heart Rate Recovery-v1" ~ "active-sensor", 
      activity == "Heart Rate Training-v1" ~ "active-sensor", 
      activity == "Illness_mindset_inventory-v1" ~ "survey", 
      activity == "Illness_mindset_inventory-v2" ~ "survey", 
      activity == "NonIdentifiableDemographicsTask-v3" ~ "demographic", 
      activity == "Reconsent-v1" ~ "Reconsent-v1", 
      activity == "Resting Heart Rate-v1" ~ "active-sensor", 
      activity == "Vaping_and_smoking_survey-v1" ~ "survey", 
      activity == "Vaping_and_smoking_survey-v2" ~ "survey", 
      activity == "Vaping_and_smoking_survey-v3" ~ "survey", 
      activity == "cardiovascular-2-APHHeartAge-7259AC18-D711-47A6-ADBD-6CFCECDED1DF-v1" ~ "survey", 
      activity == "cardiovascular-2-APHHeartAge-7259AC18-D711-47A6-ADBD-6CFCECDED1DF-v2" ~ "survey", 
      activity == "cardiovascular-23andmeTask-v1" ~ "survey", 
      activity == "cardiovascular-6-Minute Walk Test_SchemaV4-v1" ~ "active-sensor", 
      activity == "cardiovascular-6MWT Displacement Data-v1" ~ "active-sensor", 
      activity == "cardiovascular-6MinuteWalkTest-v2" ~ "active-sensor", 
      activity == "cardiovascular-ABTestResults-v1" ~ "survey", 
      activity == "cardiovascular-ActivitySleep-v1" ~ "survey", 
      activity == "cardiovascular-AwsClientIdTask-v1" ~ "cardiovascular-AwsClientIdTask-v1", 
      activity == "cardiovascular-Diet_survey_cardio-v1" ~ "survey", 
      activity == "cardiovascular-Diet_survey_cardio_SchemaV2-v1" ~ "survey", 
      activity == "cardiovascular-HealthKitDataCollector-v1" ~ "passive-sensor", 
      activity == "cardiovascular-HealthKitSleepCollector-v1" ~ "passive-sensor", 
      activity == "cardiovascular-HealthKitWorkoutCollector-v1" ~ "passive-sensor", 
      activity == "cardiovascular-NonIdentifiableDemographics-v1" ~ "demographic", 
      activity == "cardiovascular-NonIdentifiableDemographicsTask-v2" ~ "demographic", 
      activity == "cardiovascular-appVersion" ~ "cardiovascular-appVersion", 
      activity == "cardiovascular-daily_check-v1" ~ "survey", 
      activity == "cardiovascular-daily_check-v2" ~ "survey", 
      activity == "cardiovascular-day_one-v1" ~ "survey", 
      activity == "cardiovascular-displacement-v1" ~ "passive-sensor", 
      activity == "cardiovascular-heart_risk_and_age-v1" ~ "survey", 
      activity == "cardiovascular-motionActivityCollector-v1" ~ "passive-sensor", 
      activity == "cardiovascular-motionTracker-v1" ~ "passive-sensor", 
      activity == "cardiovascular-par-q quiz-v1" ~ "survey", 
      activity == "cardiovascular-risk_factors-v1" ~ "survey", 
      activity == "cardiovascular-risk_factors_SchemaV2-v1" ~ "survey", 
      activity == "cardiovascular-satisfied-v1" ~ "survey", 
      activity == "cardiovascular-satisfied_SchemaV2-v1" ~ "survey", 
      activity == "cardiovascular-satisfied_SchemaV3-v1" ~ "survey", 
      activity == "watchMotionActivityCollector-v1" ~ "passive-sensor"))
}

mutate_task_frequency <- function(engagement_data) {
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

demographics_tz_from_zip_prefix <- function(demographics_synId) {
  demographics <- synTableQuery(paste(
    "select healthCode, zip from", demographics_synId))
  demog_df=demographics$asDataFrame()
  demog_colnames=colnames(demog_df)
  demog_colnames[demog_colnames=="zip"]="zip3"
  colnames(demog_df)=demog_colnames
  demographics <- demog_df %>%
    as_tibble() %>%
    select(-ROW_ID, -ROW_VERSION) %>%
    distinct(healthCode, zip3) #match people with zipcodes
  app_zip <- zipcode %>%
    mutate(zip3 = as.integer(str_sub(zip, 1, 3))) %>%
    group_by(zip3) %>%
    summarize(lat = median(latitude), long = median(longitude))
  zip_state <- zipcode %>%
    mutate(zip3 = as.integer(str_sub(zip, 1, 3))) %>%
    count(zip3, state) %>%
    group_by(zip3) %>%
    slice(which.max(n)) %>%
    select(zip3, state)
  timezones <- purrr::map2(
    app_zip$lat, app_zip$long, lutz::tz_lookup_coords, method = "fast") %>%
    unlist()
  app_zip <- app_zip %>% mutate(timezone = timezones)
  demographics <- demographics %>% left_join(app_zip, by = "zip3")
  demographics <- demographics %>% left_join(zip_state, by = "zip3")
  travelers <- demographics %>%
    group_by(healthCode) %>%
    summarize(n_tz = n_distinct(timezone)) %>%
    filter(n_tz > 1)
  demographics <- demographics %>%
    filter(!(healthCode %in% travelers$healthCode))
  head(demographics)
  return(demographics)
}

mutate_local_time <- function(engagement) {
  print("will fail")
  demographics <- demographics_tz_from_zip_prefix("syn3420615")
  print("won't fail")
  engagement <- engagement %>%
    left_join(demographics, by="healthCode")
  print("left_join done")
  local_time <- purrr::map2(engagement$createdOn, engagement$timezone, with_tz) %>%
    purrr::map(as.character) %>%
    unlist()
  print("local_time done")
  engagement <- engagement %>% dplyr::mutate(
    createdOnLocalTime = local_time,
    createdOnLocalTime = ifelse(is.na(timezone), NA, createdOnLocalTime)) %>%
    select(-zip3, -lat, -long)
  print("engagement done")
  return(engagement)
}

curate_my_heart_counts_metadata <- function(engagement) {

  df <- synTableQuery("select * from syn3917840")$asDataFrame() %>%
    dplyr::rename(age = NonIdentifiableDemographics.json.patientCurrentAge,
                  gender = NonIdentifiableDemographics.json.patientBiologicalSex) %>%
    dplyr::mutate( age_group = cut(age, breaks=c(17,29,39,49, 59, 120))) %>%
    arrange(desc(createdOn)) %>%
    distinct(healthCode, .keep_all = T) %>%
    dplyr::select(healthCode, age,age_group, gender, phoneInfo)

  #integrate the heartCondition
  #See - https://github.com/Sage-Bionetworks/mhealth-engagement-analysis/issues
  diseaseStatus <- synTableQuery("select * from syn3420257")$asDataFrame() %>%
    dplyr::mutate(createdOn = as.Date(lubridate::ymd_hms(createdOn))) %>%
    arrange(desc(createdOn)) %>%
    distinct(healthCode, .keep_all = T) %>%
    dplyr::select(healthCode, heartCondition) %>%
    dplyr::rename(caseStatus = heartCondition)
  df = merge(df, diseaseStatus, all=T)

  ##Add state info
  state.metadata = data.frame(state.name = state.name,
                              state.abb = state.abb,
                              state.region = state.region) %>%
    dplyr::mutate(state.name = as.character(state.name),
                  state.abb = as.character(state.abb),
                  state.region = as.character(state.region))
  state.metadata <- rbind(state.metadata, c('District of Columbia', 'DC', 'South'))
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
                  age.fromHeartAgeSurvey = ifelse(age.fromHeartAgeSurvey == 'NA', NA, age.fromHeartAgeSurvey),)

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
  synLogin()
  print("logged in") 
  #df=curate_my_heart_counts()
  #saveRDS(df, "df.rds")
  df <- readRDS("df.rds")
  my_heart_counts <- df %>%
    mutate_participant_week_day() %>%
    mutate_local_time() %>% # adds state from demographics file
    mutate_task_type()
  print("executed curate_my_heart_counts") 
  df_metadata=curate_my_heart_counts_metadata(my_heart_counts)
  saveRDS(df_metadata, "df_metadata.rds")
  df_metadata <- readRDS("df_metadata.rds")
  my_heart_counts_metadata <- curate_my_heart_counts_metadata(my_heart_counts)
  print("executed curate_my_heart_counts_metadata") 
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
