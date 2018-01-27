function timeseries = motor_data_example(sampling_time, total_time, filename)
%motor_data_example
%   This code generates an example of time series data that may
%   come from NTRT for motor input tracking. It outputs a time series
%   of sinusoidal data. This is an example of what come from NTRT
%   simulations, and would be tracked by a discrete-time PID control for
%   one motor.
%
%   Arguments:
%       sampling_time = timestep for the tracking. This correlates to what
%           timestep we choose for NTRT, and is also then the dt for the
%           discrete time controller. Will be the first column of output.
%       total_time = end time for the data. Rounded down to the nearest
%           interval of sampling_time.
%       filename = name of the .CSV file that will be output of the
%           example data. Should not contain the .csv extension. File is
%           placed in the current folder.

% Generate the timesteps, save as the first column of example data.
timeseries = [0:sampling_time:total_time]';
% Parameters for the sinusoid. Make it slowly varying, with an offset.
period = 1.5;
freq = 2*pi / period;
amplitude = .8; % in radians
offset = 0.9;
phase = 0;
% Output of the sinusoid:
sin_out = amplitude .* sin(freq.*timeseries + phase) + offset;
timeseries(:,2) = sin_out;

% Output the CSV file. This will be what's provided by NTRT.
% Creat the full filename:
filename = strcat(filename, '.csv');
% Write the csv file.
disp(strcat('Writing csv file: ', filename));
csvwrite(filename, timeseries);

end

