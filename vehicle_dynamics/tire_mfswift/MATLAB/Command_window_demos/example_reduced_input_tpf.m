function example_reduced_input_tpf()
% Demo that shows the estimation capabilities of MF-Tyre
% As is described in the User Manual in the section 'Reduced Input Data
% Requirements', the tyre model is able to make estimates of parameters if
% these are not specified in the tyre property file.

% Three tyre property files are considered:
% 1) A fully identified parameter set TNO_car205_60R15.tir
% 2) A minimum recommended reduced input file TNO_car205_60R15_reduced_input.tir 


%% Get tyre characteristics for different tyre property files

filnam = 'TNO_car205_60R15.tir';
t1=tyrechar(filnam);

filnam = 'TNO_car205_60R15_reduced_input.tir';
t2=tyrechar(filnam);

%% Make some figures to comapre results

% Get pointers
varinf_ptr = tno_varinf_ptr();

% Longitudinal slip
figure
plot(t1.Fx_forces(t1.idx_plot,:,varinf_ptr.KAPSTS)',t1.Fx_forces(t1.idx_plot,:,varinf_ptr.FXC)','linewidth',2);
hold on
plot(t2.Fx_forces(t2.idx_plot,:,varinf_ptr.KAPSTS)',t2.Fx_forces(t2.idx_plot,:,varinf_ptr.FXC)','--');
xlabel('\kappa [-]')
ylabel('Fx [N]')
title('Fx pure; ''-'' full tpf, ''--'' reduced tpf')
grid
legend('0.5*FNOMIN','FNOMIN','1.5*FNOMIN')

% Lateral 
figure
plot(180/pi*t1.Fy_forces(t1.idx_plot,:,varinf_ptr.ALPSTS)',t1.Fy_forces(t1.idx_plot,:,varinf_ptr.FYC)','linewidth',2);
hold on
plot(180/pi*t2.Fy_forces(t2.idx_plot,:,varinf_ptr.ALPSTS)',t2.Fy_forces(t2.idx_plot,:,varinf_ptr.FYC)','--');
xlabel('\alpha [deg]')
ylabel('Fy [N]')
title('Fy pure; ''-'' full tpf, ''--'' reduced tpf')
grid
legend('0.5*FNOMIN','FNOMIN','1.5*FNOMIN')

% Combined slip
figure
plot(t1.Fc_forces(:,:,1)',t1.Fc_forces(:,:,2)','linewidth',2);
hold on;
plot(t2.Fc_forces(:,:,1)',t2.Fc_forces(:,:,2)','--');
xlabel('Fx [N]')
ylabel('Fy [N]')
axis equal
grid
title('combined slip at FNOMIN; ''-'' full tpf, ''--'' reduced tpf, ''..'' reduced tpf')

end

function [s]=tyrechar(tpfname)

% Get pointers
varinf_ptr = tno_varinf_ptr();

% Define vertical load ranges
typarr_struct = tno_tir2struct(tpfname);
Fznom=typarr_struct.VERTICAL.FNOMIN;
Fzmax=typarr_struct.VERTICAL_FORCE_RANGE.FZMAX;
Fz      = Fznom*(0.1:0.1:2);
if Fzmax>Fz(end), Fz = [Fz Fzmax]; end
Fz_plot = Fznom*[0.5 1 1.5];
Fz      = unique(sort(Fz));

for k=1:length(Fz_plot)
    idx_plot(k) = find( Fz==Fz_plot(k) );
end

%% Longitudinal slip

kappa    = [-1:0.005:1]';
alpha    = 0*kappa;
camber   = 0*ones(size(alpha));
turnslip = 0*ones(size(alpha));
Vx       = 10+0*ones(size(alpha));

for i=1:length(Fz)
  Fztyre=Fz(i)*ones(size(alpha));
  Fx_forces(i,:,:)=dteval(tpfname,[Fztyre kappa alpha camber turnslip Vx],4);
end

%% Lateral (zero camber)

alpha   =pi/180*[-20:0.1:20]';
kappa   =0*ones(size(alpha));
camber  =0*ones(size(alpha));
turnslip=0*ones(size(alpha));
Vx      =10+0*ones(size(alpha));

for i=1:length(Fz)
  Fztyre=Fz(i)*ones(size(alpha));
  Fy_forces(i,:,:)=dteval(tpfname,[Fztyre kappa alpha camber turnslip Vx],4);
end

%% Combined slip

alp      = pi/180*[-8 -6 -4 -2 -1 0 1 2 4 6 8];
kappa    = [-1:0.005:1]';
camber   = 0*ones(size(kappa));
turnslip = 0*ones(size(kappa));
Vx       = 10+0*ones(size(kappa));
Fztyre   = 0*ones(size(kappa))+Fznom;

for i=1:length(alp)
  alpha= alp(i)*ones(size(kappa));
  Fc_forces(i,:,:)=dteval(tpfname,[Fztyre kappa alpha camber turnslip Vx],4);
end

%% Output in structure

s.Fx_forces = Fx_forces;
s.Fy_forces = Fy_forces;
s.Fc_forces = Fc_forces;
s.idx_plot = idx_plot;

end
