function plotFootMarkerDataMultipleTest(markerdata_all, finalTimeIndices, hwLiftAngles)
%plotFootMarkerDataMultipleTest
%   Does the plot of multiple tests of 4 feet in NTRT vs. hardware.
%   Outputs a plot with N many subplots.
%   Andrew P. Sabelhaus
%   Berkeley Emergent Space Tensegrities Lab
%   Sept. 8, 2018
%
%   @param[in] markerdata, from NTRT
%   @param[in] finalTimeIndices, last datapoint to plot for these tests'
%   NTRT data. Manually written down by looking at the logs for when the
%   robot starts to tip over.
%   @param[in] hwLiftAngles, parsed from hardware data.


% Here's the plan:
% - Rotation along the x-axis
% - Foot height along the y-axis
% - Curves are for both +/- rotations, where we then have two plots: one
% for A/D, the other for B/C, where one of each lifts in quadrants 1,2.
% - Vertical line plotted where hardware was observed to lift a foot.

% For the colors, we'll do blue-to-purple-to-red.
% The markerdata cell array should be a row.
% n is the number of tests.
n = 5;
%...this is hard-coded since the code doesn't need to be re-used for now.

% The five colorsets are:
% Blue, Blue-purple, purple, purple-red, red
% Triplet is R, G, B
% original attempt:
% colorsForPlot{1} = [0,      0,      1];
% colorsForPlot{2} = [0.5,    0,      1];
% colorsForPlot{3} = [1,      0,      1];
% colorsForPlot{4} = [1,      0,      0.5];
% colorsForPlot{5} = [1,      0,      0];

% Manually adjusted:
% colorsForPlot{1} = [0,      0,      1];
% colorsForPlot{2} = [0.5,    0,      1];
% colorsForPlot{3} = [0.75,      0,      0.75];
% colorsForPlot{4} = [1,      (153/255),      (51/255)];
% colorsForPlot{5} = [1,      0,      0];

colorsForPlot{1} = [0,      0,      1];
colorsForPlot{2} = [0.75,    0,      0.75];
colorsForPlot{3} = [(25/255),      (208/255),      (68/255)];
colorsForPlot{4} = [1,      (153/255),      (51/255)];
colorsForPlot{5} = [1,      0,      0];

% To make the colors nice, let's explicitly define them.
% The 'lines' command gives an N x 3 matrix of RBG color values.
% First two are for feet A and D, etc.
% colorsForPlot = lines;
% colorA = colorsForPlot(1,:);
% colorD = colorsForPlot(2,:);
% colorB = colorsForPlot(3,:);
% colorC = colorsForPlot(4,:);

% Here are some good dimensions of figures:
% fontsize = 12;
%set(gca, 'FontSize', fontsize);
%set(xhandle,'Position',[100,100,500,300]);
%set(xhandle,'PaperPosition',[1,1,5,3]);

fontsize = 14;

% For all the below, use the openGL renderer so any symbols are properly formatted.
% ACTUALLY, NO: it seems that the openGL renderer outputs raster images! No!
% Need to use the default painter.

% Specify the starting and ending index for the data.
% This is like "what time to start measuring at, what time to stop."
% Let's choose 5 seconds for the start for all:
dt = 0.01;
tstart = 5;
startIndex = tstart/dt;

%%%% Start the plotting
fighandle = figure;
hold on;
% Set up the plot
set(gca, 'FontSize', fontsize);
% Make it roughly twice the height of Drew's usual size.
%set(fighandle,'Position',[100,100,500,350]);
set(fighandle,'Position',[100,100,550,650]);
%set(fighandle,'Position',[100,100,450,700]);
%set(fighandle,'PaperPosition',[1,1,5.8,3.5]);

% Pre-calculate: lifting angles for all 4 feet.
% This differs according to A/D vs. B/C, so do it manually outside the
% loop.
% Min and max test lift angles for foot j
liftMin = [];
liftMax = [];
% A and D are negative angles
liftMin(1) = - max(hwLiftAngles(1,:));
liftMax(1) = - min(hwLiftAngles(1,:));
liftMin(4) = - max(hwLiftAngles(4,:));
liftMax(4) = - min(hwLiftAngles(4,:));
% B and C are positive angles
liftMax(2) = max(hwLiftAngles(2,:));
liftMin(2) = min(hwLiftAngles(2,:));
liftMax(3) = max(hwLiftAngles(3,:));
liftMin(3) = min(hwLiftAngles(3,:));

%%%%%%%%%%%%%%%%
% First plot (foot A): do it separately, since this is where the legend comes in.
% Subplot 1!
subplot_handle = subplot(4,1,1);
hold on;
set(gca, 'FontSize', fontsize);

% Make the top plot a bit 'bigger' to make room for the legend.
% This is in FRACTIONS now, not pixels.
subplot_handle.Position = subplot_handle.Position + [0, -0.06, 0, 0.06];

% Here, we need to subtract the first datapoint (the offset!) from
% everything. The offset value is the second column (radians)
for i=1:n
    % This plot is foot A (foot 1), store the offset for each n of the
    % tests
    offsets(i) = markerdata_all{i}{1}(startIndex, 2);
end

% Subtract from all second-column datapoints.
for i=1:n
    markerdata_all{i}{1}(:,2) = markerdata_all{i}{1}(:,2) - offsets(i);
    % Also, we need to scale the data to centimeters (from meters).
    markerdata_all{i}{1}(:,2) = markerdata_all{i}{1}(:,2) * 100;
