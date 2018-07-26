import numpy as np

def load_motion_tracker_summary(filepath):
    dtype_dict=dict()
    dtype_dict['names']=("Subject",
                         "DaysInStudy",
                         "Intervention",
                         "DayIndex",
                         "DayType",
                         "Activity",
                         "Duration_in_Minutes",
                         "Fraction",
                         "Numentries")
    dtype_dict['formats']=('S36',
                           'i',
                           'S36',
                           'i',
                           'i',
                           'S36',
                           'f',
                           'f',
                           'i')
    data=np.genfromtxt(filepath,
                       dtype=dtype_dict['formats'],
                       names=dtype_dict['names'],
                       delimiter='\t',
                       skip_header=True,
                       loose=True,
                       invalid_raise=False)

    return data
def load_health_kit_summary(filepath):
    dtype_dict=dict()
    dtype_dict['names']=("Subject",
                         "DaysInStudy",
                         "Intervention",
                         "DayIndex",
                         "DayType",
                         "Metric",
                         "Value")
    dtype_dict['formats']=('S36',
                           'i',
                           'S36',
                           'i',
                           'i',
                           'S36',
                           'f')
    data=np.genfromtxt(filepath,
                       dtype=dtype_dict['formats'],
                       names=dtype_dict['names'],
                       delimiter='\t',
                       skip_header=True,
                       loose=True,
                       invalid_raise=False)

    return data

if __name__=="__main__":
    #TESTS ON SHERLOCK
    import pdb
    filepath_motiontracker="/scratch/PI/euan/projects/mhc/data/timeseries_v2/summary/motion_tracker_combined.filered.txt"
    filepath_healthkit="/scratch/PI/euan/projects/mhc/data/timeseries_v2/summary/health_kit_combined.txt"
    data_motiontracker=load_motion_tracker_summary(filepath_motiontracker)
    data_healthkit=load_health_kit_summary(filepath_healthkit)
    pdb.set_trace() 
