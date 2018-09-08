function markerdata = parseNTRTFootMarkerDataOnly(filepaths)
%parseNTRTForcePlateDataMany.m
%   Parses and plots the data from all 4 foot-lifting tests of Laika in
%   NTRT, for ICRA 2019, now only doing NTRT and not hardware.
%   Andrew P. Sabelhaus
%   Berkeley Emergent Space Tensegrities Lab
%   Sept. 8, 2018
%
%   @param[in] filepaths, a struct with strings for feet A, B, C, and D


% The column to read is different for each foot marker.
% For the respective test, the column with the Y data for its marker is:
% (example, "3" is column "4" in excel)
% BUT now that we're reading in to a matlab matrix, index from 1.
markerYcols = [4, 7, 10, 13];

% Read in all the data. We'll need to concatenate / index the Y positions
% against the actual rotations, so need column 2 for everything also.
% So just start from column 0.
% Changing from before: filepaths is now a cell array, not a struct, and
% the A to D feet are indices 1 to 4.

alldatatemp = csvread(filepaths{1}, 2, 0);
% but now as a matrix we index from 1.
markerdata{1} = [alldatatemp(:,2), alldatatemp(:, markerYcols(1))];

% For all other feet:
alldatatemp = csvread(filepaths{2}, 2, 0);
markerdata{2} = [alldatatemp(:,2), alldatatemp(:, markerYcols(2))];

alldatatemp = csvread(filepaths{3}, 2, 0);
markerdata{3} = [alldatatemp(:,2), alldatatemp(:, markerYcols(3))];

alldatatemp = csvread(filepaths{4}, 2, 0);
markerdata{4} = [alldatatemp(:,2), alldatatemp(:, markerYcols(4))];



% now that we have the rotation/ foot lift data, plot some combinations of
% it:
if( 0 )
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
    %finalIndexA = 1620;
    %finalIndexA = 2470;
    %finalIndexA = 2669;
    hold on;
    % Let's do foot D also
    %finalIndexD = 1620;
    %finalIndexD = 2500;
    %finalIndexD = 2846;
    
    % For the ICRA 2019 data:
    % Min (216), at bottom = 810:
%     finalIndexA = 2212;
%     finalIndexD = 2546;
    % Min (216) at bottom = 941:
%     finalIndexA = 2355;
%     finalIndexD = 2664;
    % Max (258) at bottom = 941"
%     finalIndexA = 2726;
%     finalIndexD = 2848;

    % Data for the 20 tests:
    % Tests 1-4 (min tension):
%     finalIndexA = 2200;
%     finalIndexD = 2317;
    % Tests 17-20 (max tension):
    finalIndexA = 2787;
    finalIndexD = 2910;
    
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
    legend('Foot A, Left Bend', 'Foot D, Right Bend', 'Location', 'Northwest');
    % Set the limits:
    ylim([0 5]);
    xlim([0 0.7]);
    
    %%%%%% SIMULATION VERTICAL LINES
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
    %vline( lifted_A_rad, 'b--', 'lift',18);
    %vline( lifted_D_rad, 'r--', 'lift',18);
    %vline(12, 'k--', 't_2',18);
    %vline(17, 'k--', 't_3',18);


    %%%%%% HARDWARE VERTICAL LINES
    
    % Min and max test lift angles for A
    % A is negative angles
    liftMinA = - max(hwLiftAngles(1,:));
    liftMaxA = - min(hwLiftAngles(1,:));
    % for D, also negative
    liftMinD = - max(hwLiftAngles(4,:));
    liftMaxD = - min(hwLiftAngles(4,:));
    
    % Plot temporarily in blue for A and red for D
    vline( liftMinA, 'b--', ' ',18);
    vline( liftMaxA, 'b--', ' ',18);
    vline( liftMinD, 'r--', ' ',18);
    vline( liftMaxD, 'r--', ' ',18);
    
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
    %finalIndexB = 2950;
    %finalIndexB = 3590;
    %finalIndexB = 4391;
    %finalIndexB = 4192;
    hold on;
    %finalIndexC = 2550;
    %finalIndexC = 3800;
    %finalIndexC = 4336;
    %finalIndexC = 3967;
    
    % For the ICRA 2019 data:
    % Min (216), at bottom = 810:
%     finalIndexB = 3184;
%     finalIndexC = 3741;
    % Min (216), at bottom = 941:
%     finalIndexB = 3883;
%     finalIndexC = 4135;
    % Max (258) at bottom = 941:
%     finalIndexB = 4306;
%     finalIndexC = 4252;
    
    % Data for the 20 tests:
    % Tests 1-4 (min tension):
%     finalIndexB = 3634;
%     finalIndexC = 2980;
    % Tests 17-20 (max tension):
    finalIndexB = 4530;
    finalIndexC = 4370;

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
    legend('Foot B, Left Bend', 'Foot C, Right Bend', 'Location', 'Northwest');
    % Set the limits:
    ylim([0 5]);
    %xlim([0 0.6]);
    xlim([0, 0.7]);
    
    
    %%%%%%%%%%% SIMULATION VERTICAL LINES
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
    %vline( lifted_B_rad, '--', 'lift',18);
    %vline( lifted_C_rad, '--', 'lift',18);
    %vline(12, 'k--', 't_2',18);
    %vline(17, 'k--', 't_3',18);
    %hold off;

    %%%%%% HARDWARE VERTICAL LINES
    
    % Min and max test lift angles for B
    % B is positive angles
    liftMaxB = max(hwLiftAngles(2,:));
    liftMinB = min(hwLiftAngles(2,:));
    % for C, positive
    liftMaxC = max(hwLiftAngles(3,:));
    liftMinC = min(hwLiftAngles(3,:));
    
    % Plot temporarily in yellow for B and magenta for C
    % was 'lift'
    bminline = vline( liftMinB, 'y--', ' ',18);
    bmaxline = vline( liftMaxB, 'y--', ' ',18);
    vline( liftMinC, 'm--', ' ',18);
    vline( liftMaxC, 'm--', ' ',18);
    
    % try setting better colors for the B line
    bminline.Color = colorB;
    bmaxline.Color = colorB;

end



