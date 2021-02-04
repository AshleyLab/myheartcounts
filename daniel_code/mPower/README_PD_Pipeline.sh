#!/bin/bash

#this script described the pipeline that how to produce the features

root=~/PD_dream #working root dir
script_path=~/PD_dream/scripts #all scripts were stored here.
export PATH==${script_path}:$PATH 

#---------------------------------------------------#
#installing necessary R libraries
R --vanilla < ${script_path}/install_R_lib.R
#install PDdream library
R CMD INSTALL ${script_path}/PDdream_0.2.1.tar.gz

#---------------------------------------------------#
#1, download & and transforming raw data
mkdir -p ${root}/download_training_data ${root}/download_supp_data ${root}/download_testing_data
cd ${root}/download_training_data
#download data
R --vanilla < ${script_path}/download_training_rawdata.R
#to transform raw data to data matrix
R --vanilla < ${script_path}/download_training_data/rawdata2dm_accel_walking_outbound.R
R --vanilla < ${script_path}/download_training_data/rawdata2dm_accel_walking_rest.R
R --vanilla < ${script_path}/download_training_data/rawdata2dm_accel_walking_return.R
R --vanilla < ${script_path}/download_training_data/rawdata2dm_deviceMotion_walking_outbound.R
R --vanilla < ${script_path}/download_training_data/rawdata2dm_deviceMotion_walking_rest.R
R --vanilla < ${script_path}/download_training_data/rawdata2dm_deviceMotion_walking_return.R
R --vanilla < ${script_path}/download_training_data/rawdata2dm_pedometer_walking_outbound.R
R --vanilla < ${script_path}/download_training_data/rawdata2dm_pedometer_walking_return.R

cd ${root}/download_supp_data
R --vanilla < ${script_path}/download_supp_rawdata.R
R --vanilla < ${script_path}/download_supp_data/rawdata2dm_accel_walking_outbound.R
R --vanilla < ${script_path}/download_supp_data/rawdata2dm_accel_walking_rest.R
R --vanilla < ${script_path}/download_supp_data/rawdata2dm_accel_walking_return.R
R --vanilla < ${script_path}/download_supp_data/rawdata2dm_deviceMotion_walking_outbound.R
R --vanilla < ${script_path}/download_supp_data/rawdata2dm_deviceMotion_walking_rest.R
R --vanilla < ${script_path}/download_supp_data/rawdata2dm_deviceMotion_walking_return.R
R --vanilla < ${script_path}/download_supp_data/rawdata2dm_pedometer_walking_outbound.R
R --vanilla < ${script_path}/download_supp_data/rawdata2dm_pedometer_walking_return.R

cd ${root}/download_testing_data
R --vanilla < ${script_path}/download_testing_rawdata.R
R --vanilla < ${script_path}/download_testing_data/rawdata2dm_accel_walking_outbound.R
R --vanilla < ${script_path}/download_testing_data/rawdata2dm_accel_walking_rest.R
R --vanilla < ${script_path}/download_testing_data/rawdata2dm_accel_walking_return.R
R --vanilla < ${script_path}/download_testing_data/rawdata2dm_deviceMotion_walking_outbound.R
R --vanilla < ${script_path}/download_testing_data/rawdata2dm_deviceMotion_walking_rest.R
R --vanilla < ${script_path}/download_testing_data/rawdata2dm_deviceMotion_walking_return.R
R --vanilla < ${script_path}/download_testing_data/rawdata2dm_pedometer_walking_outbound.R
R --vanilla < ${script_path}/download_testing_data/rawdata2dm_pedometer_walking_return.R

#---------------------------------------------------#
#2, producing raw features data
mkdir -p ${root}/proc_raw_features 
cd ${root}/proc_raw_features
#!!!using HPC to submit the following scripts with different parameters to accelerate calculation
# example: Rscript ${script_path}/run2_wavelets1.R 1 1 100 tf2_1_100.txt training
# parameter NA means all the data
files=`seq 1 6`
for f in ${files[@]};do
	#for training
	Rscript ${script_path}/run2_wavelets1.R ${f} 1 NA run2_f${f}.txt training 
	Rscript ${script_path}/run3_wavelets1.R ${f} 1 NA run3_f${f}.txt training 
	Rscript ${script_path}/run4_wavelets1.R ${f} 1 NA run4_f${f}.txt training 
	Rscript ${script_path}/run9_wavelets1.R ${f} 1 NA run9_f${f}.txt training 
	Rscript ${script_path}/run10_wavelets1.R ${f} 1 NA run10_f${f}.txt training 
	Rscript ${script_path}/run11_wavelets1.R ${f} 1 NA run11_f${f}.txt training 

	#for supp training
    Rscript ${script_path}/run2_wavelets1.R ${f} 1 NA srun2_f${f}.txt supp
    Rscript ${script_path}/run3_wavelets1.R ${f} 1 NA srun3_f${f}.txt supp
    Rscript ${script_path}/run4_wavelets1.R ${f} 1 NA srun4_f${f}.txt supp
    Rscript ${script_path}/run9_wavelets1.R ${f} 1 NA srun9_f${f}.txt supp
    Rscript ${script_path}/run10_wavelets1.R ${f} 1 NA srun10_f${f}.txt supp
    Rscript ${script_path}/run11_wavelets1.R ${f} 1 NA srun11_f${f}.txt supp

	#for testing
    Rscript ${script_path}/run2_wavelets1.R ${f} 1 NA trun2_f${f}.txt testing
    Rscript ${script_path}/run3_wavelets1.R ${f} 1 NA trun3_f${f}.txt testing
    Rscript ${script_path}/run4_wavelets1.R ${f} 1 NA trun4_f${f}.txt testing
    Rscript ${script_path}/run9_wavelets1.R ${f} 1 NA trun9_f${f}.txt testing
    Rscript ${script_path}/run10_wavelets1.R ${f} 1 NA trun10_f${f}.txt testing
    Rscript ${script_path}/run11_wavelets1.R ${f} 1 NA trun11_f${f}.txt testing	
