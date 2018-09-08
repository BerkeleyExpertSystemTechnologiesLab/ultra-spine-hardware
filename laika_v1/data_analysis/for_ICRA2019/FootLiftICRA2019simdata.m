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

% We're going for four files x 5 tests.
% Specify the names and timestamps, as a little struct.

% For the set of 20 tests for ICRA 2019:
% The indexing here will order the groups of tests as 1 to 5 (from tests
% 1-4 up to group 17-20.)

% Tests 1-4 (min tension):
t1_4 = {'09072018_121117_1', '09072018_121254_2', '09072018_121443_3', ...
    '09072018_121617_4'};

% keep each group separate so we don't need to do complicated indexing
% later when we do 5 subplots.
NTRTteststimestamp{1} = t1_4;

% Tests 5-8:
t5_8 = {'09072018_165939_5', '09072018_170104_6', ...
    '09072018_170247_7', '09072018_170436_8'};

NTRTteststimestamp{2} = t5_8;

% Tests 9-12:
t9_12 = {'09072018_170907_9', '09072018_171106_10', ...
    '09072018_171249_11', '09072018_171507_12'};

NTRTteststimestamp{3} = t9_12;

% Tests 13-16:
t13_16 = {'09072018_171842_13', '09072018_172035_14', ...
    '09072018_172233_15', '09072018_172421_16'};

NTRTteststimestamp{4} = t13_16;

% Tests 17-20 (max tension):
t17_20 = {'09072018_155508_17', '09072018_155654_18', ...
    '09072018_160032_19', '09072018_160252_20'};

NTRTteststimestamp{5} = t17_20;

% Next, build up the full file paths to each set of tests.
filepaths = {};
for i=1:5
    % for each of the 4 feet for this test:
    % A
    filepaths{i}{1} = strcat(logfile_base, 'A_0.8_', ...
        NTRTteststimestamp{i}{1}, '.txt');
    % B
    filepaths{i}{2} = strcat(logfile_base, 'B_0.8_', ...
        NTRTteststimestamp{i}{2}, '.txt');
    % C
    filepaths{i}{3} = strcat(logfile_base, 'C_0.8_', ...
        NTRTteststimestamp{i}{3}, '.txt');
    % D
    filepaths{i}{4} = strcat(logfile_base, 'D_0.8_', ...
        NTRTteststimestamp{i}{4}, '.txt');
end

% We can now build up the paths to each file
% filepaths.A = strcat(logfile_base, 'A_0.8_', tA, '.txt');
% filepaths.B = strcat(logfile_base, 'B_0.8_', tB, '.txt');
% filepaths.C = strcat(logfile_base, 'C_0.8_', tC, '.txt');
% filepaths.D = strcat(logfile_base, 'D_0.8_', tD, '.txt');

% Also, since we'll need it later, put together a list of the last timestep
% to plot for each simulation (in terms of row on the CSV spreadsheet from
% NTRT.)

% finalTimeIndices = [ 2220; %1, A  
%                     3634; %2, B
%                     2980; %3, C
%                     2980; %4, D
%                     2129; %5, A
%                     3445; %6, B
%                     3453; %7, C
%                     2492; %8, D
%                     2428; %9, A
%                     3915; %10, B
%                     3966; %11, C
%                     2643; %12, D
%                     2643; %13, A
%                     4299; %14, B
%                     4232; %15, C
%                     2794; %16, D
%                     2787; %17, A
%                     4530; %18, B
%                     4370; %19, C
%                     2910]; %20, D
                
finalTimeIndices = [ 2220, 3634, 2980, 2980; %1-4, A-D
                    2129, 3445, 3453, 2492; %5-8
                    2428, 3915, 3966, 2643; %9-12
                    2643, 4299, 4232, 2794; %13-16
                    2787, 4530, 4370, 2910]; %17-20

% A flag to control making plots or not
% ...we are going to make plots later, so keep off.
make_plots = 0;

% Call the parser function on each set of data.
% the results will be stored as:
markerdata = {};

% we've got 5 sets of tests.
for i = 1:5
    % call the parser
    markerdata{i} = parseNTRTFootMarkerDataOnly(filepaths{i});
end

% Since there is only one set of hardware data, we only need to parse it
% once:
[footHWdata, hwTimes, hwLiftAngles] = parseHardwareFootLiftData(logfile_hardware_base);


        
%[markerdata, footHWdata, hwTimes, hwLiftAngles] = parseNTRTFootMarkerDataMany(filepaths, logfile_hardware_base, finalTimeIndices, make_plots);
















