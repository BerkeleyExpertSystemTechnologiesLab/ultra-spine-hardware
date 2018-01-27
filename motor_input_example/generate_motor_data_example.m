% An example of running the function to create motor tracking example data.
% This will concatenate data to the same file - be sure to delete the .csv
% before running this script again.
sampling_time = 0.01;
total_time = 5.0;
filename = 'motor_data_example_dt01_tt_50';
example_data = motor_data_example(sampling_time, total_time, filename);