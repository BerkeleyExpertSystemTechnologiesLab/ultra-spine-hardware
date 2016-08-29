function [ f0, f1, wholefile ] = parse_UC_Davis_data( path, makeGraphs )
%parse_UC_Davis_data
%   Parses the CSV files saved by the force plate testing setup
%   at the UC Davis Canine Gait Lab.
%   Copyright (C) 2016 UC Berkeley, Berkeley Emergent Space Tensegrities Lab,
%   and Andrew P. Sabelhaus.
%   @param[in] path - a string, the name of the file to read in.
%   @param[in] makeGraphs - a boolean, controls whether or not graphs are displayed.
%   @param[out] f0 - a matrix with the normal and shear forces for the "F" plate,
%       the first of the two. In column order, forces in X, Y, Z.
%   @param[out] f1 - a matrix with the normal and shear forces for the "F1" plate,
%       the second of the two. In column order, forces in X, Y, Z.
%   @param[out] wholefile - the whole matrix of data, including the moments
%       and the center of mass. This is just for backup really.

% Set the default value for the 'makeGraphs' boolean.
% Defaults to 1.
if (nargin < 2)
    makeGraphs = 1;
end

% First, determine the number of lines in the file.
% These csv files have a varying number of rows, depending on how long
% data was collected. 
% The following code adapted from Stackexchange, all credit goes to
% http://stackoverflow.com/questions/12176519/is-there-a-way-in-matlab-to-determine-the-number-of-lines-in-a-file-without-loop

fileID = fopen(path, 'r');
% First, determine size of the file:
fseek(fileID, 0, 'eof');
fileSize = ftell(fileID);
% Reset the file position indicator:
frewind(fileID);
% Then, read in the whole file, according to the file size:
fileData = fread(fileID, fileSize, 'uint8');
% Count number of new lines, and correct for the number of newlines that
% the UC Davis software appends to the end of the file.
numLines = sum(fileData == 10) - 2;
fclose(fileID);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% NOTE! FOR ALL THE INDICES BELOW:
% csvread starts indexing from 0 instead of 1.
% So, the 20th column will be at '19' instead, for example.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% The data in these files starts at row 6:
rowStart = 5;
% ..and ends at 6 rows before the end of the file:
rowOffsetEnd = 6;
% So then, the final row to read will be:
rowEnd = numLines - rowOffsetEnd;

% There are 20 columns in the file:
numCol = 19;
% and the f0 data is in columns 3 to 5:
f0start = 2;
f0end = 4;
% and the f1 data is in columns 12 to 14:
f1start = 11;
f1end = 13;

%DEBUGGING:
%numLines

f0 = csvread( path, rowStart, f0start, [rowStart, f0start, rowEnd, f0end] );
f1 = csvread( path, rowStart, f1start, [rowStart, f1start, rowEnd, f1end] );

% Just in case,
wholefile = csvread( path, rowStart, 0, [rowStart, 0, rowEnd, numCol] );

% Make graphs of the data, if desired.
if( makeGraphs )
    close all;
    % Plot the X data
    xFigHandle = figure;
    hold on;
    plot(f0(:,1), '.r');
    plot(f1(:,1), '.b');
    % Create the title, which should include the name of the file passed in:
    titleX = sprintf( strcat('UC Davis Testing Data, Forces in X Direction, for file:\n', path) );
    title(titleX);
    xlabel('Timestep');
    ylabel('Force (N?)');
    legend('Force Plate 0 (red)', 'Force Plate 1 (blue)');
    % Plot the y data
    yFigHandle = figure;
    hold on;
    plot(f0(:,2), '.r');
    plot(f1(:,2), '.b');
    % Create the title, which should include the name of the file passed in:
    titleY = sprintf( strcat('UC Davis Testing Data, Forces in Y Direction, for file:\n', path) );
    title(titleY);
    xlabel('Timestep');
    ylabel('Force (N?)');
    legend('Force Plate 0 (red)', 'Force Plate 1 (blue)');
    % Plot the z data
    zFigHandle = figure;
    hold on;
    plot(f0(:,3), '.r');
    plot(f1(:,3), '.b');
    % Create the title, which should include the name of the file passed in:
    titleZ = sprintf( strcat('UC Davis Testing Data, Forces in Z Direction, for file:\n', path) );
    title(titleZ);
    xlabel('Timestep');
    ylabel('Force (N?)');
    legend('Force Plate 0 (red)', 'Force Plate 1 (blue)');
end

end





