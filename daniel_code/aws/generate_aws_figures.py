# -*- coding: utf-8 -*-
"""
Created on Sat May 11 17:25:04 2019

Generates various figures for AWS Demographics analytics

@author: Daniel Wu
"""

import numpy as np
import pandas as pd
import json
from collections import defaultdict
from scipy import stats
import matplotlib.pyplot as plt

#Anna's function to map AWS client IDs to healthcodes, returns dict
def map_aws_to_healthcode(source_table = r'/scratch/PI/euan/projects/mhc/code/daniel_code/aws/tables/cardiovascular-AwsClientIdTask-v1.tsv'): 
    client_id_to_health_code_id=dict()
    #read in the data 
    dtype_dict=dict() 
    dtype_dict['names']=('skip',
                         'recordId',
                         'appVersion',
                         'phoneInfo',
                         'uploadDate',
                         'healthCode',
                         'externalId',
                         'dataGroups',
                         'createdOn',
                         'createdOnTimeZone',
                         'userSharingScope',
                         'validationErrors',
                         'AwsClientId')
    dtype_dict['formats']=('S36',
                           'S36',
                           'S36',
                           'S36',
                           'S36',
                           'S36',
                           'S36',
                           'S36',
                           'S36',
                           'S36',
                           'S36',
                           'S36',
                           'S36')
    try: 
        data=np.genfromtxt(source_table,
                           names=dtype_dict['names'],
                           dtype=dtype_dict['formats'],
                           delimiter='\t',
                           skip_header=True,
                           loose=True,
                           invalid_raise=False)
    except:
        print("failed to load file:"+str(source_table))
        raise Exception() 

    #create a mapping of client id to healthCode 
    for line in data: 
        client_id_to_health_code_id[line['AwsClientId'].decode('UTF-8')] = line['healthCode'].decode('UTF-8')    
    return client_id_to_health_code_id


def reject_outliers(data, m=3):
    outliers = data[np.logical_or(abs(data - np.mean(data)) >= m * np.std(data), data <= 2)]
    clean = data[np.logical_and(abs(data - np.mean(data)) < m * np.std(data), data>2)]
    
    num_less = (data <= 2).sum()#(outliers < np.mean(data)).sum()
    num_more = (outliers > np.mean(data)).sum()

    return clean, num_less, num_more

def page_duration():
    '''generates a table and figure describing average time spent on an activity based on activity'''
    
    print("Generating page duration table")
    
    freq = defaultdict(list)
    
    with open(r'/scratch/PI/euan/projects/mhc/code/daniel_code/aws/tables/PageEndedActivities.txt', 'r') as file:
        print("Loading in data")
        for line in file:
            data = json.loads(line.rstrip())
            dur = int(data["attributes"]["duration"])
            act = data["attributes"]["pageName"]
            
            freq[act].append(dur)
            
    print("Finished loading the data - beginning parsing")
    #Describe all the results
    for key in freq.keys():
        print("Stats for activity {}".format(key))
        print(stats.describe(freq[key]))
        
        #clean up the data a little
        clean, num_less, num_more = reject_outliers(np.array(freq[key]))
        
        #Plot everything
        fig = plt.hist(clean)
        plt.title('Duration spent on activity {} \n {} 2 or less, {} high outliers'.format(key, num_less, num_more))
        plt.xlabel("Duration")
        plt.ylabel("# Occurences")
        plt.savefig("/scratch/PI/euan/projects/mhc/code/daniel_code/aws/figures/duration_{}.png".format(key))
        plt.clf()

def age_activity(healthcode_map, uniq_only=True):

    '''Generates a figure and table of the average duration spent on various activities depending on age'''
    
    print("Generating age activity table")

    
    age_table = pd.read_csv(r'tables/demographics_summary_v2.age.tsv', delimiter='\t').set_index('Subject')
    
    freq = defaultdict(list)
    uniq = set()
    
    with open(r'/scratch/PI/euan/projects/mhc/code/daniel_code/aws/tables/PageEndedActivities.txt', 'r') as file:
        print("Loading in data")
        for line in file:
            data = json.loads(line.rstrip())
            aws_id = data["client"]["client_id"]
            act = data["attributes"]["pageName"]
            
            #Include only never before seen ids for each activity
            if(uniq_only):
                if((aws_id, act) in uniq):
                    continue
                else:
                    uniq.add((aws_id, act))
            
            #Get the age
            try:
                healthcode = healthcode_map[aws_id]
                age = int(age_table.loc[healthcode, 'Agex'])
                
                freq[act].append(age)
            except KeyError:
                print("AWS_id not found {}".format(aws_id))
            
    print("Finished loading the data - beginning parsing")
    #Describe all the results
    for key in freq.keys():
        print("Stats for activity {}".format(key))
        print(stats.describe(freq[key]))
        
        
        #Plot everything
        fig = plt.hist(freq[key])
        plt.title('Age spent on activity {}'.format(key))
        plt.xlabel("Age")
        plt.ylabel("# Occurences")
        plt.savefig("/scratch/PI/euan/projects/mhc/code/daniel_code/aws/figures/age_{}.png".format(key))
        plt.clf()



