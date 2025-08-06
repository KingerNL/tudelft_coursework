LineStyle = 'r';
FntSz = 12;
subplot(211)
plot(tout,velacc(:,8),LineStyle,'LineWidth',2);
title('Lateral Acc. (m/s^2)','FontWeight','Bold','FontSize',FntSz)
%xlabel('Time (s)')
ylabel('Lat. Acc. (m/s^2)')

subplot(212)
plot(tout,velacc(:,6),LineStyle,'LineWidth',2);
title('Yaw Velocity (deg/s)','FontWeight','Bold','FontSize',FntSz);
xlabel('Time (s)')
ylabel('Yaw Vel. (deg/s)')
