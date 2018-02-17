% An example of running the function to create motor tracking example data.
% This will concatenate data to the same file - be sure to delete the .csv
% before running this script again.

clear all;
close all;
clc;

sampling_time = 0.01;
total_time = 10.0;

% For the sinusoid example:
%filename = 'motor_data_example_dt01_tt_50';
%example_data = motor_data_example(sampling_time, total_time, filename);

% For the ramp:
max = 0.5; % radians
filename = 'motor_data_ramp_dt01_tt_10_max_05';
example_data = motor_data_ramp(sampling_time, total_time, max, filename);