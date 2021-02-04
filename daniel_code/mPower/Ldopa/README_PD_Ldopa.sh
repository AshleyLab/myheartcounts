#!/bin/bash

#this script described the pipeline that how to produce the features

root=~/PD_dream #working root dir
script_path=~/PD_dream/scripts #all scripts were stored here.
export PATH==${script_path}:$PATH

#some folds were zip compressed
cd ${script_path}
unzip other_folds.zip

#---------------------------------------------------#
#1, download & and transforming raw data
mkdir -p ${root}/download_LdopaTraining_data 
cd ${root}/download_LdopaTraining_data
#download data
R --vanilla < ${script_path}/download_PD_Ldopa_training.R
#to transform raw data to data matrix
R --vanilla < ${script_path}/rawdata2dm_Ldopo_training.R

#---------------------------------------------------#
#2, producing raw features data
#mkdir -p ${root}/Ldopa_proc_raw_features/_temp_out
mkdir -p ${root}/Ldopa_proc_raw_features/all_training/merged
cd ${root}/Ldopa_proc_raw_features/all_training

methods = ( m1  m10  m11  m2  m3  m4  m8  m9 )
files=`seq 1 13`

for m in ${methods[@]};do
	mkdir -p ${root}/Ldopa_proc_raw_features/all_training/${m}/table
	for f in ${files[@]};do
		#Rscript ${script_path}/do_each_var.R ${f} 1 NA _temp_out Ldopa_training
		pbsv2.pl "cd ${root}/Ldopa_proc_raw_features/all_training/${m}; Rscript ${script_path}/do_each_var.R ${f} 1 NA _temp_out Ldopa_training; perl ${script_path}/sum_table.pl; R --vanilla < run_table.R; R --vanilla < run_table_y.R" -ppn 20 -pmem 120000 -q general
	done
done

#merging and removing redundant features
R --vanilla < ${script_path}/Ldopa/merging_remove_redundant.R

#---------------------------------------------------#
#3, download & and transforming testing raw data
mkdir -p ${root}/download_LdopaTesting_data 
cd ${root}/download_LdopaTesting_data
#download data
R --vanilla < ${script_path}/download_PD_Ldopa_testing.R
#to transform raw data to data matrix
R --vanilla < ${script_path}/rawdata2dm_Ldopo_testing.R

#---------------------------------------------------#
#4, machine learning after merging tasks, results version 1
mkdir -p ${root}/Ldopa_mergingTask_FS
cd ${root}/Ldopa_mergingTask_FS

mkdir Tremor Dyskinesia Bradykinesia

#-------------------------------------------#
#4.1 ML processing

#------------#
#for sub 2.1
cd ${root}/Ldopa_mergingTask_FS/Tremor
mkdir bagging_importance_rf Feature_selection
cp ${script_path}/para_examples/Ldopa_FS/Tremor/bagging_importance_para.R bagging_importance_rf
cp ${script_path}/para_examples/Ldopa_FS/Tremor/feature_selection_para.R Feature_selection
pbsv2.pl "Rscript ${script_path}/Ldopa/split_samples_Ldopa_mergeTask_v4.R t > split_samples_Ldopa_mergeTask_v4.log; cd ${root}/Ldopa_mergingTask_FS/Tremor/bagging_importance_rf; R --vanilla < ${script_path}/feature_selection/feature_selection_bagging_importance_v2_02.R; cd ${root}/Ldopa_mergingTask_FS/Tremor/Feature_selection; R --vanilla < ${script_path}/feature_selection/feature_selection_rf_svm_screen_02_v3.R; R --vanilla < ${script_path}/feature_selection/feature_selection_caret_test_accu_03_v3.R" -ppn 10 -e -pmem 200000 -q bigmem

