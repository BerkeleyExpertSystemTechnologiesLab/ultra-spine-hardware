% Parse the NTRT sensor data. Calculate foot positions based on
% the combined rigid body center of mass and its rotation.
% Andrew P. Sabelhaus 2018

% prep
clear all;
clc;
close all;

% parameters
%logfile_name = 'LaikaCombinedMotion_02172018_143112.txt';
% with "no drop"
logfile_name = 'LaikaCombinedMotion_02172018_152635.txt';
position_X_column = 136; % we'll assume Y is next, then Z.
% need to switch "Y" and "Z" since Bullet is dumb and does Y as vertical,
% but that should happen after all the transformations.
% we'll assume that the three euler angles follow the x, y, z.
% Global coordinate frame, with respect to Laika pre-drop, of one foot.
z_trans = 8; % this is in the *third* element of Bullet's vectors, which we'd usually call "Y", and is NOT the vertical direction.
hips_global = [10, 45.5, z_trans]; % coordinate system of the hips in global frame
front_global = [-18, 45.5, z_trans]; % same with front
% local initial positions of each of the leg connections:
leg_C_local = [15, 0, 15]; % "back right"
leg_D_local = [15, 0, -15]; % "back left"
leg_A_local = [-15, 0, 15]; % front, right
leg_B_local = [-15, 0, -15]; % front, left
% local position of sphere within each leg
sphere_local = [0, -30, 0];
% Any additional global offset from the YAML files
global_offset = [0, -10.5, -8];

% Call csvread:
% Data starts at the third row (row two.)
data = csvread( logfile_name, 2, 0);
% this should give us a whole matrix.

% Pick out the position vectors:
whole_body_pos = data(:, position_X_column : position_X_column + 2);
% and rotations:
whole_body_rot = data(:, position_X_column + 3 : position_X_column + 5);

% calculate the (initial) global positions of each of the four feet.
% These will be, for example,
% (hip position) + (trans to leg attach) + (trans to foot) + (global
% offset)
% make them columns
foot_C_global = (hips_global + leg_C_local + sphere_local + global_offset)';
foot_D_global = (hips_global + leg_D_local + sphere_local + global_offset)';
foot_A_global = (front_global + leg_A_local + sphere_local + global_offset)';
foot_B_global = (front_global + leg_B_local + sphere_local + global_offset)';

% Plot the four positions to see if this makes sense.
feet_global = [foot_A_global, foot_B_global, foot_C_global, foot_D_global];

% In addition, NTRT's "zero" is really at some higher distance, AND,
% the center of the sphere is not the point that contacts the bottom.
% It seems as if the "zero height" of the feet, or the "touching the
% ground" of the feet, is at
feet_initial_Z = foot_A_global(2);
% ...we can subtract this back in later.

% Important: get the (approx?) global initial center of mass of each 
% compound rigid (the shoulders, and the hips). This is because
% Bullet doesn't let us specify a local frame, and instead
% stores the whole body's COM. This is why we need the robot to be 
% "close to" the ground when the simulation begins.
% column vector.
shoulders_global_COM = whole_body_pos(1,:)';
% We have to be careful here: the position_x_column needs to be for
% shoulders. Also specify another for the hips!!

% We can now find the local vector between the rigid body's COM and
% the feet.
A_from_COM = foot_A_global - shoulders_global_COM;
B_from_COM = foot_B_global - shoulders_global_COM;

% OK, so... we should now be able to calculate the foot positions 
% by the following:
% (1) rotate the local vector according to the rotation matrix of the rigid
% body at that timestep
% (2) add the global COM back in

% Store the positions.
% Do this more intelligently, as column vectors.
footA_pos = zeros(size(whole_body_pos))';
footB_pos = zeros(size(whole_body_pos))';

% At each timestep:
for i = 1: size(whole_body_pos, 1)
    % Form the rotation matrix
    t = whole_body_rot(i, 1);
    g = whole_body_rot(i, 2);
    p = whole_body_rot(i, 3);
    R1 = [ 1          0           0         ;
           0          cos(t)   sin(t) ;
           0         -sin(t)   cos(t)];

    R2 = [cos(g)   0           sin(g) ;
          0           1           0         ;
         -sin(g)   0           cos(g)];

    R3 = [cos(p)   sin(p)   0         ;
         -sin(p)   cos(p)   0         ;
          0           0           1        ];
    % Building full Rotation Matrix
    Rot=R3*R2*R1;
    
    % Get the rotation of the local foot->COM vector
    A_rotated = Rot * A_from_COM;
    B_rotated = Rot * B_from_COM;
    % Add back the global COM of the body, store.
    % Need to transpose data matrix.
    footA_pos(:,i) = A_rotated + whole_body_pos(i,:)';
    footB_pos(:,i) = B_rotated + whole_body_pos(i,:)';
    % Subtract away the initial height of the feet.
    footA_pos(2,i) = footA_pos(2,i) - feet_initial_Z;
    footB_pos(2,i) = footB_pos(2,i) - feet_initial_Z;
end

%plot3(footA_pos(1,:), footA_pos(2,:), footA_pos(3,:));

% some plotting
figure;
hold on;
plot(footA_pos(3,:));
title('Foot A positions');

figure;
hold on;
plot(footB_pos(3,:));
title('Foot B positions');
















