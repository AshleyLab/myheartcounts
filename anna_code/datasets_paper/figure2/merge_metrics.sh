#python merge_metrics.py --histograms v1.motion.hist.by_subject.tsv v1.hk.hist.by_subject.tsv v1.6mwt.hist.by_subject.tsv v1.surveys.by_subject.tsv \
#    --categories CoreMotion HealthKit WalkTest Surveys \
#    --outf merged.by_subject.txt 

#python merge_metrics.py --histograms v1.motion.hist.by_date.tsv v1.hk.hist.by_date.tsv v1.6mwt.hist.by_date.tsv v1.surveys.by_date.tsv \
#    --categories CoreMotion HealthKit WalkTest Surveys \
#    --outf merged.by_date.txt 

python merge_metrics.py --histograms \
    v1.surveys.activitysleep.by_date.tsv \
    v1.surveys.day1.by_date.tsv \
    v1.surveys.life.satisfaction.by_date.tsv \
    v1.surveys.diet.by_date.tsv \
    v1.surveys.parq.by_date.tsv \
    v1.surveys.dailycheck.by_date.tsv \
    v1.surveys.heartage.by_date.tsv \
    v1.surveys.riskfactors.by_date.tsv \
    --categories ActivitySleep Day1 LifeSatisfaction Diet ParQ DailyCheck HeartAge RiskFactors \
    --outf merged.surveys.by_date.txt 

python merge_metrics.py --histograms \
    v1.surveys.activitysleep.by_subject.tsv \
    v1.surveys.day1.by_subject.tsv \
    v1.surveys.life.satisfaction.by_subject.tsv \
    v1.surveys.diet.by_subject.tsv \
    v1.surveys.parq.by_subject.tsv \
    v1.surveys.dailycheck.by_subject.tsv \
    v1.surveys.heartage.by_subject.tsv \
    v1.surveys.riskfactors.by_subject.tsv \
    --categories ActivitySleep Day1 LifeSatisfaction Diet ParQ DailyCheck HeartAge RiskFactors \
    --outf merged.surveys.by_subject.txt 

