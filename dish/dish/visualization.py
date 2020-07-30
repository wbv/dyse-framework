import os
import re
from collections import defaultdict
import numpy as np
import seaborn as sns
import matplotlib.pyplot as plt


def get_traces(input_file, default_levels=3):
    """Load simulation values from a trace file

    Trace file should contain (optionally) individual runs, followed by the
    frequency summaries, followed by the squares summaries for each element
    (output_format 1 or 3 from the simulator)

    """

    # dictionary to store traces for each element
    trace_data = defaultdict(lambda: defaultdict())

    # read traces from trace file
    with open(input_file) as in_file:
        trace_file_lines = in_file.readlines()
    trace_file_lines = [x.strip() for x in trace_file_lines]

    run = 0
    frequency_summary = False
    squares_summary = False
    for trace_line_content in trace_file_lines:

        # check each line for the Run #, Frequency/Squares summaries, or values
        if re.match(r'Run #[0-9]+', trace_line_content):
            # save the last run # as the total number of runs
            run = re.findall(r'Run #([0-9]+)', trace_line_content)[0]

        elif re.match('Frequency Summary:', trace_line_content):
            # set frequency summary flag
            frequency_summary = True

        elif re.match('Squares Summary:', trace_line_content):
            # set squares summary flag
            squares_summary = True
        
        else:
            # get trace values and element name
            trace_values_str = trace_line_content.split(' ')
            element_name = trace_values_str[0].split('|')[0] 

            if element_name != '':
                # get num states for this element if available
                if len(trace_values_str[0].split('|')) > 1:
                    levels = int(trace_values_str[0].split('|')[1])
                else:
                    levels = default_levels
                
                # get simulation values
                trace_values = [float(val) for val in trace_values_str[1:]]
                                
                # store trace data
                trace_data[element_name]['levels'] = levels
                # will save the number read from the last occurrence of "Run#" in the file
                # adding 1 to correct for zero indexed run number
                trace_data[element_name]['runs'] = int(run) + 1
                if squares_summary:
                    trace_data[element_name]['squares'] = trace_values
                    # calculate avg and stdev values
                    runs = trace_data[element_name]['runs']
                    levels = trace_data[element_name]['levels']
                    freq_vals = trace_data[element_name]['frequency']
                    avg_vals = [float(val)/runs for val in freq_vals]
                    stdev_vals = [np.sqrt(float(val)/runs - avg_vals[idx]**2) for idx, val in enumerate(trace_values)]
                    
                    trace_data[element_name]['avg'] = avg_vals
                    trace_data[element_name]['stdev'] = stdev_vals
                    trace_data[element_name]['avg_percent'] = [100*val/(levels-1) for val in avg_vals]
                    trace_data[element_name]['stdev_percent'] = [100*val/(levels-1) for val in stdev_vals]

                elif frequency_summary:
                    trace_data[element_name]['frequency'] = trace_values
                else:
                    if 'traces' in trace_data[element_name]:
                        trace_data[element_name]['traces'].update({run : trace_values})
                    else:
                        trace_data[element_name]['traces'] = {run : trace_values}

    return trace_data


