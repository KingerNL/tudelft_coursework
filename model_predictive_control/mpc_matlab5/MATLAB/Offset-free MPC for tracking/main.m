clear all
clc
close all

%% Data

%LTI system definition

LTI.A=[  0.2698  -0.0033   -0.007
         9.698    0.3276   -25.43 
         0        0         1.000];
               
LTI.B=[  -0.0053   0.1655
         1.296     97.89
         0        -6.636];
               
LTI.C=[1 0 0; 0 0 1];

LTI.Cd=eye(2);

LTI.yref=[0.8780; 0.6590];
               
LTI.x0=[0.01; -100; 0.1];

LTI.d=[0.1; 1];

%Definition of system dimension
dim.nx=3;     %state dimension
dim.nu=2;     %input dimension
dim.ny=2;     %output dimension
dim.nd=2;     %disturbance dimension
dim.N=3;      %horizon

%Definition of quadratic cost function
weight.Q=[1 0 0; 0 2 0; 0 0 3];                %weight on output
weight.R=eye(dim.nu);                          %weight on input
weight.P=dare(LTI.A,LTI.B,weight.Q,weight.R);  %terminal cost

T=30;     %simulation horizon

%% Offset-free MPC
% %{

predmod=predmodgen(LTI,dim);  
[H,h]=costgen(predmod,weight,dim); 
L=[0.5 0; 0 0.5];                   %observer gain

% Receding horizon implementation
x=zeros(dim.nx,T+1);
u_rec=zeros(dim.nu,T);
dhat=zeros(dim.nd,T+1);

x(:,1)=LTI.x0;
dhat(:,1)=[0;0];

for k=1:T
    
    %Compute estimated optimal ss
    eqconstraints=eqconstraintsgen(LTI,dim,dhat(:,k));
    [xr,ur]=optimalss(LTI,dim,weight,[],eqconstraints); 
    
    x_0=x(:,k);
     
    
    %Solve optimization problem    
    uostar = sdpvar(dim.nu*dim.N,1);                               %define optimization variable
    Constraint=[];                                                 %define constraints
    Objective = 0.5*uostar'*H*uostar+(h*[x_0; xr; ur])'*uostar;    %define cost function
    optimize(Constraint,Objective);                                %solve the problem
    uostar=value(uostar);      

    % Select the first input only
    u_rec(:,k)=uostar(1:dim.nu);

    % Compute the state/output evolution
    x(:,k+1)=LTI.A*x_0 + LTI.B*u_rec(:,k);
    y=LTI.C*x(:,k+1)+LTI.Cd*LTI.d+0.01*randn(dim.ny,1);
    clear u_uncon
    
    % Update disturbance estimation
    dhat(:,k+1)=dhat(:,k)+L*(y-LTI.C*x(:,k+1)-dhat(:,k));
 
end

%}


%% Plots

e=y-kron(ones(1,T+1),LTI.yref);
figure
plot(0:T,e),
xlabel('k'), ylabel('Tracking error'), grid on;
legend('e_1','e_2');

