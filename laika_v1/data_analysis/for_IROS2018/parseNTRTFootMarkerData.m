function [ markerdata ] = parseNTRTFootMarkerData( filepaths, make_plots )
%parseNTRTForcePlateData.m
%   Parses and plots the data from all 4 foot-lifting tests of Laika in
%   NTRT, for IROS 2018
%   Andrew P. Sabelhaus
%   Berkeley Emergent Space Tensegrities Lab
%   Feb. 24th, 2018
%
%   @param[in] filepaths, a struct with strings for feet A, B, C, and D
%   @param[in] make_plots, a flag that controls creation of graphs of the data or not
%   @retvar[out] fpdata, a cell array will all the force plate data nicely organized.

% The column to read is different for each foot marker.
% For the respective test, the column with the Y data for its marker is:
% (example, "3" is column "4" in excel)
% BUT now that we're reading in to a matlab matrix, index from 1.
markerYcols = [4, 7, 10, 13];

% Read in all the data. We'll need to concatenate / index the Y positions
% against the actual rotations, so need column 2 for everything also.
% So just start from column 0.
alldatatemp = csvread( filepaths.A, 2, 0);
% but now as a matrix we index from 1.
markerdata{1} = [alldatatemp(:,2), alldatatemp(:, markerYcols(1))];
% For all other feet:
alldatatemp = csvread( filepaths.B, 2, 0);
markerdata{2} = [alldatatemp(:,2), alldatatemp(:, markerYcols(2))];
alldatatemp = csvread( filepaths.C, 2, 0);
markerdata{3} = [alldatatemp(:,2), alldatatemp(:, markerYcols(3))];
alldatatemp = csvread( filepaths.D, 2, 0);
markerdata{4} = [alldatatemp(:,2), alldatatemp(:, markerYcols(4))];

% now that we have the rotation/ foot lift data, plot some combinations of
% it:
if( make_plots )
    % Here's the plan:
    % - Rotation along the x-axis
    % - Foot height along the y-axis
    % - Curves are for both +/- rotations, where we then have two plots: one
    % for A/D, the other for B/C, where one of each lifts in quadrants 1,2.
    % - Vertical line plotted where hardware was observed to lift a foot.
    
    % Here are some good dimensions of figures:
    % fontsize = 12;
    %set(gca, 'FontSize', fontsize);
    %set(xhandle,'Position',[100,100,500,300]);
    %set(xhandle,'PaperPosition',[1,1,5,3]);
    
    fontsize = 14;
    
    % For all the below, use the openGL renderer so any symbols are properly formatted.
    % ACTUALLY, NO: it seems that the openGL renderer outputs raster images! No!
    % Need to use the default painter.
    
    %%%%%%%% FOR THE A/D PLOT
    
    adhandle = figure;
    % Specify the starting and ending index for the data.
    % This is like "what time to start measuring at, what time to stop."
    % Let's choose 5 seconds for the start for all:
    dt = 0.01;
    tstart = 5;
    startIndex = tstart/dt;
    % For the end, in the A/D plots, things looked good up until about 26 or
    % 27 seconds, which is 2650.
    % Actually, let's make it much before that, so no vibrations.
    finalIndexA = 2500;
    hold on;
    % Let's do foot D also
    finalIndexD = 2500;
    
    % Set up the plot
    set(gca, 'FontSize', fontsize);
    set(adhandle,'Position',[100,100,500,350]);
    set(adhandle,'PaperPosition',[1,1,5.8,3.5]);

    % plot rotation vs. foot height for A and D.
    % Column 1 is rotation, column 2 is height in cm.
    plot( markerdata{1}(startIndex:finalIndexA,1), markerdata{1}(startIndex:finalIndexA,2), 'LineWidth', 2);
    plot( markerdata{4}(startIndex:finalIndexD,1), markerdata{1}(startIndex:finalIndexD,2), 'LineWidth', 2);
    
    title('Foot Height');
    ylabel('Foot Height (cm)');
    xlabel('Center Vert. Rotation (rad)');
    legend('FrontRight', 'RearLeft');
    % Set the limits:
    %ylim([-0.6 0.8]);
    % Draw vertical lines for the places where snapshots are taken
    % and analyzed in the ICRA 2017 paper
    % Credit to Brandon Kuczenski for the vline function
    %vline(5, 'k--', 't_1',18);
    %vline(12, 'k--', 't_2',18);
    %vline(17, 'k--', 't_3',18);
    hold off;
    
    
    
    
    
%     % Y. We're actually calling this "Z", since that's what the UC Davis force plate data used. These are the vertical forces.
%     %yhandle = figure('Renderer', 'opengl');
%     yhandle = figure;
%     % For the Y data, start at a certain time. Ignore the beginning of the simulation, 
%     % since it has to settle down first.
%     % Start the plots at:
%     tstart = 5;
%     % End the plots at:
%     % Used to be
%     tend = 22;
%     % The dt for these simulations is roughly:
%     dt = 0.01;
%     % Number of timesteps to get to tstart seconds:
%     timestep_start = tstart/dt;
%     timestep_end = tend/dt;
%     % start making the graph
%     hold on;
%     set(gca, 'FontSize', fontsize);
%     set(yhandle,'Position',[100,100,500,350]);
%     set(yhandle,'PaperPosition',[1,1,5.8,3.5]);
%     for i=1:4
%         % create the modified time vector.
%         t_temp = markerdata{i}.data(timestep_start:timestep_end,1);
%         % subtract away the start time.
%         t_temp = t_temp - tstart;
%         y_temp = markerdata{i}.data(timestep_start:timestep_end,3);
%         % plot t vs. y for each plate
%         %plot( fpdata{i}.data(:,1), fpdata{i}.data(:,3) )
%         plot( t_temp, y_temp,'LineWidth',2);
%         % Store this data for analysis later
%         markerdata{i}.t_foranalysis = t_temp;
%         markerdata{i}.y_foranalysis = y_temp;
%     end
%     title('NTRTsim ForcePlate Vertical Forces (Fz)');
%     ylabel('Force Fz (N)');
%     xlabel('Time (sec)');
%     % Set the limits
%     %xlim([0 10]);
%     %ylim([-3 17]);
%     ylim([2 6]);
%     % Draw vertical lines for the places where snapshots are taken
%     % and analyzed in the ICRA 2017 paper
%     % Credit to Brandon Kuczenski for the vline function
%     vline(5, 'k--', 't_1',18);
%     vline(12, 'k--', 't_2',18);
%     vline(17, 'k--', 't_3',18);
%     legend('RearLeft', 'RearRight', 'FrontLeft', 'FrontRight', 'Location', 'Northwest' );
%     hold off;

end




