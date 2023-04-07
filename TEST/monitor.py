#!/usr/bin/env python3
''' Performance monitor tool

    Parameters:
    - CPU (cores, usage, frequency, temperature)
    - Swap (space, usage)
    - RAM (space, usage)
    - Disk (space, usage)

    Print:
    - CPU cores
    - RAM space
    - Swap space
    - Disk space

    Bar graph:
    - CPU usage
    - RAM usage
    - RAM frequency [TODO]
    - RAM temperature [TODO]
    - Disk Usage

    Time graph:
    - CPU usage
    - RAM usage

'''

import os
import psutil
import time
import sys
import pathlib
import argparse
import logging

import numpy as np
from matplotlib import pyplot as plt
from matplotlib.patches import Patch




#! CPU
class CPU():

    def __init__(self):
        self.cpu_cores_ = psutil.cpu_count()
        self.cpu_array = np.array([])

    def cpu_usage(self):
        self.cpu_usage_ = psutil.cpu_percent(interval=None)
        self.cpu_array = np.append(self.cpu_array, self.cpu_usage_)
        # print(' - CPU usage:        {}%'.format(self.cpu_usage_))

    #TODO
    def cpu_freq(self):
        self.cpu_freq_ = int(psutil.cpu_freq().current)

    #TODO
    def cpu_temp(self):
        self.cpu_temp_ = 0.0
        if os.path.isfile('/sys/class/thermal/thermal_zone0/temp'):
            with open('/sys/class/thermal/thermal_zone0/temp') as f:
                line = f.readline().strip()
            # test if the string is an integer as expected.
            if line.isdigit():
                self.cpu_temp_ = float(line) / 1000         # convert the string with the CPU temperature to a float in degrees Celsius.
        return self.cpu_temp_



#! RAM
class RAM():

    def __init__(self):
        self.ram_space_ = int(psutil.virtual_memory().total)
        self.swap_space_ = int(psutil.swap_memory().total)       
        self.ram_array = np.array([])

    def ram_usage(self):
        self.ram_usage_ = psutil.virtual_memory().percent
        self.ram_array = np.append(self.ram_array, self.ram_usage_)
        # print(' - RAM usage:        {}%'.format(self.ram_usage_))

    #TODO
    def swap_usage(self):
        self.swap_usage_ = int(psutil.swap_memory().percent)


#! Disk
class Disk():

    def __init__(self):
        self.disk_space_ = psutil.disk_usage('/').total
        self.disk_array = np.array([])

    def disk_usage(self):
        self.disk_usage_ = psutil.disk_usage('/').percent
        self.disk_array = np.append(self.disk_array, self.disk_usage_)
        # print(' - Disk usage:        {}%'.format(self.disk_usage_))



#! Wrap class
class Performance(CPU, RAM, Disk):

    def __init__(self):
        self.labels = [CPU.__name__, RAM.__name__, Disk.__name__]

        print('{}: {}'.format(type(self).__name__, self.labels))

        # initialize parent classes
        CPU.__init__(self)
        RAM.__init__(self)
        Disk.__init__(self)

        # initialize bar graph
        self.bar_num = len(self.labels)
        self.bar_position = np.array(list(range(len(self.labels))))
        self.bar_width = 0.5

        self.bar_fig, self.bar_axes = plt.subplots()
        
        plt.ion()
        plt.show()


    def print_sys_info(self):
        print('System info: \n - CPU cores: {} \n - RAM space: {:.1f} GB \n - Swap space: {:.1f} GB \n - Disk space: {:.1f} GB'.format(
            self.cpu_cores_, self.ram_space_ / (1024**3), self.swap_space_ / (1024**3), self.disk_space_ / (1024**3)
        ))


    def get_performance(self):
        self.cpu_usage()
        self.ram_usage()
        self.disk_usage()
        self.bar_performance = [self.cpu_usage_, self.ram_usage_, self.disk_usage_]
        self.line_performance = [self.cpu_array, self.ram_array]


    def performance_time_graph(self, time_span):
        self.time_fig, self.time_exes = plt.subplots(nrows=1, ncols=1, sharex=False, sharey=False, figsize=(12,6))

        # plot
        self.line_color = ['red', 'blue']
        self.time_exes.plot(time_span, self.line_performance[0], color=self.line_color[0], label='CPU', linestyle='-', linewidth=1, marker='o', markersize=6)
        self.time_exes.plot(time_span, self.line_performance[1], color=self.line_color[1], label='RAM', linestyle='-', linewidth=1, marker='o', markersize=6)
        
        # title and layout
        self.time_exes.set_title('Performance', fontsize=20)
        self.time_exes.grid(True, color="k", linestyle="--", alpha=0.2)

        # axes properties
        self.time_exes.set_ylim(0, 100+10)
        
        self.time_exes.set_yticks([25, 50, 75, 100])
        self.time_exes.set_xticks(time_span)

        self.time_exes.set_ylabel('Percentage [%]', fontsize=12)
        self.time_exes.set_xlabel('Time [s]', fontsize=12)

        # legend
        self.time_exes.legend(loc='best')
        # plt.legend()

        # show plot
        plt.show(block=True)



    def performance_bar_graph(self):

        # clear plot
        self.bar_axes.clear()

        # plot
        self.bar_color = ['red', 'blue', 'green']
        self.bar_plot = self.bar_axes.bar(self.bar_position, self.bar_performance, self.bar_width, align='center', color=self.bar_color)

        # title and layout
        self.bar_axes.set_title('Performance', fontsize=20)
        self.bar_axes.grid(axis='y', which="both", color="k", linestyle="--", alpha=0.2)

        # axes properties
        # self.bar_axes.set_xlim(-1, self.bar_num)
        self.bar_axes.set_ylim(0, 100 + 10)
        self.bar_axes.set_ylabel('Percentage [%]', fontsize=12)
        plt.xticks(self.bar_position, self.labels)
        # self.bar_axes.set_xticks(self.bar_position, labels=self.labels)
        self.bar_axes.set_yticks([25, 50, 75, 100])

        # legend        
        self.color_map = dict(zip(self.bar_performance, self.bar_color))
        self.patches = [Patch(color=v, label=k) for k, v in self.color_map.items()]
        self.bar_axes.legend(labels=self.labels, handles=self.patches, loc='best')

        # annotation
        for x, y in zip(self.bar_position, self.bar_performance):
            plt.annotate('{}%'.format(y), xy=(x, y), textcoords="offset points", xytext=(0, 5), ha='center', va='center')

        # show
        plt.draw()
        plt.pause(0.001)



if __name__ == '__main__':

    arg = argparse.ArgumentParser()
    arg.add_argument('-enable_runtime_bargraph', '-b', type=bool, default=False)

    performance = Performance()

    performance.print_sys_info()


    # TODO



    
    try:
        end_time = 10
        update_period = 1
        time_span = range(0, round(end_time/update_period))

        # while True:
        for i in time_span:

            tic = time.perf_counter()

            performance.get_performance()
            performance.performance_bar_graph()

            toc = time.perf_counter()
            time_elapsed = toc - tic

            print(f"Time window {time_elapsed:0.2f} seconds")

            time.sleep(update_period-time_elapsed)



        plt.close()

        #! time graph
        performance.performance_time_graph(time_span)


    except KeyboardInterrupt:
        print('\nStutdown!')
    