end

% plot rotation vs. foot height for A, tests 1 to n.
% Column 1 is rotation, column 2 is height in cm.
for i=1:n
    % test i uses colorsForPlot{i}, and final time index i, 1
    finalIndexA = finalTimeIndices(i,1);
    plot(markerdata_all{i}{1}(startIndex:finalIndexA,1), markerdata_all{i}{1}(startIndex:finalIndexA,2), 'LineWidth', 2, 'Color', colorsForPlot{i});
end

% A kinda poor hack to get the labels for feet via indexing.
footlabel = {'A', 'B', 'C', 'D'};

% this makes MATLAB include the whitespace between Foot and A
ylabel(strcat({'Foot'}, {' '}, {footlabel{1}}, {' '}, {'(cm)'}));
% Was: ylabel('Foot A (cm)');
%xlabel('Center Vert. Rotation (rad)');
% Set the limits:
ylim([0 3]);
xlim([0 0.65]);


% Set up the top of the plot.
currenttitle = title('Foot Vertical Position, Simulation vs. Hardware');
% Move the title up a bit so it doesn't collide with the Y-axis.
currentpos = currenttitle.Position;
titleshift = [0, 0.3, 0];
newposition = currentpos + titleshift;
set(currenttitle, 'Position', newposition);
%currenttitle.Position = currenttitle.Position + [0, 0, 0];

%%%%%% HARDWARE VERTICAL LINES

% Min and max test lift angles for A
% A is negative angles
% liftMinA = - max(hwLiftAngles(1,:));
% liftMaxA = - min(hwLiftAngles(1,:));

% Plot in black for clarity? Too many colors going on here.
vhandle1 = vline( liftMin(1), 'k--', ' ',18);
vhandle2 = vline( liftMax(1), 'k--', ' ',18);
% Need to set these to visible so they have legend entries.
% Since it's the same line style, we'll just label one of the two.
set(vhandle1, 'HandleVisibility', 'on');

% legend goes at the top of the plot?
% Set the interpreter to latex to get the symbols nicer.
leg = legend('Min. Tens. (-2$\sigma$)', 'Med-Low Tension', ...
    'Mean Tension ($\mu$)', 'Med-High Tension', 'Max. Tens. (+2$\sigma$)', 'Hardware Range','Location', 'Northwest');
set(leg, 'Interpreter', 'latex');
% Font doesn't need to be as big as everything else.
leg.FontSize = 12;
% we can also move it up.
leg.Position = leg.Position + [0, 0.03, 0, 0];

hold off;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% FOR THE REMAINING 3 FEET:
for j=2:4
    % This is for foot j. We're doing the test as indexing through i.
    % Subplot j!
    subplot_handle = subplot(4,1,j);
    hold on;
    set(gca, 'FontSize', fontsize);
    % Make these plots a bit 'smaller' to make room for the legend.
    % This is in FRACTIONS now, not pixels.
    % calculate a good offset: want to shift them all down, but then need
    % to compress a bit (so j=3 and 4 need an additional 'up' offset.)
    suboffset = -0.04 + (0.01 * (j-2));
    subplot_handle.Position = subplot_handle.Position + [0, suboffset, 0, -0.03];

    % Here, we need to subtract the first datapoint (the offset!) from
    % everything. The offset value is the second column (radians)
    for i=1:n
        % This plot is foot j, store the offset for each n of the
        % tests
        offsets(i) = markerdata_all{i}{j}(startIndex, 2);
    end

    % Subtract from all second-column datapoints.
    for i=1:n
        markerdata_all{i}{j}(:,2) = markerdata_all{i}{j}(:,2) - offsets(i);
        % Also, we need to scale the data to centimeters (from meters).
        markerdata_all{i}{j}(:,2) = markerdata_all{i}{j}(:,2) * 100;
    end

    % plot rotation vs. foot height for j, tests 1 to n.
    % Column 1 is rotation, column 2 is height in cm.
    for i=1:n
        % test i uses colorsForPlot{i}, and final time index i, 1
        finalIndex = finalTimeIndices(i,j);
        plot(markerdata_all{i}{j}(startIndex:finalIndex,1), markerdata_all{i}{j}(startIndex:finalIndex,2), 'LineWidth', 2, 'Color', colorsForPlot{i});
    end

    % Set up the top of the plot.
    %title('Foot Height, Simulation vs. Hardware');
    %ylabel(strcat('Foot ', footlabel{j}, ', (cm)'));
    %ylabel(strcat({'Foot'}, {' '}, {footlabel{j}}, {' '}, {'(cm)'}));
    %ylabel(footlabel{j});
    ylabel(strcat({footlabel{j}}, {' '}, {'(cm)'}));
    %xlabel('Center Vert. Rotation (rad)');
    % Set the limits:
    ylim([0 3]);
    xlim([0 0.65]);

    %%%%%% HARDWARE VERTICAL LINES
    % Plot in black for clarity? Too many colors going on here.
    vline( liftMin(j), 'k--', ' ',18);
    vline( liftMax(j), 'k--', ' ',18);
    % Need to set these to visible so they have legend entries.
    % Since it's the same line style, we'll just label one of the two.
    set(vhandle1, 'HandleVisibility', 'on');
end

% For the last plot, add the horizontal axis label.
xlabel('Center Vertebra Rotation (rad)');

end