done

# then cat all output together
#for testing
cat trun2_f*.txt > trun2.txt
cat trun3_f*.txt > trun3.txt
cat trun4_f*.txt > trun4.txt
cat trun9_f*.txt > trun9.txt
cat trun10_f*.txt > trun10.txt
cat trun11_f*.txt > trun11.txt

#for training (including training & supp training)
cat run2_f*.txt > run2.txt
cat srun2_f*.txt >> run2.txt
cat run3_f*.txt > run3.txt
cat srun3_f*.txt >> run3.txt
cat run4_f*.txt > run4.txt
cat srun4_f*.txt >> run4.txt
cat run9_f*.txt > run9.txt
cat srun9_f*.txt >> run9.txt
cat run10_f*.txt > run10.txt
cat srun10_f*.txt >> run10.txt
cat run11_f*.txt > run11.txt
cat srun11_f*.txt >> run11.txt

#---------------------------------------------------#
#3, producing features

#for training (including training & supp training)
#only keeping specific recordIds
Rscript ${script_path}/filter_recordId.R run2.txt run2_f.txt
Rscript ${script_path}/filter_recordId.R run3.txt run3_f.txt
Rscript ${script_path}/filter_recordId.R run4.txt run4_f.txt
Rscript ${script_path}/filter_recordId.R run9.txt run9_f.txt
Rscript ${script_path}/filter_recordId.R run10.txt run10_f.txt
Rscript ${script_path}/filter_recordId.R run11.txt run11_f.txt

Rscript ${script_path}/run_table_recordId.R run2_f.txt run2_table.txt m2.f
Rscript ${script_path}/run_table_recordId.R run3_f.txt run3_table.txt m3.f
Rscript ${script_path}/run_table_recordId.R run4_f.txt run4_table.txt m4.f
Rscript ${script_path}/run_table_recordId.R run9_f.txt run9_table.txt m9.f
Rscript ${script_path}/run_table_recordId.R run10_f.txt run10_table.txt m10.f
Rscript ${script_path}/run_table_recordId.R run11_f.txt run11_table.txt m11.f

#for submition version of all recordIds
Rscript ${script_path}/run_table_recordId.R run2.txt run2_table.txt m2.f
Rscript ${script_path}/run_table_recordId.R run3.txt run3_table.txt m3.f
Rscript ${script_path}/run_table_recordId.R run4.txt run4_table.txt m4.f
Rscript ${script_path}/run_table_recordId.R run9.txt run9_table.txt m9.f
Rscript ${script_path}/run_table_recordId.R run10.txt run10_table.txt m10.f
Rscript ${script_path}/run_table_recordId.R run11.txt run11_table.txt m11.f

#for testing
Rscript ${script_path}/run_table_test.R trun2.txt trun2_table.txt m2.f
Rscript ${script_path}/run_table_test.R trun3.txt trun3_table.txt m3.f
Rscript ${script_path}/run_table_test.R trun4.txt trun4_table.txt m4.f
Rscript ${script_path}/run_table_test.R trun9.txt trun9_table.txt m9.f
Rscript ${script_path}/run_table_test.R trun10.txt trun10_table.txt m10.f
Rscript ${script_path}/run_table_test.R trun11.txt trun11_table.txt m11.f

#---------------------------------------------------#
#4, output all features

#for training (including training & supp training)
join run2_table.txt run3_table.txt > j2_j3.txt
join j2_j3.txt run4_table.txt > j2_j4.txt
join j2_j4.txt run9_table.txt > j2_j9.txt
join j2_j9.txt run10_table.txt > j2_j10.txt
join j2_j10.txt run11_table.txt > j2_j11.txt
rm -f j2_j3.txt j2_j4.txt j2_j9.txt j2_j10.txt

