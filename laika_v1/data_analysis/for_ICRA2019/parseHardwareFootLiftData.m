function [footHWdata, hwTimes, hwLiftAngles] = parseHardwareFootLiftData(logfile_hardware_base)
%parseHardwareFootLiftData
%   Parses and plots the data from all 4 foot-lifting tests of Laika in
%   hardware, for ICRA 2019
%   Andrew P. Sabelhaus
%   Berkeley Emergent Space Tensegrities Lab
%   Sept. 8, 2018
%

% Read in the hardware data. Each foot ending string will be (A,B.C,D)
footHWstring{1} = ' Front Right Blue.txt';
footHWstring{2} = ' Front Left Orange.txt';
footHWstring{3} = ' Back Right Purple.txt';
footHWstring{4} = ' Back Left Red.txt';

% Programattically create file paths and read in each set of five tests
% Feet 1-4 are A-D in that order
footHWdata = {};
for i=1:4
    % for this leg
    for j=1:5
        % for this test
        % Concatenate string
        currentHWpath = strcat(logfile_hardware_base, 'Test', num2str(j), ...
            footHWstring{i});
        % Read in csv
        footHWdata{i}{j} = csvread(currentHWpath);
    end
end

% Great. Now, let's make a big 2D array of the timepoints at which the legs
% lift.
% File is in same folder as data, and has name
hwTimesCSV = strcat(logfile_hardware_base, 'foot lifting times from hw videos.csv');
% Data starts at 4th? row (index from 0 makes it 3?), columns 3-5 (2-4)
hwTimes = csvread(hwTimesCSV, 3, 2);

% Let's pull out the seconds-from-start and convert to ms for use with
% Kim's data from the serial terminal. 5 tests each for 4 legs 
hwTimes = reshape(hwTimes(:,3), 5, 4) .* 1000;
% Transpose it so we have rows = feet, col = test
hwTimes = hwTimes';

% For each test, find the corresponding lift in radians.
hwLiftAngles = zeros(size(hwTimes));

for i=1:4
    % for this foot
    for j=1:5
        % for this test
        % The index of the first row that's at the time we desire will be
        % (recall, footHWdata{foot}{test}, hwTimes(foot, test)
        timeIndex = find( footHWdata{i}{j}(:,1) > hwTimes(i,j), 1)
        % The time data from the arduino has gaps along when the foot
        % settles.
        % So, it's most appropriate to take the "just before" time, since
        % for example 8.5 sec (video) -> 8.01 sec (serial data), as 8.01
        % sec would be when the radians command was issued, and the extra
        % 0.49 sec is for the robot settling at its new position, which
        % would only be reflected in the video AFTER setting.
        % HOWEVER, for certain tests, this wraps over. So, just set to max.
        if( size(timeIndex) == [0 1] )
            % number of rows.
            timeIndex = size(footHWdata{i}{j}, 1); 
        end
        timeIndex = timeIndex - 1;
        % Then, the lift angle will be at this index, on the second row, in
        % rad.
        hwLiftAngles(i,j) = footHWdata{i}{j}(timeIndex, 2);
    end
end

% note, these are in terms of output shaft rotations for the motor.
% need to convert via the gear ratio of the center gear.

% As submitted originally, we had these calculations wrong. We
% single-counted the motor's encoder ticks, but double-counted in this
% script, as in:
%hwLiftAngles = hwLiftAngles .* 0.5;
% However, that's incorrect. Instead, we actually needed to use the proper
% gear ratio for the center vertebra. Originally, we had:
% 0.625 inch / 1.5 inch, or
%gearratio = 0.625 / 1.5; % 0.4167
% ...but it really is 1/4, or
gearratio = 0.25;

% and adjust all the hw lift angles
hwLiftAngles = hwLiftAngles .* gearratio;

end


