% close all;clear all;clc;clear mex


% Cleat test conditions
rdfname = 'TNO_PlankRoad_2D.rdf';
Fztyre  = 4000;
Vx      = 40/3.6;
RIMROTIN= 0.253;
TRGROTIN= 0.049;

% Full tyre property file
tpfname = 'TNO_car205_60R15.tir';

varinf_ptr = tno_varinf_ptr();
typarr_struct = tno_tir2struct(tpfname);
[varinf,typarr] = dteval(tpfname,[Fztyre 0 0 0 0 Vx],4);
axle_z =  typarr_struct.VERTICAL.Q_RE0*typarr_struct.DIMENSION.UNLOADED_RADIUS - varinf(varinf_ptr.IDEFL);
Omega0 = Vx/varinf(varinf_ptr.IREF);
BELT_IYY = typarr(162);
IYY = typarr(192);
IYY_wheel = IYY-BELT_IYY+RIMROTIN+TRGROTIN;

sim test_delfttyre_sti_cleat.mdl 

figure;
subplot(2,1,1);
plot(time,force(:,3));
xlim([0.1 0.3])
hold all;
xlabel('t [s]'),ylabel('Fz [N]')
subplot(2,1,2);
plot(time,force(:,1));
xlim([0.1 0.3])
hold all;
xlabel('t [s]'),ylabel('Fx [N]')


% Reduced tyre property file
tpfname = 'TNO_car205_60R15_reduced_input.tir';

varinf_ptr = tno_varinf_ptr();
typarr_struct = tno_tir2struct(tpfname);
[varinf,typarr] = dteval(tpfname,[Fztyre 0 0 0 0 0],4);
axle_z =  typarr_struct.DIMENSION.UNLOADED_RADIUS - varinf(varinf_ptr.IDEFL);
Omega0 = Vx/varinf(varinf_ptr.IREF);
BELT_IYY = typarr(162);
IYY = typarr(192);
IYY_wheel = IYY-BELT_IYY+RIMROTIN+TRGROTIN;

sim test_delfttyre_sti_cleat.mdl 

subplot(2,1,1);
plot(time,force(:,3));
legend('full tir','reduced tir');
title('Reduced input cleat test example')
subplot(2,1,2);
plot(time,force(:,1));
legend('full tir','reduced tir');