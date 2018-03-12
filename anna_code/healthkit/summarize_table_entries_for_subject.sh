#for subject in 0a3a8074-130f-4eae-8ee6-98485df94b58 1aaec753-1685-490c-9468-62c886ab3cae 2a0701f9-1f25-477f-abec-9ed4c5e9ec8 e8ead3c7-055e-4a5e-b08d-9043918ceb09 ec6c54ff-68e9-4086-bfc4-f98e9eb3ab80
for subject in 2a0701f9-1f25-477f-abec-9ed4c55e9ec8 
do
python summarize_table_entries_for_subject.py --subject $subject  \
       --source_tables /scratch/PI/euan/projects/mhc/data/tables/cardiovascular-HealthKitDataCollector-v1.tsv \
       --outf $subject.HealthKitDataCollector.txt
python summarize_table_entries_for_subject.py --subject $subject  \
       --source_tables /scratch/PI/euan/projects/mhc/data/tables/cardiovascular-motionActivityCollector-v1.tsv /scratch/PI/euan/projects/mhc/data/tables/cardiovascular-motionTracker-v1.tsv \
       --outf $subject.MotionTracker.txt
done
