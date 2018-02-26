% An example of running the function to create motor tracking example data.
% This will concatenate data to the same file - be sure to delete the .csv
% before running this script again.

clear all;
close all;
clc;

sampling_time = 0.01;
total_time = 20.0;

% For the sinusoid example:
%filename = 'motor_data_example_dt01_tt_50';
%example_data = motor_data_example(sampling_time, total_time, filename);

% For the ramp:
%max = 0.5; % radians
%filename = 'motor_data_ramp_dt01_tt_10_max_05';
%example_data = motor_data_ramp(sampling_time, total_time, max, filename);

% Laika IROS 2018: For lifting feet B and C (front left, back right)
max = pi/8; % radians
filename = 'motor_data_ramp_dt01_tt_20_max_pi8';
%example_data = motor_data_ramp(sampling_time, total_time, max, filename);

% Laika IROS 2018: For lifting feet A and D (front right, back left)
max = -pi/32; % radians
filename = 'motor_data_ramp_dt01_tt_20_max_neg_pi32';
%example_data = motor_data_ramp(sampling_time, total_time, max, filename);

% Laika IROS 2018, SI units model: trajectory up to pi/4.
% Keep the same speed though (go up to 40 sec of motion.)
total_time = 40.0;
max = pi/4; % radians
filename = 'motor_data_ramp_dt01_tt_40_max_pi4';
%example_data = motor_data_ramp(sampling_time, total_time, max, filename);

% Laika IROS 2018, SI units model: trajectory up to pi/4.
% Keep the same speed though (go up to 40 sec of motion.)
total_time = 40.0;
max = -pi/4; % radians
filename = 'motor_data_ramp_dt01_tt_40_max_neg_pi4';
example_data = motor_data_ramp(sampling_time, total_time, max, filename);