#------------#
#for sub 2.2
cd ${root}/Ldopa_mergingTask_FS/Dyskinesia
mkdir bagging_importance_rf Feature_selection
cp ${script_path}/para_examples/Ldopa_FS/Dyskinesia/bagging_importance_para.R bagging_importance_rf
cp ${script_path}/para_examples/Ldopa_FS/Dyskinesia/feature_selection_para.R Feature_selection
pbsv2.pl "Rscript ${script_path}/Ldopa/split_samples_Ldopa_mergeTask_v4.R d > split_samples_Ldopa_mergeTask_v4.log; cd ${root}/Ldopa_mergingTask_FS/Dyskinesia/bagging_importance_rf; R --vanilla < ${script_path}/feature_selection/feature_selection_bagging_importance_v2_02.R; cd ${root}/Ldopa_mergingTask_FS/Dyskinesia/Feature_selection; R --vanilla < ${script_path}/feature_selection/feature_selection_rf_svm_screen_02_v3.R; R --vanilla < ${script_path}/feature_selection/feature_selection_caret_test_accu_03_v3.R" -ppn 10 -e -pmem 200000 -q bigmem

#------------#
#for sub 2.3
cd ${root}/Ldopa_mergingTask_FS/Bradykinesia
mkdir bagging_importance_rf Feature_selection
cp ${script_path}/para_examples/Ldopa_FS/Dyskinesia/bagging_importance_para.R bagging_importance_rf
cp ${script_path}/para_examples/Ldopa_FS/Dyskinesia/feature_selection_para.R Feature_selection
pbsv2.pl "Rscript ${script_path}/Ldopa/split_samples_Ldopa_mergeTask_v4.R b > split_samples_Ldopa_mergeTask_v4.log; cd ${root}/Ldopa_mergingTask_FS/Bradykinesia/bagging_importance_rf; R --vanilla < ${script_path}/feature_selection/feature_selection_bagging_importance_v2_02.R; cd ${root}/Ldopa_mergingTask_FS/Bradykinesia/Feature_selection; R --vanilla < ${script_path}/feature_selection/feature_selection_rf_svm_screen_02_v3.R; R --vanilla < ${script_path}/feature_selection/feature_selection_caret_test_accu_03_v3.R" -ppn 10 -e -pmem 200000 -q bigmem

###delete temp files/folds
cd ${root}/Ldopa_mergingTask_FS
rm -fr */b*/*out
rm -fr */F*/F*/_temp*

#-------------------------------------------#
#4.2, producing final submission features output, v1
mkdir -p ${root}/Ldopa_final_features_v1
cd ${root}/Ldopa_final_features_v1
R --vanilla < ${script_path}/Ldopa/Ldopa_get_final_fetures.R > Ldopa_get_final_fetures.log

#-------------------------------------------#
#4.3, testing testing feature output
cd ${root}/official_test
pbsv2.pl "python2 sc2FitModels.py tremor ${root}/Ldopa_final_features_v1/sub2_1_Tremor_fs_v1.csv > sub2_1_v1.log" -pmem 100000
pbsv2.pl "python2 sc2FitModels.py bradykinesia ${root}/Ldopa_final_features_v1/sub2_3_Bradykinesia_fs_v1.csv > sub2_3_v1.log" -pmem 100000
pbsv2.pl "python2 sc2FitModels.py dyskinesia ${root}/Ldopa_final_features_v1/sub2_2_Dyskinesia_fs_v1.csv > sub2_2_v1.log" -pmem 100000 

#---------------------------------------------------#
#5, machine learning after removing ttest sig features, results version 2
mkdir -p ${root}/Ldopa_PostTtest_FS
cd ${root}/Ldopa_PostTtest_FS

mkdir Tremor Dyskinesia Bradykinesia

#-------------------------------------------#
#5.1 ML processing

#------------#
#for sub 2.1
cd ${root}/Ldopa_PostTtest_FS/Tremor
mkdir bagging_importance_rf Feature_selection
cp ${script_path}/para_examples/Ldopa_FS/Tremor/bagging_importance_para.R bagging_importance_rf
cp ${script_path}/para_examples/Ldopa_FS/Tremor/feature_selection_para.R Feature_selection
pbsv2.pl "Rscript ${script_path}/Ldopa/split_samples_Ldopa_mergeTask_ttest_v5.R t > split_samples_Ldopa_mergeTask_ttest_v5.R.log; cd ${root}/Ldopa_PostTtest_FS/Tremor/bagging_importance_rf; R --vanilla < ${script_path}/feature_selection/feature_selection_bagging_importance_v2_02.R; cd ${root}/Ldopa_PostTtest_FS/Tremor/Feature_selection; R --vanilla < ${script_path}/feature_selection/feature_selection_rf_svm_screen_02_v3.R; R --vanilla < ${script_path}/feature_selection/feature_selection_caret_test_accu_03_v3.R" -ppn 10 -e -pmem 200000 -q bigmem

