

##################################################
## Figure 3B - Bed Time & Satisfaction
##################################################

# On SCG3
# Dir: /srv/gsfs0/projects/ashley/rachel/mhc/workspace_october2015

### Shell Commands ###


# get a list of healthcodes

ls /srv/gsfs0/projects/ashley/common/myheart/grouped_timeseries/motiontracker/motiontracker/
 >> healthCodes.tsv


# Find out bed times and wake times for all indviduals

# wake times

for i in `cat healthCodes.tsv`; do perl parse_activity_data_forSleepTime.pl ` echo $i |sed 's/\.tsv//'` /srv/gsfs0/projects/ashley/common/myheart/grouped_timeseries/motiontracker/motiontracker/$i 1 >> wakeTimes.txt; done


# bed times
for i in `cat healthCodes.tsv`; do tac /srv/gsfs0/projects/ashley/common/myheart/grouped_timeseries/motiontracker/motiontracker/$i > motiontracker/$i.backwards; done

for i in `cat healthCodes.tsv`; do perl parse_activity_data_forSleepTime.pl ` echo $i |sed 's/\.tsv//'` motiontracker/$i.backwards 2 >> bedTimes.txt; done 


# If they have more than 3 times, find the median time

cat wakeTimes.txt | perl parseTimes.pl  > wakeTimesMedian.txt
cat bedTimes.txt | perl parseTimes.pl  > bedTimesMedian.txt


# Rank individuals and keep top 10% and bottom 10%

sort -k2,2n wakeTimesMedian.txt  > wakeTimesMedian.sorted.txt 
sort -k2,2n bedTimesMedian.txt  > bedTimesMedian.sorted.txt 

awk '{if(NF==2){print}}' wakeTimesMedian.sorted.txt  > wakeTimesMedian.sorted.final.txt 
awk '{if(NF==2){print}}' bedTimesMedian.sorted.txt  > bedTimesMedian.sorted.final.txt

head -1748 wakeTimesMedian.sorted.final.txt  > earlyRisers.txt
tail -1748 wakeTimesMedian.sorted.final.txt  > lateRisers.txt

head -1758 bedTimesMedian.sorted.final.txt > earlyToBed.txt
tail -1758  bedTimesMedian.sorted.final.txt > lateToBed.txt


sort earlyRisers.txt > earlyRisers.sorted.txt
sort earlyToBed.txt > earlyToBed.sorted.txt
sort lateToBed.txt > lateToBed.sorted.txt
sort lateRisers.txt > lateRisers.sorted.txt

join -j 1  earlyRisers.sorted.txt earlyToBed.sorted.txt > earlyRise.earlyBed.txt
join -j 1  earlyRisers.sorted.txt lateToBed.sorted.txt > earlyRise.lateBed.txt
join -j 1  lateRisers.sorted.txt lateToBed.sorted.txt > lateRise.lateBed.txt
join -j 1  lateRisers.sorted.txt earlyToBed.sorted.txt > lateRise.earlyBed.txt


# Intersect early to bed or late to bed etc with satisfaction with life data & plot
module load r/3.2.0 

R --vanilla < plot_sleep_satisfied.R





##################################################
## Supplemental Figure 2 - Bed Time & Age
##################################################

# On SCG3
# Dir: /srv/gsfs0/projects/ashley/rachel/mhc/workspace_october2015


# Intersect bed time with Age
R --vanilla < plot_bedTime_age.R



##################################################
## Table 1: Cardiovascular Demographics
##################################################

# On SCG3
# Dir: /srv/gsfs0/projects/ashley/rachel/mhc/workspace_october2015

sh make_table1_cardiovascularDems.sh 


##################################################
## Table 2: Activity Demographics
##################################################

# On SCG3
# Dir: /srv/gsfs0/projects/ashley/rachel/mhc/workspace_october2015


R --vanilla < make_table2_activityDems.R






