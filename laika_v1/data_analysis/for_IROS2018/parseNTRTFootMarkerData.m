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

return

% For each of these, read in the data for each of these logs
%for i=1:4
    % Call csvread
%    markerdata{i}.data = csvread( markerdata{i}.path, 1, 0);
    % Adjust the data. All rows except the timestamp
%end

% Combine the results, maybe this is used for testing of the whole robot
num_samples = size(markerdata{1}.data, 1);
% Record the totals for x, y, and z directions, plus time.
markerdata{5}.data = zeros(num_samples, 4);
% But we also need to copy over the timestamps for column 1.
% Arbitrarily choose the first set of data from which to copy the timestamps.
markerdata{5}.data(:,1) = markerdata{1}.data(:,1);
for i=1:4
    % Copy over the x, y, and z, columns 2, 3, 4
    markerdata{5}.data(:,2) = markerdata{5}.data(:,2) + markerdata{i}.data(:,2);
    markerdata{5}.data(:,3) = markerdata{5}.data(:,3) + markerdata{i}.data(:,3);
    markerdata{5}.data(:,4) = markerdata{5}.data(:,4) + markerdata{i}.data(:,4);
end

if( make_plots )
    % Plot the forces in x, y, z for each forceplate.
    % Here are some good dimensions of figures:
    % fontsize = 12;
    %set(gca, 'FontSize', fontsize);
    %set(xhandle,'Position',[100,100,500,300]);
    %set(xhandle,'PaperPosition',[1,1,5,3]);
    
    fontsize = 14;
    
    % For all the below, use the openGL renderer so any symbols are properly formatted.
    % ACTUALLY, NO: it seems that the openGL renderer outputs raster images! No!
    % Need to use the default painter.
    
    % X: This is actually "Y" in the UC Davis notation. This is the interesting one, in the lateral direction.
    %xhandle = figure('Renderer', 'opengl');
    xhandle = figure;
    % Similar to the Y data, only plot a certain region.
    % Ignore the beginning of the simulation, 
    % since it has to settle down first.
    % Start the plots at:
    tstart = 5;
    % End the plots at:
    % Used to be
    tend = 22;
    % The dt for these simulations is roughly:
    dt = 0.01;
    % Number of timesteps to get to tstart seconds:
    timestep_start = tstart/dt;
    timestep_end = tend/dt;
    hold on;
    % Set up the plot
    set(gca, 'FontSize', fontsize);
    set(xhandle,'Position',[100,100,500,350]);
    set(xhandle,'PaperPosition',[1,1,5.8,3.5]);
    for i=1:4
        % create the modified time vector.
        t_temp_x = markerdata{i}.data(timestep_start:timestep_end,1);
        % subtract away the start time.
        t_temp_x = t_temp_x - tstart;
        % X data is column 2
        x_temp = markerdata{i}.data(timestep_start:timestep_end,2);
        % plot t vs. y for each plate
        %plot( fpdata{i}.data(:,1), fpdata{i}.data(:,3) )
        plot( t_temp_x, x_temp, 'LineWidth',2);
        % Store this data for analysis later
        markerdata{i}.t_foranalysis_x = t_temp_x;
        markerdata{i}.x_foranalysis = x_temp;
        % plot t vs. x for each plate
        %plot( fpdata{i}.data(:,1), fpdata{i}.data(:,2) )
    end
    title('NTRTsim ForcePlate Lateral Forces (Fy)');
    ylabel('Force Fy (N)');
    xlabel('Time (sec)');
    legend('RearLeft', 'RearRight', 'FrontLeft', 'FrontRight' );
    % Set the limits:
    ylim([-0.6 0.8]);
    % Draw vertical lines for the places where snapshots are taken
    % and analyzed in the ICRA 2017 paper
    % Credit to Brandon Kuczenski for the vline function
    vline(5, 'k--', 't_1',18);
    vline(12, 'k--', 't_2',18);
    vline(17, 'k--', 't_3',18);
    hold off;
    
    % Y. We're actually calling this "Z", since that's what the UC Davis force plate data used. These are the vertical forces.
    %yhandle = figure('Renderer', 'opengl');
    yhandle = figure;
    % For the Y data, start at a certain time. Ignore the beginning of the simulation, 
    % since it has to settle down first.
    % Start the plots at:
    tstart = 5;
    % End the plots at:
    % Used to be
    tend = 22;
    % The dt for these simulations is roughly:
    dt = 0.01;
    % Number of timesteps to get to tstart seconds:
    timestep_start = tstart/dt;
    timestep_end = tend/dt;
    % start making the graph
    hold on;
    set(gca, 'FontSize', fontsize);
    set(yhandle,'Position',[100,100,500,350]);
    set(yhandle,'PaperPosition',[1,1,5.8,3.5]);
    for i=1:4
        % create the modified time vector.
        t_temp = markerdata{i}.data(timestep_start:timestep_end,1);
        % subtract away the start time.
        t_temp = t_temp - tstart;
        y_temp = markerdata{i}.data(timestep_start:timestep_end,3);
        % plot t vs. y for each plate
        %plot( fpdata{i}.data(:,1), fpdata{i}.data(:,3) )
        plot( t_temp, y_temp,'LineWidth',2);
        % Store this data for analysis later
        markerdata{i}.t_foranalysis = t_temp;
        markerdata{i}.y_foranalysis = y_temp;
    end
    title('NTRTsim ForcePlate Vertical Forces (Fz)');
    ylabel('Force Fz (N)');
    xlabel('Time (sec)');
    % Set the limits
    %xlim([0 10]);
    %ylim([-3 17]);
    ylim([2 6]);
    % Draw vertical lines for the places where snapshots are taken
    % and analyzed in the ICRA 2017 paper
    % Credit to Brandon Kuczenski for the vline function
    vline(5, 'k--', 't_1',18);
    vline(12, 'k--', 't_2',18);
    vline(17, 'k--', 't_3',18);
    legend('RearLeft', 'RearRight', 'FrontLeft', 'FrontRight', 'Location', 'Northwest' );
    hold off;
    % Run statistics on the Y-data for the rear left leg.
    % RearLeft is plate 1.
    bin1start = 1;
    bin1end = 5/dt;
    bin2start = 12/0.01;
    % Calculate the total force the robot is exerting in simulation:
    disp('Total force inside bin1, all legs:');
    % Add up the force at a random number of timesteps into bin 1 (choose 10 timestamps in)
    total_force = markerdata{1}.y_foranalysis(10) + markerdata{2}.y_foranalysis(10) + markerdata{3}.y_foranalysis(10) + markerdata{4}.y_foranalysis(10)
    bin1 = markerdata{1}.y_foranalysis(bin1start:bin1end);
    bin2 = markerdata{1}.y_foranalysis(bin2start:end);
    bin1_FL = markerdata{3}.y_foranalysis(bin1start:bin1end);
    bin2_FL = markerdata{3}.y_foranalysis(bin2start:end);
    disp('Mean, rear left, bin1:');
    mean(bin1)
    disp('Mean, rear left, bin2:');
    mean(bin2)
    disp('Difference, rear left:');
    observed_diff = mean(bin2) - mean(bin1)
    disp('Mean, front left, bin1:');
    mean(bin1_FL)
    disp('Mean, front left, bin2:');
    mean(bin2_FL)
    disp('Difference, front left:');
    observed_diff_FL = mean(bin2_FL) - mean(bin1_FL)
    %std(bin1)
    %std(bin2)
    %std_err1 = std(bin1) / sqrt(size(bin1,1) )
    %std_err2 = std(bin2) / sqrt(size(bin2,1) )
    %std_err_diff = sqrt( std_err1^2 + std_err2^2 )
    %z = observed_diff / std_err_diff
    % Then, calculate z symbolically, since normcdf doesn't take z-values this large.
    % thanks to:
    % http://math.stackexchange.com/questions/806814/numerical-precision-of-product-of-probabilities-normal-cdf
    %z_sym = sym(z);
    %p_sym = normcdf(z_sym, 0, 1)
    %p_sym_evaluated = vpa(p_sym)
    
    % Z
    zhandle = figure('Renderer', 'opengl');
    hold on;
    for i=1:4
        % plot t vs. z for each plate
        plot( markerdata{i}.data(:,1), markerdata{i}.data(:,4) )
    end
    title('Force plate Fz forces vs. time');
    ylabel('Force Fz (N)');
    xlabel('Time (sec)');
    legend('RearLeft', 'RearRight', 'FrontLeft', 'FrontRight' );
    hold off;
    
    % Plot the total Fy, for perspective on how much the robot weighs.
%     figure;
%     hold on;
%     plot( fpdata{5}.data(:,1), fpdata{5}.data(:,3) );
%     title('Total forces in Y, NTRT force plates, vs. time');
%     ylabel('Force Fy (N)');
%     xlabel('Time (sec)');
%     hold off;
end