#------------#
#for sub 2.2
cd ${root}/Ldopa_PostTtest_FS/Dyskinesia
mkdir bagging_importance_rf Feature_selection
cp ${script_path}/para_examples/Ldopa_FS/Dyskinesia/bagging_importance_para.R bagging_importance_rf
cp ${script_path}/para_examples/Ldopa_FS/Dyskinesia/feature_selection_para.R Feature_selection
pbsv2.pl "Rscript ${script_path}/Ldopa/split_samples_Ldopa_mergeTask_ttest_v5.R d > split_samples_Ldopa_mergeTask_ttest_v5.R.log; cd ${root}/Ldopa_PostTtest_FS/Dyskinesia/bagging_importance_rf; R --vanilla < ${script_path}/feature_selection/feature_selection_bagging_importance_v2_02.R; cd ${root}/Ldopa_PostTtest_FS/Dyskinesia/Feature_selection; R --vanilla < ${script_path}/feature_selection/feature_selection_rf_svm_screen_02_v3.R; R --vanilla < ${script_path}/feature_selection/feature_selection_caret_test_accu_03_v3.R" -ppn 10 -e -pmem 200000 -q bigmem

#------------#
#for sub 2.3
cd ${root}/Ldopa_PostTtest_FS/Bradykinesia
mkdir bagging_importance_rf Feature_selection
cp ${script_path}/para_examples/Ldopa_FS/Dyskinesia/bagging_importance_para.R bagging_importance_rf
cp ${script_path}/para_examples/Ldopa_FS/Dyskinesia/feature_selection_para.R Feature_selection
pbsv2.pl "Rscript ${script_path}/Ldopa/split_samples_Ldopa_mergeTask_ttest_v5.R b > split_samples_Ldopa_mergeTask_ttest_v5.R.log; cd ${root}/Ldopa_PostTtest_FS/Bradykinesia/bagging_importance_rf; R --vanilla < ${script_path}/feature_selection/feature_selection_bagging_importance_v2_02.R; cd ${root}/Ldopa_PostTtest_FS/Bradykinesia/Feature_selection; R --vanilla < ${script_path}/feature_selection/feature_selection_rf_svm_screen_02_v3.R; R --vanilla < ${script_path}/feature_selection/feature_selection_caret_test_accu_03_v3.R" -ppn 10 -e -pmem 200000 -q bigmem

###delete temp files/folds
cd ${root}/Ldopa_PostTtest_FS
rm -fr */b*/*out
rm -fr */F*/F*/_temp*

#-------------------------------------------#
#5.2, producing testing feature output
mkdir -p ${root}/Ldopa_final_features_v2
cd ${root}/Ldopa_final_features_v2
R --vanilla < ${script_path}/Ldopa/Ldopa_get_final_fetures_v2.R > Ldopa_get_final_fetures_v2.log

#-------------------------------------------#
#5.3, testing testing feature output
cd ${root}/official_test
pbsv2.pl "python2 sc2FitModels.py tremor ${root}/Ldopa_final_features_v2/sub2_1_Tremor_fs_v2.csv > sub2_1_v2.log" -pmem 100000
pbsv2.pl "python2 sc2FitModels.py bradykinesia ${root}/Ldopa_final_features_v2/sub2_3_Bradykinesia_fs_v2.csv > sub2_3_v2.log" -pmem 100000
pbsv2.pl "python2 sc2FitModels.py dyskinesia ${root}/Ldopa_final_features_v2/sub2_2_Dyskinesia_fs_v2.csv > sub2_2_v2.log" -pmem 100000 

