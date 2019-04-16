import argparse
import pandas as pd 
def parse_args(): 
    parser=argparse.ArgumentParser(description="get mean start/end times for asleep, in bed, sleep duration, time in bed duration") 
    parser.add_argument("--table_asleep",default="out.HKCategoryValueSleepAnalysisAsleep") 
    parser.add_argument("--table_inbed",default="out.HKCategoryValueSleepAnalysisInBed") 
    parser.add_argument("--outf",default="hk.sleep.habits.summary.tsv")
    return parser.parse_args() 

def main(): 
    args=parse_args() 
    



    
    
