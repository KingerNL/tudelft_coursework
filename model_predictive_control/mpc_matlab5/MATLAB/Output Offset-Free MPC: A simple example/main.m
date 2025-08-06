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

LTI.Cd=diag([0.5 2]);

LTI.Bd=[1 0.5; 0.4 0; 0 1];
              
LTI.x0=[0.01; -100; 0.1];
LTI.d=[0.1; 1];
LTI.yref=[0.8780; 0.6590];

%Definition of system dimension
dim.nx=3;     %state dimension
dim.nu=2;     %input dimension
dim.ny=2;     %output dimension
dim.nd=2;     %disturbance dimension
dim.N=5;      %horizon

%Definition of quadratic cost function
weight.Q=[1 0 0; 0 2 0; 0 0 3];                %weight on output
weight.R=eye(dim.nu);                          %weight on input
weight.P=dare(LTI.A,LTI.B,weight.Q,weight.R);  %terminal cost

T=30;     %simulation horizon

%% Check if the problem is well posed
rank([eye(dim.nx)-LTI.A -LTI.Bd; LTI.C LTI.Cd]);

%% Extended system computation

LTIe.A=[LTI.A LTI.Bd; zeros(dim.nd,dim.nx) eye(dim.nd)];
LTIe.B=[LTI.B; zeros(dim.nd,dim.nu)];
LTIe.C=[LTI.C LTI.Cd];
LTIe.x0=[LTI.x0; LTI.d];
LTIe.yref=LTI.yref;

%Definition of system dimension
dime.nx=5;     %state dimension
dime.nu=2;     %input dimension
dime.ny=2;     %output dimension
dime.N=5;      %horizon


%Definition of quadratic cost function
weighte.Q=blkdiag(weight.Q,zeros(dim.nd));            %weight on output
weighte.R=weight.R;                                   %weight on input
weighte.P=blkdiag(weight.P,zeros(dim.nd));            %terminal cost

%% Non offset-free MPC assuming state and disturbance knowledge
%{

predmod=predmodgen(LTI,dim);  
[H,h]=costgen(predmod,weight,dim); 

% Receding horizon implementation
x=zeros(dim.nx,T+1);
y=zeros(dim.ny,T+1);
u_rec=zeros(dim.nu,T);

x(:,1)=LTI.x0;
y(:,1)=LTI.C*LTI.x0+LTI.d;

%Compute optimal ss (only once, since the disturbance is known)
eqconstraints=eqconstraintsgen(LTI,dim,zeros(dim.nd,1));
[xr,ur]=optimalss(LTI,dim,weight,[],eqconstraints); 

for k=1:T
    
    x_0=x(:,k);  
    
    uostar = sdpvar(dim.nu*dim.N,1);                               %define optimization variable
    Constraint=[];                                                 %define constraints
    Objective = 0.5*uostar'*H*uostar+(h*[x_0; xr; ur])'*uostar;    %define cost function
    optimize(Constraint,Objective);                                %solve the problem
    uostar=value(uostar);      

    % Select the first input only
    u_rec(:,k)=uostar(1:dim.nu);

    % Compute the state/output evolution
    x(:,k+1)=LTI.A*x_0 + LTI.B*u_rec(:,k)+LTI.Bd*LTI.d;
    y(:,k+1)=LTI.C*x(:,k+1)+LTI.Cd*LTI.d;
    clear u_uncon
    
end

%}

%% Offset-free MPC assuming state and disturbance knowledge
%{

predmode=predmodgen(LTIe,dime);  
[He,he]=costgen(predmode,weighte,dime); 

% Receding horizon implementation
xe=zeros(dime.nx,T+1);
y=zeros(dime.ny,T+1);
u_rec=zeros(dime.nu,T);

xe(:,1)=LTIe.x0;
y(:,1)=LTIe.C*LTIe.x0;

%Compute optimal ss (only once, since the disturbance is known)
eqconstraints=eqconstraintsgen(LTI,dim,LTI.d);
[xr,ur]=optimalss(LTI,dim,weight,[],eqconstraints); 
xre=[xr; LTI.d];

for k=1:T
    
    xe_0=xe(:,k);  
    
    uostar = sdpvar(dime.nu*dime.N,1);                                 %define optimization variable
    Constraint=[];                                                     %define constraints
    Objective = 0.5*uostar'*He*uostar+(he*[xe_0; xre; ur])'*uostar;    %define cost function
    optimize(Constraint,Objective);                                    %solve the problem
    uostar=value(uostar);      

    % Select the first input only
    u_rec(:,k)=uostar(1:dim.nu);

    % Compute the state/output evolution
    xe(:,k+1)=LTIe.A*xe_0 + LTIe.B*u_rec(:,k);
    y(:,k+1)=LTIe.C*xe(:,k+1);
    clear u_uncon
    
end

%}

%% Offset-free MPC from output

predmode=predmodgen(LTIe,dime);  
[He,he]=costgen(predmode,weighte,dime); 

% Receding horizon implementation
xe=zeros(dime.nx,T+1);
y=zeros(dime.ny,T+1);
u_rec=zeros(dime.nu,T);
xehat=zeros(dime.nx,T+1);

xe(:,1)=LTIe.x0;
xehat(:,1)=[0; 90; 0; 0; 0];
y(:,1)=LTIe.C*LTIe.x0;

L=place(LTIe.A',LTIe.C',[0.5; 0.4; 0.45;0.6;0.65])';      %observer gain

for k=1:T
    
    xe_0=xe(:,k);  
    dhat=xehat(end-dim.nd+1:end,k);
    
    %Compute optimal ss (online, at every iteration)
    eqconstraints=eqconstraintsgen(LTI,dim,dhat);
    [xr,ur]=optimalss(LTI,dim,weight,[],eqconstraints); 
    xre=[xr;dhat];
    
    uostar = sdpvar(dime.nu*dime.N,1);                                 %define optimization variable
    Constraint=[];                                                     %define constraints
    Objective = 0.5*uostar'*He*uostar+(he*[xe_0; xre; ur])'*uostar;    %define cost function
    optimize(Constraint,Objective);                                    %solve the problem
    uostar=value(uostar);      

    % Select the first input only
    u_rec(:,k)=uostar(1:dim.nu);

    % Compute the state/output evolution
    xe(:,k+1)=LTIe.A*xe_0 + LTIe.B*u_rec(:,k);
    y(:,k+1)=LTIe.C*xe(:,k+1);
    clear u_uncon
        
    % Update extended-state estimation
    xehat(:,k+1)=LTIe.A*xehat(:,k)+LTIe.B*u_rec(:,k)+L*(y(:,k)-LTIe.C*xehat(:,k));
    
end

%}

%% Plots

e=y-kron(ones(1,T+1),LTI.yref);
figure
plot(0:T,e),
xlabel('k'), ylabel('Tracking error'), grid on;
legend('e_1','e_2');
