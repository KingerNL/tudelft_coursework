TNO_Veh_PARAM.GroundCrossSection = [-5 -2; 110 -2; 110 80; -5 80]; %4-coordinates in m
TNO_Veh_PARAM.GroundLength = 0.05; %m
TNO_Veh_PARAM.GroundHeight = 0.1; %m

TNO_Veh_PARAM.Body.Length = 3;   % m
TNO_Veh_PARAM.Body.Width  = 1;   % m
TNO_Veh_PARAM.Body.Height = 0.55; % m
% TNO_Veh_PARAM.Body.LWH = [TNO_Veh_PARAM.Body.Length TNO_Veh_PARAM.Body.Width TNO_Veh_PARAM.Body.Height];
TNO_Veh_PARAM.Body.LWH = [0.1 0.1 0.1]; % for representation of CG location
% TNO_Veh_PARAM.Body.GraphicsShift = [-2.3 0.975 -0.5]; % (m) %for shifting the graphics file onto CG
% TNO_Veh_PARAM.Body.GraphicsShift = [-0.975-0.1 2.75 -0.85]; % (m) %for shifting the graphics file onto CG
TNO_Veh_PARAM.Body.GraphicsShift = [-0.9750-0.01 2.75 -0.85]; % (m) FROM STEVE
TNO_Veh_PARAM.Body.Mass = 1600;  % kg
TNO_Veh_PARAM.Body.Inertias = [600 3000 3200]; % kg*m^2

TNO_Veh_PARAM.Suspension.FA.Heave.Stiffness = 40000; % N/m
TNO_Veh_PARAM.Suspension.FA.Heave.Damping = 3500; % N/m
TNO_Veh_PARAM.Suspension.FA.Heave.EqPos = -0.2; % m
TNO_Veh_PARAM.Suspension.FA.Heave.Height = 0.45; % m

TNO_Veh_PARAM.Suspension.FA.Roll.Stiffness = 66000; % N*m/rad
TNO_Veh_PARAM.Suspension.FA.Roll.Damping = 2050; % N*m/(rad/s)
TNO_Veh_PARAM.Suspension.FA.Roll.Height = 0.1; % m

TNO_Veh_PARAM.Suspension.RA.Heave.Stiffness = 50000; % N/m
TNO_Veh_PARAM.Suspension.RA.Heave.Damping = 3500; % N/m
TNO_Veh_PARAM.Suspension.RA.Heave.EqPos = -0.16; % m
TNO_Veh_PARAM.Suspension.RA.Heave.Height = 0.45; % m

TNO_Veh_PARAM.Suspension.RA.Roll.Stiffness = 27500; % N*m/rad
TNO_Veh_PARAM.Suspension.RA.Roll.Damping = 2050; % N*m/(rad/s)
TNO_Veh_PARAM.Suspension.RA.Roll.Height = 0.05; % m

TNO_Veh_PARAM.Axle_Housing.Radius = 0.01; % m
TNO_Veh_PARAM.Axle_Housing.Length = 0.01; % m

TNO_Veh_PARAM.WheelBase = 1.6; %m

TNO_Veh_PARAM.Axle.FA.Length = 1.6; % m
TNO_Veh_PARAM.Axle.FA.Radius = 0.1; % m
TNO_Veh_PARAM.Axle.FA.Mass = 95; % kg
TNO_Veh_PARAM.Axle.FA.Inertia = [1 1 1]; % kg*m^2
%TNO_Veh_PARAM.Axle.FA.Height = 0.275; %m
TNO_Veh_PARAM.Axle.FA.Height = 0.2908; %m
%hFA = 0.2908;

TNO_Veh_PARAM.Axle.RA.Length = 1.6; % m
TNO_Veh_PARAM.Axle.RA.Radius = 0.1; % m
TNO_Veh_PARAM.Axle.RA.Mass = 90; % kg
TNO_Veh_PARAM.Axle.RA.Inertia = [1 1 1]; % kg*m^2
%TNO_Veh_PARAM.Axle.RA.Height = 0.225; %m
TNO_Veh_PARAM.Axle.RA.Height = 0.2909-0.05; %m
%hRA = 0.2909;

TNO_Veh_PARAM.Hub.Radius = 0.01; % m
TNO_Veh_PARAM.Hub.Length = 0.01; % m

TNO_Veh_PARAM.Steer.Kp = 1e6; % m
TNO_Veh_PARAM.Steer.Ki = 1e3; % m

TNO_Veh_PARAM.InitVel.LF = 66; %rad/s
TNO_Veh_PARAM.InitVel.RF = 66; %rad/s
TNO_Veh_PARAM.InitVel.LR = 66; %rad/s
TNO_Veh_PARAM.InitVel.RR = 66; %rad/s
TNO_Veh_PARAM.InitVel.Vehicle = 20; %m/s

Extr_Data_RDF

% SINE WITH DWELL
tswd0=3;
tswd=0:0.01:10;

dwell=0.5;
Aswd=116*pi/180;
fswd=0.7;
is = 16;

delta=Aswd*(sin(2*pi*fswd*(tswd-tswd0)).*(tswd>=tswd0 & tswd<=(tswd0+3/4*1/fswd)) + ...
    -1.*(tswd>(tswd0+3/4*1/fswd) & tswd<(tswd0+dwell+3/4*1/fswd))+ ...
    sin(2*pi*fswd*(tswd-tswd0-dwell)).*(tswd>=(tswd0+dwell+3/4*1/fswd) & tswd<=(tswd0+dwell+1/fswd)));


% PARKING
is = 16;
tparking = [0  1    3     6       9    10 11 14 ];
angparking  = [0  0 400 400 -210 -210   0   0]*pi/180;
tvxset = [0 4 5    6 7    8 9 10 14];
vxset =  [0 0 1 3.5 5 5.5 6  8  30]/3.6;
tend = tparking(end);