def usage_graph(healthcode_map):

    '''
    Generates a figure of overall activities per person
    Returns healthcodes of the 10 most active people
    '''
    
    usage = defaultdict(int)
    invalid_aws_id = set()
    
    with open(r'/scratch/PI/euan/projects/mhc/code/daniel_code/aws/tables/PageEndedActivities.txt', 'r') as file:
        print("Loading in data")
        for line in file:
            data = json.loads(line.rstrip())
            aws_id = data["client"]["client_id"]
            

            #Get the healthcode
            try:
                healthcode = healthcode_map[aws_id] 
                
                #Count usage
                usage[healthcode] += 1
            except KeyError:
                #print("AWS_id not found {}".format(aws_id))
                invalid_aws_id.add(aws_id)
            
    print("There were {} distinct invalid aws ids".format(len(invalid_aws_id)))
    print("Finished loading the data - beginning graphing")
        
    #Plot everything
    fig = plt.hist(list(usage.values()))
    plt.title("Activity of users")
    plt.xlabel("# activities")
    plt.ylabel("# users")
    plt.savefig("/scratch/PI/euan/projects/mhc/code/daniel_code/aws/figures/overall_activity.png")
    
    print("Our 10 most active healthcodes were:")
    most_active = sorted(usage, key=usage.get, reverse=True)[:10]
    for i in range(10):
        print("{} with {} activities".format(most_active[i], usage[most_active[i]]))

    return most_active


def journey_map(healthcode_map, healthcodes):

    '''
    Looks at the events and behavior of a specific set of healthcodes
    '''
    from datetime import datetime

    events = defaultdict(list)
    times = defaultdict(list)
    invalid_aws_id = set()
    
    with open(r'/scratch/PI/euan/projects/mhc/code/daniel_code/aws/tables/PageEndedActivities.txt', 'r') as file:
        print("Loading in data")
        for line in file:
            data = json.loads(line.rstrip())
            aws_id = data["client"]["client_id"]
            

            #Get the healthcode
            try:
                healthcode = healthcode_map[aws_id] 
                
                #Store events
                if healthcode in healthcodes:
                    act = data["attributes"]["pageName"]
                    #Convert to seconds instead of milliseconds timestamp
                    time = datetime.fromtimestamp(data["event_timestamp"]/1000)

                    events[healthcode].append(act[3:-14])
                    times[healthcode].append(time)
            except KeyError:
                invalid_aws_id.add(aws_id)
            
    print("There were {} distinct invalid aws ids".format(len(invalid_aws_id)))
    print("Finished loading the data - beginning graphing")
    
    for healthcode in healthcodes:
        timeline(healthcode, dates = times[healthcode], names = events[healthcode])


def timeline(filename, dates, names):
    
    '''
    timeline(filename, dates, names)
    Function which saves a figure of a timeline of events
    
    filename - unique string to append
    dates - array of datetine objects of each event
    names - array of labels of events
    '''
    
    import matplotlib.dates as mdates
    from datetime import datetime
    
    print("Saving timeline {}".format(filename))
    
    # Choose some nice levels
    levels = np.tile(np.linspace(-5, 5, num=50),
                     int(np.ceil(len(dates)/50)))[:len(dates)]
    
    # Create figure and plot a stem plot with the date
    fig, ax = plt.subplots(figsize=(200, 40))
    ax.set(title="Activity of user {}".format(filename))
    
    markerline, stemline, baseline = ax.stem(dates, levels,
                                             linefmt="C3-", basefmt="k-")
    
    plt.setp(markerline, mec="k", mfc="w", zorder=3)
    
    # Shift the markers to the baseline by replacing the y-data by zeros.
    markerline.set_ydata(np.zeros(len(dates)))
    
    # annotate lines
    vert = np.array(['top', 'bottom'])[(levels > 0).astype(int)]
    for d, l, r, va in zip(dates, levels, names, vert):
        ax.annotate(r, xy=(d, l), xytext=(-3, np.sign(l)*3),
                    textcoords="offset points", va=va, ha="right")
    
    # format xaxis with 4 month intervals
    ax.get_xaxis().set_major_locator(mdates.MonthLocator(interval=4))
    ax.get_xaxis().set_major_formatter(mdates.DateFormatter("%b %Y"))
    plt.setp(ax.get_xticklabels(), rotation=30, ha="right")
    
    # remove y axis and spines
    ax.get_yaxis().set_visible(False)
    for spine in ["left", "top", "right"]:
        ax.spines[spine].set_visible(False)
    
    ax.margins(y=0.1)
    plt.savefig("/scratch/PI/euan/projects/mhc/code/daniel_code/aws/figures/user_timeline_{}.png".format(filename))
    plt.close()
    
    #Plot histogram of dates
    df = pd.DataFrame(np.ones(len(dates)), pd.DatetimeIndex(dates, name='dates'))
    fig = df.resample('D').sum().hist()
    plt.title("Activity of user {}".format(filename))
    plt.ylabel("# activities")
    plt.xlabel("Date")
    plt.savefig("/scratch/PI/euan/projects/mhc/code/daniel_code/aws/figures/user_hist_{}.png".format(filename))
    plt.close()

if __name__ == '__main__':
    
    healthcode_map = map_aws_to_healthcode()
    #age_activity(healthcode_map)
    
    #page_duration()
    
    most_active = usage_graph(healthcode_map)
    
    journey_map(healthcode_map, most_active)
