function plotFootMarkerDataSingleTest(markerdata, finalTimeIndices, hwLiftAngles)
%plotFootMarkerDataSingleTest
%   Does the plot of a single test of 4 feet in NTRT vs. hardware.
%   Should be equivalent to the plotting part of the IROS 2018 parsing
%   script.
%   Andrew P. Sabelhaus
%   Berkeley Emergent Space Tensegrities Lab
%   Sept. 8, 2018
%
%   @param[in] markerdata, from NTRT
%   @param[in] finalTimeIndices, last datapoint to plot for this test's
%   NTRT data. Manually written down by looking at the logs for when the
%   robot starts to tip over.
%   @param[in] hwLiftAngles, parsed from hardware data.


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

hold on;

% Plot until a pre-specified point in time in the simulation.
% The indices here are 1 and 4 
finalIndexA = finalTimeIndices(1);
finalIndexD = finalTimeIndices(4);

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

hold on;

% Plot until a pre-specified point in time in the simulation.
% The indices here are 2 and 3 
finalIndexB = finalTimeIndices(2);
finalIndexC = finalTimeIndices(3);

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



