import sys, os, errno
import numpy as np
import itertools as it
import pandas as pd

directory_in_str = '/scratch/users/danjwu/6mwt_subset/accel_walk_dir'
directory = os.fsencode(directory_in_str)

final_directory_in_str = '/scratch/users/danjwu/results'
final_directory = os.fsencode(final_directory_in_str)

# Set overlap to the amount you want the sliding windows to have in common 
# Example: If your sliding windows are of length 200 ms (2 seconds), make the overlap 99 for half of the window to overlap 
def moving_window(accelx, length, overlap, step=1):
    streams = it.tee(accelx, length)
    return zip(*[it.islice(stream, i, None, step + overlap) for stream, i in zip(streams, it.count(step=step))])

def normalize_dataset(dataframe):
    return (dataframe - dataframe.mean())

def create_dataframes(num_of_ms, overlap):
    for subdir, dirs, files in os.walk(directory):
        # this is so that there is only one file per healthCode
        i = 0
        for file in files:
            while (i < 1):
                # You can choose to get the non mean normalized version by not calling the normalize_dataset function
                a_df = normalize_dataset(pd.read_json(os.path.join(subdir.decode(), file.decode())).set_index('timestamp'))
                x = np.asarray(a_df.x)
                y = np.asarray(a_df.y)
                z = np.asarray(a_df.z)
                x_ = list(moving_window(x, num_of_ms, overlap))
                y_ = list(moving_window(y, num_of_ms, overlap))
                z_ = list(moving_window(z, num_of_ms, overlap))
                df = pd.DataFrame({'healthCode': subdir.decode()[subdir.decode().rfind('/')+1:], 
                'xwindows': x_, 'ywindows': y_, 'zwindows': z_}, columns=['healthCode', 'xwindows', 
                'ywindows', 'zwindows']).set_index('healthCode')

                
                if not os.path.exists(final_directory.decode() + '/' + subdir.decode()[subdir.decode().rfind('/')+1:] + '/' + str(num_of_ms) + '/' + str(overlap)):
                    os.makedirs(final_directory.decode() + '/' + subdir.decode()[subdir.decode().rfind('/')+1:] + '/' + str(num_of_ms) + '/' + str(overlap))
                df.to_hdf(final_directory.decode() + '/' + subdir.decode()[subdir.decode().rfind('/')+1:] + '/' + str(num_of_ms) + '/' + str(overlap) + '/' + subdir.decode()[subdir.decode().rfind('/')+1:] + str(num_of_ms) + str(overlap) +'.h5', key='df', mode='w')
                i += 1

create_dataframes(200, 99)

