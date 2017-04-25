#ORDER FOR EXECUTING SCRIPTS IN THIS DIRECTORY 
#CLEANUP DATA 
python cleanup.py 
python cleanup_json.py 

#ORGANIZE DATA BY CATEGORY, SUBJECT, AND TIMESTAMP 
python concat_6min_walk_and_displacement.py  
python concat_card_displacement.py  
python concat_healthkit.py  
python concat_motiontracker.py