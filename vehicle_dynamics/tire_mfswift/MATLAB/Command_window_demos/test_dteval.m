function []=test_dteval

filnam  ='TNO_car205_60R15.tir';

alpha   =pi/180*[-15:0.1:15]';
kappa   =0*ones(size(alpha));
camber  =0*ones(size(alpha));
Fz      =[1000:1000:4000];
turnslip=0*ones(size(alpha));
Vx      =10+0*ones(size(alpha));

for i=1:length(Fz)
  Fztyre=Fz(i)*ones(size(alpha));
  forces(i,:,:)=dteval(filnam,[Fztyre kappa alpha camber turnslip Vx],4);
end

plot(alpha*180/pi,1e-3*forces(:,:,2));
title('car tyre 205/60R15')
xlabel('side slip angle alpha [deg.]');
ylabel('lateral force Fy [kN]');
legend('Fz = 1 kN','Fz = 2 kN','Fz = 3 kN','Fz = 4 kN');
grid

%print -deps alpha_sweep
