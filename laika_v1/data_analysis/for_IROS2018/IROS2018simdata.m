% IROS2018simdata.m
% A helper script file that takes in data from 
% the NASA Tensegrity Robotics Toolkit simulations of Laika and its
% foot vs. vertebra rotation positions.
%   Andrew P. Sabelhaus
%   Berkeley Emergent Space Tensegrities Lab

% Clean up the workspace
clear all;
close all;
clc;

% Add the path to the hline and vline functions.
% @TODO make this more robust!
addpath('./hline_vline');

% The log file base path:
% we assume we're using the data in this repository
logfile_base = './NTRTdata/footlifting_90percent_horiz/LaikaIROS2018MarkerData';

% We're going for four files, one from each foot lifting test. 
% Specify the names and timestamps, as a little struct.

% A, FR, etc.
tA = '02242018_123943';
tB = '02242018_124041';
tC = '02242018_124133';
tD = '02242018_124628';

% We can now build up the paths to each file
filepaths.A = strcat(logfile_base, 'A_0.9_', tA, '.txt');
filepaths.B = strcat(logfile_base, 'B_0.9_', tB, '.txt');
filepaths.C = strcat(logfile_base, 'C_0.9_', tC, '.txt');
filepaths.D = strcat(logfile_base, 'D_0.9_', tD, '.txt');

% A flag to control making plots or not
make_plots = 1;

% Call the parser function
markerdata = parseNTRTFootMarkerData(filepaths, make_plots);
