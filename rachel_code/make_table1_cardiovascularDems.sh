################################
# diagnosed with heart disease?
################################

# Option 1 (A + B)

#A
cat /srv/gsfs0/projects/ashley/common/myheart/data/tables/cardiovascular-risk_factors-v1.tsv | cut -f10 | grep 1\] | wc -l

#B
cat /srv/gsfs0/projects/ashley/common/myheart/data/tables/cardiovascular-risk_factors-v1.tsv | cut -f10 | grep 1, | wc -l

# Optons 2-10

for i in `seq 2 1 10`; do less /srv/gsfs0/projects/ashley/common/myheart/data/tables/cardiovascular-risk_factors-v1.tsv | cut -f10 | grep ${i} | wc -l; done



# medications
for i in `seq 1 1 4`; do less /srv/gsfs0/projects/ashley/common/myheart/data/tables/cardiovascular-risk_factors-v1.tsv | cut -f11 | grep ${i} | wc -l; done

# vascular disease
for i in `seq 1 1 7`; do less /srv/gsfs0/projects/ashley/common/myheart/data/tables/cardiovascular-risk_factors-v1.tsv | cut -f12 | grep ${i} | wc -l; done

# family history of heart disease
for i in `seq 1 1 3`; do less /srv/gsfs0/projects/ashley/common/myheart/data/tables/cardiovascular-risk_factors-v1.tsv | cut -f9 | grep ${i} | wc -l; done


