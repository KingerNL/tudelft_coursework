%% Cleaning
clc; clear all; close all;

%% Non-tunable parameters
par.g = 9.81;
par.Vinit   = 50 /3.6;              % initialization velocity, Don't TUNE
% Vehicle/Body (Camry)
par.mass     = 1380;                % vehicle mass, kg      
par.Izz      = 2634.5;              % body inertia around z-axis, kgm^2
par.L        = 2.79;                % wheelbase, m
par.l_f      = 1.384;               % distance from front axle to CoG, m
par.l_r      = par.L - par.l_f;     % distance from rear axle to CoG, m
% Steering
par.i_steer  = 15.4;                % steering ratio, -
% Additional
par.m_f      = par.mass * par.l_r / par.L;      % front sprung mass, kg
par.m_r      = par.mass * par.l_f / par.L;      % rear sprung mass, kg
par.mu       = 1;                   % friction coefficient, -
%% Tunable parameters
% Reference Generator
par.Calpha_front = 120000;          % front axle cornering stiffness
par.Calpha_rear  = 190000;          % rear axle cornering stiffness
par.Kus = par.m_f/par.Calpha_front - par.m_r/par.Calpha_rear; % understeer gradient
% second order TF identified from Sine Swept Test
par.wn      = 11;                   % yaw rate frequency
par.kseta   = 0.7;                  % yaw rate damping
par.tau     = 0.09;                 % yaw rate time constant

%% Add/ Change after this line
% Maneuver settings
%V_ref = 60 /3.6;                % pre-maneuver speed, km/h
V_ref = 100/3.6;                % pre-maneuver speed, km/h

%% Generate LQR Gains
n_points = 20; % number of data points
par.LQR_Vx_ref = linspace(60,100,n_points)/3.6; % longitudinal speed in m/s

% zero initialization
par.LQR_K = zeros(n_points, 2); % Make sure it's n_points x 2, since K is 1x2
    
for i = 1:length(par.LQR_Vx_ref)

    Vx = par.LQR_Vx_ref(i);

    % Linearized A matrix
    % Initalizing the matrices
    A = zeros(2,2);
    B = zeros(2,1);
    
    % setting the values of the matrices
    A(1,1) = -1*(par.Calpha_front + par.Calpha_rear)/(par.mass*V_ref);
    A(1,2) = (-par.l_f*par.Calpha_front + par.l_r*par.Calpha_rear)/(par.mass*V_ref)-V_ref;
    A(2,1) = (par.l_r*par.Calpha_rear - par.l_f*par.Calpha_front)/(par.Izz*V_ref);
    A(2,2) = -1*((par.l_f^2)*par.Calpha_front + (par.l_r^2)*par.Calpha_rear)/(par.Izz*V_ref);
    B = [par.Calpha_front/par.mass; par.l_f*par.Calpha_front/par.Izz];

    % LQR Weights
    Q = 8000 * diag([10  % Penalize lateral velocity
                  0.1]); % Penalize steering wheel angle
    R = Vx;        % Penalize input, the higher velocity, the harder we penalize

    % Solve LQR
    par.K = lqr(A, B, Q, R);   % 1x2 gain

    % Store
    par.LQR_K(i,:) = par.K;
end



%% Model run
sim('HW02_template')

%% Postprocessing
FontSize = 14;
LineWidth = 2;       % Thicker lines
LegendFontSize = 14; % Bigger legend text
start_SwD = 6;

%% figure

% First subplot: Longitudinal velocity
subplot(1,2,1)
set(gca, 'Color', [0.94 0.94 0.94], ...       % light gray background
         'GridColor', [1 1 1], ...            % white grid
         'GridAlpha', 1, ...                  % full grid opacity
         'LineWidth', 1.0, ...
         'Box', 'off')                        % remove border box
grid on

hold all
plot(time(time > start_SwD), long_velocity(time > start_SwD), '-k', 'LineWidth', LineWidth) % black line
xlabel('Time [s]')
ylabel('Long velocity [m/s]')
set(gca, 'FontSize', FontSize)

% Second subplot: Yaw rate and reference
yaw_rate_ref_time = yaw_rate_ref.Time;
yaw_rate_ref_data = yaw_rate_ref.Data;
yaw_rate_ref_interp = interp1(yaw_rate_ref_time, yaw_rate_ref_data, time);

subplot(1,2,2)
set(gca, 'Color', [0.94 0.94 0.94], ...       % light gray background
         'GridColor', [1 1 1], ...            % white grid
         'GridAlpha', 1, ...                  % full grid opacity
         'LineWidth', 1.0, ...
         'Box', 'off')                        % remove border box

hold all

plot(time(time > start_SwD), yaw_rate(time > start_SwD), ...
     '-', 'Color', [0 0.4470 0.7410], 'LineWidth', 2.5, 'DisplayName', 'Measured Yaw Rate');

plot(time(time > start_SwD), yaw_rate_ref_interp(time > start_SwD), ...
     '--', 'Color', [0.8500 0.3250 0.0980], 'LineWidth', 2.5, 'DisplayName', 'Reference Yaw Rate');

% Styling
xlabel('Time [s]', 'FontSize', FontSize)
ylabel('Yaw rate [rad/s]', 'FontSize', FontSize)
title('Yaw Rate Tracking', 'FontSize', FontSize)
legend('show', 'FontSize', LegendFontSize)

% Clean grid + background
set(gca, 'Color', [0.94 0.94 0.94], ...
         'GridColor', [1 1 1], ...
         'GridAlpha', 1, ...
         'Box', 'off', ...
         'FontSize', FontSize)
grid on

% Truncate to region of interest (after maneuver starts)
t_roi = time(time > start_SwD);
yaw_measured = yaw_rate(time > start_SwD);
yaw_expected = yaw_rate_ref_interp(time > start_SwD);

% Calculate the absolute area between the two yaw rate curves (numerator)
area_diff = trapz(t_roi, abs(yaw_measured - yaw_expected));

% Calculate the area under the expected yaw rate curve (denominator)
area_expected = trapz(t_roi, abs(yaw_expected));

% Metric: ratio of areas
yaw_metric = area_diff / area_expected;

% Display the result
fprintf('Yaw Velocity Metric = %.3f\n', yaw_metric);

