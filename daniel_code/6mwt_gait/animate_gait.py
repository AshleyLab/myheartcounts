# -*- coding: utf-8 -*-
"""
Created on Sat Jan 12 20:02:40 2019

Animate_Gait
Defines a function for the visualization of a gait's movement in 3D

animate_data(data)

In Spyder, make sure to change graphics to automatic so the animation is
in a new window rather than a blank inline figure
@author: Daniel Wu
"""

from matplotlib import pyplot as plt
import numpy as np
import mpl_toolkits.mplot3d.axes3d as p3
from matplotlib import animation

def gen(n):
    '''
    Generator of a spiral with n datapoints
    Data shape (n, 3)
    '''
    phi = 0
    while phi < 2*np.pi:
        yield np.array([np.cos(phi), np.sin(phi), phi])
        phi += 2*np.pi/n

def update(num, data, line):
    '''
    Helper function which updates a line to a certain num time point in the data
    '''
    line.set_data(data[:2, :num])
    line.set_3d_properties(data[2, :num])

def animate_data(data):
    '''
    Function which returns an animation of the acceleration data in 3d
    Data should be of shape (3, timesteps), where the first dim is {x, y, z}
    Plays the animation over 10 seconds.
    '''
    
    #Data of shape (3, timesteps)
    assert data.shape[0] == 3
    N = len(data[0])
    fig = plt.figure()
    ax = p3.Axes3D(fig)
    line, = ax.plot(data[0, 0:1], data[1, 0:1], data[2, 0:1])
    
    # Setting the axes properties
    ax.set_xlim3d([min(data[0]), max(data[0])])
    ax.set_xlabel('X')
    
    ax.set_ylim3d([min(data[1]), max(data[1])])
    ax.set_ylabel('Y')
    
    ax.set_zlim3d([min(data[2]), max(data[2])])
    ax.set_zlabel('Z')
    
    ani = animation.FuncAnimation(fig, update, N, fargs=(data, line), interval=10000//N, blit=False)
    plt.show()

    return ani
    #ani.save('matplot003.gif', writer='imagemagick')

#Demonstrate the animation function
if __name__ == "__main__":
    data = np.array(list(gen(100))).T
    ani = animate_data(data)