def plot_average(
        trace_data_list: list(), 
        elements_list=[''], 
        normalize_levels=True,
        scenario_labels=[''],
        errorbars=False,
        timesteps_list=[], 
        timesteps_labels=[[],['']],
        y_limits=['default'],
        x_label='Step',
        y_label='Level',
        style='whitegrid',
        linewidth=1,
        colors=None,
        linestyles=None,
        fig_size=(5,3)):
    """Plot average traces

    If trace_data_list has more than one item, plots each as a separate scenario
    """

    if not isinstance(trace_data_list, list):
        raise ValueError('Input trace_data_list must be a list')

    if scenario_labels == ['']:
        scenario_labels = [f'Scenario {idx}' for idx, _ in enumerate(trace_data_list)]

    # check length of inputs
    if len(trace_data_list) != len(scenario_labels):
        raise ValueError('Length of scenario_labels must equal length of trace_data_list')

    if colors is not None and len(trace_data_list) != len(colors):
        raise ValueError('Length of colors must equal length of trace_data_list')
    
    if linestyles is not None and len(trace_data_list) != len(linestyles):
        raise ValueError('Length of linestyles must equal length of trace_data_list')
    
    # will get traces from each element across scenarios
    avg_plots = defaultdict()

    if elements_list == ['']:
        # assuming same elements in each scenario
        elements_list = trace_data_list[0].keys()
    
    for element in elements_list:
        plot_data = []
        all_element_data = [trace_data[element] for trace_data in trace_data_list]
        
        for scenario_index, scenario_data in enumerate(all_element_data):

            levels = int(scenario_data['levels'])

            if normalize_levels:
                # stdev as percentage
                stdev_vals = scenario_data['stdev_percent']
                # average level as percentage
                avg_vals = scenario_data['avg_percent']
            else:
                stdev_vals = scenario_data['stdev']
                avg_vals = scenario_data['avg']
  
            # get only the specified time steps
            timesteps = list(range(len(avg_vals)))
            if timesteps_list != []:
                timesteps = [timesteps[int(step)] for step in timesteps_list]
                avg_vals = [avg_vals[int(step)] for step in timesteps_list]
                stdev_vals = [stdev_vals[int(step)] for step in timesteps_list]

            # save data and plotting information
            plot_data += [dict(
                    x=timesteps,
                    y=avg_vals,
                    label=scenario_labels[scenario_index],
                    error=stdev_vals,
                    levels=levels,
                    linewidth=linewidth,
                    color=colors[scenario_index] if colors is not None else None,
                    linestyle=linestyles[scenario_index] if linestyles is not None else None)]    
        
        # generate plots
        sns.set_style(style)
        fig, ax = plt.subplots(figsize=fig_size)

        # plot each trace
        [single_plot(d, errorbars) for d in plot_data]

        # using x range of [0, steps-1] to plot initial value at 0
        ax.set_xlim([0, len(plot_data[0]['x'])-1])
        
        set_y_limits(ax, y_limits, levels, normalize_levels)
        
        # set xticks and labels if provided
        if timesteps_list != []:
            plt.xticks(timesteps_list)
            ax.set_xlim([timesteps_list[0], timesteps_list[-1]])
        if timesteps_labels != [[], ['']]:
            plt.xticks(timesteps_labels[0], timesteps_labels[1], rotation='vertical')
        
        plt.xlabel(x_label)
        plt.ylabel(y_label)
        plt.title(element)

        # add legend if more than 1 scenario
        if len(trace_data_list) > 1:
            handles, labels = ax.get_legend_handles_labels()
            plt.legend(handles, labels, frameon=False) 
        
        plt.tight_layout()
        fig.tight_layout()

        avg_plots[element] = fig

        plt.close()

    return avg_plots
 

def single_plot(d, errorbars=False):

    plt.plot(d['x'], d['y'],
            label=d['label'],
            linewidth=d['linewidth'],
            color=d['color'],
            linestyle=d['linestyle'])

    if errorbars:
        var_low = np.array(d['y']) - np.array(d['error'])
        var_high = np.array(d['y']) + np.array(d['error'])
        plt.fill_between(d['x'], var_low, var_high, alpha=0.5)


def set_y_limits(ax, y_limits, levels, normalize_levels=True, comparison=None):

    if normalize_levels:
        y_max = 100
    else:
        y_max = levels - 1

    if y_limits[0] == 'default':
        # assuming all data from the same element has the same levels
        # making the y range 2% wider than levels to make sure that
        # plot lines are visible at the min and max level
        if comparison == 'difference':
            ax.set_ylim([-1.01*y_max, 1.01*y_max])
        elif comparison is None:
            ax.set_ylim([-0.01*y_max, 1.01*y_max])
    elif y_limits[0] == 'auto':
        pass
    elif len(y_limits) != 2:
        raise ValueError('Invalid y_limits input, must be [<min>, <max>]')
    else:
        # use input y_limits
        ax.set_ylim([y_limits[0], y_limits[1]])


def save_plots(element_plots, output_filepath, file_format='png'):
    """Save plots to file(s)"""
    
    for element, element_fig in element_plots.items():
        element_fig.savefig(os.path.join(output_filepath,f'{element}.{file_format}'), format = file_format)