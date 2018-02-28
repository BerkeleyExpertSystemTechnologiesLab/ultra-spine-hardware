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
    
    % To make the colors nice, let's explicitly define them.
    % The 'lines' command gives an N x 3 matrix of RBG color values.
    % First two are for feet A and D, etc.
    colorsForPlot = lines;
    colorA = colorsForPlot(1,:);
    colorD = colorsForPlot(2,:);
    colorB = colorsForPlot(3,:);
    colorC = colorsForPlot(4,:);
    
    % Here are some good dimensions of figures:
    % fontsize = 12;
    %set(gca, 'FontSize', fontsize);
    %set(xhandle,'Position',[100,100,500,300]);
    %set(xhandle,'PaperPosition',[1,1,5,3]);
    
    fontsize = 14;
    
    % For all the below, use the openGL renderer so any symbols are properly formatted.
    % ACTUALLY, NO: it seems that the openGL renderer outputs raster images! No!
    % Need to use the default painter.
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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
    % Actually, let's make it much before that, so no vibrations. (2500)
    % for the SI units: about
    finalIndexA = 1620;
    hold on;
    % Let's do foot D also
    finalIndexD = 1620;
    
    % Here, we need to subtract the first datapoint (the offset!) from
    % everything. The offset value is the second column (radians)
    offsetA = markerdata{1}(startIndex, 2);
    offsetD = markerdata{4}(startIndex, 2);
    % Subtract from all second-column datapoints.
    markerdata{1}(:,2) = markerdata{1}(:,2) - offsetA;
    markerdata{4}(:,2) = markerdata{4}(:,2) - offsetD;
    
    % Also, we need to scale the data to centimeters (from meters).
    markerdata{1}(:,2) = markerdata{1}(:,2) * 100;
    markerdata{4}(:,2) = markerdata{4}(:,2) * 100;
    
    % Set up the plot
    set(gca, 'FontSize', fontsize);
    set(adhandle,'Position',[100,100,500,350]);
    set(adhandle,'PaperPosition',[1,1,5.8,3.5]);

    % plot rotation vs. foot height for A and D.
    % Column 1 is rotation, column 2 is height in cm.
    plot( markerdata{1}(startIndex:finalIndexA,1), markerdata{1}(startIndex:finalIndexA,2), 'LineWidth', 2, 'Color', colorA);
    plot( markerdata{4}(startIndex:finalIndexD,1), markerdata{4}(startIndex:finalIndexD,2), 'LineWidth', 2, 'Color', colorD);
    
    title('Foot Height with CCW Rotation');
    ylabel('Foot Height (cm)');
    xlabel('Center Vert. Rotation (rad)');
    legend('Foot A, Left Bend (Sim)', 'Foot D, Right Bend (Sim)', 'Location', 'Best');
    % Set the limits:
    ylim([0 5]);
    xlim([0 0.5]);
    
    % Draw vertical lines for the places where we first observe the feet to
    % lift.
    % Specify some 'epsilon' for 'has lifted'. In cm.
    eps_lifted = 0.1;
    % get the index for the element which is larger than this epsilon.
    % The greater-than operator returns a list of bools, so we find the
    % first "true", subject to our index range constraints.
    %markerdata{1}(startIndex:finalIndexA,2) 
    lifted_A = find(markerdata{1}(startIndex:finalIndexA,2) > eps_lifted, 1);
    lifted_D = find(markerdata{4}(startIndex:finalIndexD,2) > eps_lifted, 1);
    % These need to be incremented by startIndex, since that's offset
    lifted_A = lifted_A + startIndex;
    lifted_D = lifted_D + startIndex;
    
    % The x-axis point is the first-column of the data at the lifted_X
    % index
    % Print these to the terminal for recording later
    lifted_A_rad = markerdata{1}(lifted_A, 1)
    lifted_D_rad = markerdata{4}(lifted_D, 1)
    % Credit to Brandon Kuczenski for the vline function
    vline( lifted_A_rad, 'b--', 'lift',18);
    vline( lifted_D_rad, 'r--', 'lift',18);
    %vline(12, 'k--', 't_2',18);
    %vline(17, 'k--', 't_3',18);
    
    hold off;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%% FOR THE B/C PLOT

    bchandle = figure;
    % Specify the starting and ending index for the data.
    % This is like "what time to start measuring at, what time to stop."
    % Let's choose 5 seconds for the start for all:
    dt = 0.01;
    tstart = 5;
    startIndex = tstart/dt;
    % B/C plots
    finalIndexB = 2950;
    hold on;
    finalIndexC = 2550;
    
    % Here, we need to subtract the first datapoint (the offset!) from
    % everything. The offset value is the second column (radians)
    offsetB = markerdata{2}(startIndex, 2);
    offsetC = markerdata{3}(startIndex, 2);
    % Subtract from all second-column datapoints.
    markerdata{2}(:,2) = markerdata{2}(:,2) - offsetB;
    markerdata{3}(:,2) = markerdata{3}(:,2) - offsetC;
    
    % Also, we need to scale the data to centimeters (from meters).
    markerdata{2}(:,2) = markerdata{2}(:,2) * 100;
    markerdata{3}(:,2) = markerdata{3}(:,2) * 100;
    
     % Set up the plot
    set(gca, 'FontSize', fontsize);
    set(bchandle,'Position',[100,100,500,350]);
    set(bchandle,'PaperPosition',[1,1,5.8,3.5]);

    % plot rotation vs. foot height for B and C.
    % Column 1 is rotation, column 2 is height in cm.
    plot( markerdata{2}(startIndex:finalIndexB,1), markerdata{2}(startIndex:finalIndexB,2), 'LineWidth', 2, 'Color', colorB);
    plot( markerdata{3}(startIndex:finalIndexC,1), markerdata{3}(startIndex:finalIndexC,2), 'LineWidth', 2, 'Color', colorC);
    
    title('Foot Height with CW Rotation');
    ylabel('Foot Height (cm)');
    xlabel('Center Vert. Rotation (rad)');
    legend('Foot B, Left Bend (Sim)', 'Foot C, Right Bend (Sim)', 'Location', 'Best');
    % Set the limits:
    ylim([0 5]);
    xlim([0 0.5]);
    
    
    % Draw vertical lines for the places where we first observe the feet to
    % lift.
    % Specify some 'epsilon' for 'has lifted'. In cm.
    eps_lifted = 0.1;
    % get the index for the element which is larger than this epsilon.
    % The greater-than operator returns a list of bools, so we find the
    % first "true", subject to our index range constraints.
    %markerdata{1}(startIndex:finalIndexA,2) 
    lifted_B = find(markerdata{2}(startIndex:finalIndexB,2) > eps_lifted, 1);
    lifted_C = find(markerdata{3}(startIndex:finalIndexC,2) > eps_lifted, 1);
    % These need to be incremented by startIndex, since that's offset
    lifted_B = lifted_B + startIndex;
    lifted_C = lifted_C + startIndex;
    
    % The x-axis point is the first-column of the data at the lifted_X
    % index
    % Print these to the terminal for recording later
    lifted_B_rad = markerdata{2}(lifted_B, 1)
    lifted_C_rad = markerdata{3}(lifted_C, 1)
    
    % Credit to Brandon Kuczenski for the vline function
    vline( lifted_B_rad, '--', 'lift',18);
    vline( lifted_C_rad, '--', 'lift',18);
    %vline(12, 'k--', 't_2',18);
    %vline(17, 'k--', 't_3',18);
    hold off;

end