#for testing
join trun2_table.txt trun3_table.txt > tj2_j3.txt
join tj2_j3.txt trun4_table.txt > tj2_j4.txt
join tj2_j4.txt trun9_table.txt > tj2_j9.txt
join tj2_j9.txt trun10_table.txt > tj2_j10.txt
join tj2_j10.txt trun11_table.txt > tj2_j11.txt
rm -f tj2_j3.txt tj2_j4.txt tj2_j9.txt tj2_j10.txt

#---------------------------------------------------#
#5, machine learning using caret
#!!Notice: 	1) all *para.R file examples please refer to ${script_path}/para_examples
#!!			2) slurm system and general queue was the default HPC system and queue name. PBS was also supported by changing the parameters of pbsv2.pl 

mkdir -p ${root}/R2_R11_feature_selection_PDdream
cd ${root}/R2_R11_feature_selection_PDdream
#----------------------------------------------#
#5.1 prepare traning, validation, & testing set
#produce demo.txt
R --vanilla < ${script_path}/pr_demo.R
#produce training, validation, and testing data sets
vi split_samples_para.R
R --vanilla < ${script_path}/feature_selection/split_samples.R
#----------------------------------------------#
#5.2 importance ranking with rf & svm
#rf imp bagging
mkdir -p ${root}/R2_R11_feature_selection_PDdream/bagging_importance_rf
cd ${root}/R2_R11_feature_selection_PDdream/bagging_importance_rf
vi bagging_importance_para.R
R --vanilla < ${script_path}/feature_selection/feature_selection_bagging_importance_v2_02.R
#svm imp bagging
mkdir -p ${root}/R2_R11_feature_selection_PDdream/bagging_importance_svm
cd ${root}/R2_R11_feature_selection_PDdream/bagging_importance_svm
vi bagging_importance_para.R
R --vanilla < ${script_path}/feature_selection/feature_selection_bagging_importance_v2_02.R

#----------------------------------------------#
#5.3 feature selection
#merging imp files
mkdir -p ${root}/R2_R11_feature_selection_PDdream/Merging_rf_svm_imp_feature_selection
cd ${root}/R2_R11_feature_selection_PDdream/Merging_rf_svm_imp_feature_selection
Rscript ${script_path}/feature_selection/feature_selection_merge_rf_svm_imp.R ../bagging_importance_rf/rf_500_imp.txt ../bagging_importance_svm/svmRadial_500_imp.txt merge_svm_rf_imp.txt > feature_selection_merge_rf_svm_imp.R.log
head -n 3001 merge_svm_rf_imp.txt  > merge_svm_rf_imp_top3000.txt
vi feature_selection_para.R
#for training the model, and selecting the best using validation set
R --vanilla < ${script_path}/feature_selection/feature_selection_rf_svm_screen_02_v3.R
#for testing 
R --vanilla < ${script_path}/feature_selection/feature_selection_caret_test_accu_03_v2.R

#----------------------------------------------#
#5.4 narrowdown feature selection
mkdir -p ${root}/R2_R11_feature_selection_PDdream/narrowDown_Feature_selection_m2_m9
cd ${root}/R2_R11_feature_selection_PDdream/narrowDown_Feature_selection_m2_m9
vi feature_selection_para.R
R --vanilla < ${script_path}/feature_selection/feature_selection_rf_svm_screen_02_v3.R
R --vanilla < ${script_path}/feature_selection/feature_selection_caret_test_accu_03_v2.R


#---------------------------------------------------#
#6, output selected features
#----------------------------------------------#
#6.1 feature set 1
#top 1351 features in Merging_rf_svm_imp_feature_selection/merge_svm_rf_imp_top3000.txt
mkdir -p ${root}/final_features
cd ${root}/final_features
Rscript ${script_path}/get_final_fetures.R ${root}/proc_raw_features/run_table_v3_testing/tj2_j11.txt ${root}/R2_R11_feature_selection_PDdream/Merging_rf_svm_imp_feature_selection/merge_svm_rf_imp_top3000.txt 751 mPower_feature1_required.csv mPower_feature1_all.csv ${root}/proc_raw_features/run_table_v3_training/j2_j11.txt

#6.2 feature set 2
#top 751
Rscript ${script_path}/get_final_fetures.R ${root}/proc_raw_features/run_table_v3_testing/tj2_j11.txt ${root}/R2_R11_feature_selection_PDdream/Merging_rf_svm_imp_feature_selection_432/merge_svm_rf_imp_top3000.txt 451 mPower_feature2_required.csv mPower_feature2_all.csv ${root}/proc_raw_features/run_table_v3_training/j2_j11.txt

#test if the feture files are qualified
R --vanilla < ${script_path}/test_features.R > test_features.log

