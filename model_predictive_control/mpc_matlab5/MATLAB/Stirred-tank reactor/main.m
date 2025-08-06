%% ?Offset-free linear MPC of a stirred-tank reactor

clear all
close all
clc
%% Parameters and stuffs

global F F0 r E k0 DeltaH rhoCp T0 c0 U Tc hs

% Parameters and sizes for the nonlinear system
sampling_time = 1;
n_state = 3;
n_input = 2;
nmeas = n_state;
n_disturbance = 1;

% Introduce the nominal values
F0 = 0.1;
T0 = 350;
c0 =  1; 
r  = 0.219;
k0 = 7.2e10;
E  =  8750;
U  =  54.94;
rho = 1e3;
Cp  = 0.239;
DeltaH = -5e4;

rhoCp = rho*Cp;

% Equilibrium
cs = 0.8778;
hs = 0.659;
Ts = 324.4966;

Tcs = 300;
Fs = F0;

zs = [cs; Ts; hs];


% Set the disturbance
ps = 0.1*F0;


%% Linearize and discretize the model
G = partial(zs);
Ac =  G(:,1:n_state);
Bc = G(:,n_state+1:n_state+2);
Bpc = G(:,n_state+3:end);
C = eye(n_state);

sys = ss(Ac, [Bc, Bpc], C, zeros(size(C,1),size([Bc, Bpc],2)));

% Discretize
dsys = c2d(sys, sampling_time);
A = dsys.a;
B = dsys.b(:,1:n_input);
Bp = dsys.b(:,n_input+1:end);

% Compute LQR
Q = diag(1./zs.^2);
R = diag(1./[Tcs; Fs].^2);
[K, P] = dlqr(A, B, Q, R);
K = -K;

% Pick whether to use good disturbance model.
useGoodDisturbanceModel = ~true();

if useGoodDisturbanceModel
    
    % Disturbance model 6; no offset
    nd = 3;
    Bd = zeros(n_state, nd);
    Bd(:,3) = B(:,2);
    Cd = [1 0 0; 0 0 0; 0 1 0];
else
    
    % Disturbance model with offset
    nd = 2;
    Bd = zeros(n_state, nd);
    Cd = [1 0; 0 0; 0 1];
end

% Set the augmented system
Aaug = [A, Bd; zeros(nd, n_state), eye(nd)];
Baug = [B; zeros(nd, n_input)];
Caug = [C, Cd];
naug = size(Aaug,1);

% Detectability test of disturbance model
detec = rank([eye(n_state+nd) - Aaug; Caug]);
if detec < (n_state + nd)
  warning ('augmented system is not detectable\n')
end

% Find the gain of a Luenberger observer
if useGoodDisturbanceModel
    eigenplace = [0.5437 + 0.9125i, 0.5437 - 0.9125i, -0.3122, 0.1263, 0.5485, 0.6854];
    L = place(Aaug',Caug',eigenplace)';
    Lx = L(1:n_state,:);
    Ld = L(n_state+1:end,:);
else
    eigenplace = [-0.3188, 0.6763, 0.3933 + 0.1810i, 0.3933 - 0.1810i, 0];
    L = place(Aaug',Caug',eigenplace)';
    Lx = L(1:n_state,:);
    Ld = L(n_state+1:end,:);
end

%% Simulations
ntimes = 50;
x0 = zeros(n_state, 1);
x = zeros(n_state, ntimes);
x(:, 1) = x0;
y = zeros(nmeas, ntimes);
u = zeros(n_input, ntimes);
randn('seed', 0);
v = zeros(nmeas, ntimes);
xhat_ = zeros(n_state, ntimes);
dhat_ = zeros(nd, ntimes);
xhat = xhat_;
dhat = dhat_;
time = (0:ntimes-1)*sampling_time;
xs = zeros(n_state, ntimes);
us = zeros(n_input, ntimes);
ys = zeros(nmeas, ntimes);
etas = zeros(nmeas, ntimes);
options = [];

% Disturbance and setpoint.
p = [zeros(n_disturbance, 10), ps*ones(n_disturbance, ntimes-10)];
yset = zeros(nmeas,1);

% Steady-state target matrices.
H  = [1 0 0; 0 0 1];
Ginv = inv([eye(n_state)-A, -B; H*C, zeros(size(H,1), n_input)]);

for i = 1: ntimes
    % Measurement
    y(:,i) = C*x(:,i) + v(:,i);
    
    % state estimate
    ey = y(:,i) - C*xhat_(:,i) -Cd*dhat_(:,i);
    xhat(:,i) = xhat_(:,i) + Lx*ey;
    dhat(:,i) = dhat_(:,i) + Ld*ey;
    
    % Stop if at last time.
    if i == ntimes
        break
    end
    
    % target selector
    tmodel.p = dhat(:,i);
    
    qs = Ginv*[Bd*dhat(:,i); H*(yset-Cd*dhat(:,i))];
    xss = qs(1:n_state); 
    uss = qs(n_state+1:end);
    xs(:,i) = xss;
    us(:,i) = uss;
    ys(:,i) = C*xss + Cd*dhat(:,i);
    
    % Implment LQR
    x0 = xhat(:,i) - xs(:,i);
    u(:,i) = K*x0 + us(:,i);

    % Plant evolution
    t = [time(i); mean(time(i:i+1)); time(i+1)];
    z0 = x(:,i) + zs;
    Tc = u(1,i) + Tcs;
    F  = u(2,i) + Fs;
    F0 = p(:,i) + Fs;

    [tout, z] = ode15s(@massenbal, t, z0, options);

    if sum(tout ~= t)
        warning('integrator failed!')
    end
    x(:,i+1) = z(end,:)' - zs;
    
    % Advance state estimates
    xhat_(:,i+1) = A*xhat(:,i) + ...
        Bd*dhat(:,i) + B*u(:,i);
    dhat_(:,i+1) = dhat(:,i);
end
u(:,end) = u(:,end-1); % Repeat for stair plot.


% Dimensional units
yd = y + kron(ones(1, ntimes), zs);
ud = u + kron(ones(1, ntimes), [Tcs; Fs]);

%% Plots
figure(),

subplot(3,2,1)
plot(time, yd(1,:), '-or'), grid on
ylabel('c (kmol/m^3)')

subplot(3,2,3)
plot(time, yd(2,:), '-or'), grid on
ylabel('T (K)')

subplot(3,2,5)
plot(time, yd(3,:), '-or'), grid on
ylabel('h (m)')
xlabel('Time')

subplot(3,2,2)
stairs(time, ud(1,:), '-r'), grid on
ylabel('Tc (K)')

subplot(3,2,4)
stairs(time, ud(2,:), '-r'), grid on
ylabel('F (m^3/min)')
xlabel('Time')

