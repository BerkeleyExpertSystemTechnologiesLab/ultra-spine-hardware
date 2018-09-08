% FootLift2018simdata.m
% A helper script file that takes in data from 
% the NASA Tensegrity Robotics Toolkit simulations of Laika and its
% foot vs. vertebra rotation positions.
%   Andrew P. Sabelhaus
%   Berkeley Emergent Space Tensegrities Lab
% August 2018: expect this script to be used for ICRA 2019 too.

% Clean up the workspace
clear all;
close all;
clc;

% Add the path to the hline and vline functions.
% @TODO make this more robust!
addpath('./hline_vline');

% The log file base path:
% we assume we're using the data in this repository
%logfile_base = './NTRTdata/footlifting_90percent_horiz/SI/LaikaIROS2018MarkerData';
%logfile_base = './NTRTdata/footlifting_80percent_horiz/SI/ICRA2019/LaikaIROS2018MarkerData';
% For ICRA 2019, we use new labels:
logfile_base = './NTRTdata/footlifting_80percent_horiz/SI/ICRA2019/LaikaICRA2019MarkerData';
logfile_hardware_base = './HardwareExperimentData/';

% We're going for four files, one from each foot lifting test. 
% Specify the names and timestamps, as a little struct.

% A, FR, etc.
% These for the centimeters model:
%tA = '02242018_123943';
%tB = '02242018_124041';
%tC = '02242018_124133';
%tD = '02242018_124628';
% For the SI units model:
%tA = '08232018_154644';
%tB = '09062018_153626_max';
%tC = '08232018_164351';
%tD = '08232018_160212';

% for the ICRA 2019 tests:
% Minimum (216), with the bottom at 810:
% tA = '09072018_101630_min_810';
% tB = '09072018_101903_min_810';
% tC = '09072018_101725_min_810';
% tD = '09072018_102033_min_810';
% Minimum (216), with the bottom at 941:
% tA = '09072018_095733_min_941';
% tB = '09072018_100048_min_941';
% tC = '09072018_095849_min_941';
% tD = '09072018_100213_min_941';
% Maximum (258), with bottom at 941:
% tA = '09072018_110001_max_941';
% tB = '09072018_110256_max_941';
% tC = '09072018_110101_max_941';
% tD = '09072018_110434_max_941';

% For the set of 20 tests for ICRA 2019:
% Tests 1-4 (min tension):
% tA = '09072018_121117_1';
% tB = '09072018_121254_2';
% tC = '09072018_121443_3';
% tD = '09072018_121617_4';

% Tests 17-20 (max tension):
tA = '09072018_155508_17';
tB = '09072018_155654_18';
tC = '09072018_160032_19';
tD = '09072018_160252_20';

% We can now build up the paths to each file
filepaths.A = strcat(logfile_base, 'A_0.8_', tA, '.txt');
filepaths.B = strcat(logfile_base, 'B_0.8_', tB, '.txt');
filepaths.C = strcat(logfile_base, 'C_0.8_', tC, '.txt');
filepaths.D = strcat(logfile_base, 'D_0.8_', tD, '.txt');

% A flag to control making plots or not
make_plots = 1;

% Call the parser function
[markerdata, footHWdata, hwTimes, hwLiftAngles] = parseNTRTFootMarkerData(filepaths, logfile_hardware_base, make_plots);



