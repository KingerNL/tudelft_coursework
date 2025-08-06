function Configure_TNO_Tire_Test(tire_test)
%tire_test = 'handling';
%tire_test = '4poster';
%tire_test = 'ride';
%tire_test = 'sinewithdwell';
%tire_test = 'parking';

%open_system('test_simmechanics_all_2G');

ri_bpth = find_system(bdroot,'Regexp','on','Name','Road Input','OverrideUsingVariant','.');
TNOblk_pth = find_system(bdroot,'Regexp','on','cnt_mode','.');

if (strcmp(tire_test,'handling'))
    % SET ROAD INPUT VARIANT
    for i = 1:length(ri_bpth)
        set_param(char(ri_bpth(i)),'OverrideUsingVariant','NonMoving');
    end
    set_param([bdroot '/World/Road'],'OverrideUsingVariant','NoRoad');
    % SET STEERING INPUT VARIANT
    set_param([bdroot '/Steering Input'],'OverrideUsingVariant','StepSteer');
    % SETTINGS FOR MF-TYRE
    for i = 1:length(TNOblk_pth)
        set_param(char(TNOblk_pth(i)),'cnt_mode','(x1xx) smooth road');
        set_param(char(TNOblk_pth(i)),'dyn_mode','(xx0x) steady-state');
        set_param(char(TNOblk_pth(i)),'mf_mode','(xxx4) combined');
        set_param(char(TNOblk_pth(i)),'rdfname','which(''TNO_FlatRoad.rdf'')');
    end
    % SET INITIAL STATES FOR WHEELS AND CAR
    evalin('base','TNO_Veh_PARAM.InitVel.LF = 66;'); %rad/s
    evalin('base','TNO_Veh_PARAM.InitVel.RF = 66;'); %rad/s
    evalin('base','TNO_Veh_PARAM.InitVel.LR = 66;'); %rad/s
    evalin('base','TNO_Veh_PARAM.InitVel.RR = 66;'); %rad/s
    evalin('base','TNO_Veh_PARAM.InitVel.Vehicle = 20;'); %m/s
    % SET DRIVE VARIANT
    set_param([bdroot '/6-DOF Joint'],'PxTorqueActuationMode','InputTorque');
    set_param([bdroot '/6-DOF Joint'],'PxMotionActuationMode','ComputedMotion');
    set_param([bdroot '/Drive/Enable Motion'],'Gain','0');
    % SET SOLVER
    set_param(bdroot,'Solver','ode15s');
elseif (strcmp(tire_test,'4poster'))
    % SET ROAD INPUT VARIANT
    for i = 1:length(ri_bpth)
        set_param(char(ri_bpth(i)),'OverrideUsingVariant','TestRigPost');
    end
    set_param([bdroot '/World/Road'],'OverrideUsingVariant','NoRoad');
    % SET STEERING INPUT VARIANT
    set_param([bdroot '/Steering Input'],'OverrideUsingVariant','NoSteer');
    % SETTINGS FOR MF-TYRE
    for i = 1:length(TNOblk_pth)
        set_param(char(TNOblk_pth(i)),'cnt_mode','(x3xx) moving road');
        set_param(char(TNOblk_pth(i)),'dyn_mode','(xx0x) steady-state');
        set_param(char(TNOblk_pth(i)),'mf_mode','(xxx4) combined');
        set_param(char(TNOblk_pth(i)),'rdfname','which(''TNO_FlatRoad.rdf'')');
    end
    % SET INITIAL STATES FOR WHEELS AND CAR
    evalin('base','TNO_Veh_PARAM.InitVel.LF = 0;'); %rad/s
    evalin('base','TNO_Veh_PARAM.InitVel.RF = 0;'); %rad/s
    evalin('base','TNO_Veh_PARAM.InitVel.LR = 0;'); %rad/s
    evalin('base','TNO_Veh_PARAM.InitVel.RR = 0;'); %rad/s
    evalin('base','TNO_Veh_PARAM.InitVel.Vehicle = 0;'); %m/s
    % SET DRIVE VARIANT
    set_param([bdroot '/6-DOF Joint'],'PxTorqueActuationMode','InputTorque');
    set_param([bdroot '/6-DOF Joint'],'PxMotionActuationMode','ComputedMotion');
    set_param([bdroot '/Drive/Enable Motion'],'Gain','0');
    % SET SOLVER
    set_param(bdroot,'Solver','ode15s');
elseif (strcmp(tire_test,'ride'))
    % SET ROAD INPUT VARIANT
    for i = 1:length(ri_bpth)
        set_param(char(ri_bpth(i)),'OverrideUsingVariant','NonMoving');
    end
    set_param([bdroot '/World/Road'],'OverrideUsingVariant','BumpyRoad');
    % SET STEERING INPUT VARIANT
    set_param([bdroot '/Steering Input'],'OverrideUsingVariant','NoSteer');
    % SETTINGS FOR MF-TYRE
    for i = 1:length(TNOblk_pth)
        set_param(char(TNOblk_pth(i)),'cnt_mode','(x5xx) 3D short wavelength road contact');
        set_param(char(TNOblk_pth(i)),'dyn_mode','(xx3x) rigid ring');
        set_param(char(TNOblk_pth(i)),'mf_mode','(xxx4) combined');
        set_param(char(TNOblk_pth(i)),'rdfname','which(''TNO_PolylineRoad.rdf'')');
    end
    % SET INITIAL STATES FOR WHEELS AND CAR
    evalin('base','TNO_Veh_PARAM.InitVel.LF = 66;'); %rad/s
    evalin('base','TNO_Veh_PARAM.InitVel.RF = 66;'); %rad/s
    evalin('base','TNO_Veh_PARAM.InitVel.LR = 66;'); %rad/s
    evalin('base','TNO_Veh_PARAM.InitVel.RR = 66;'); %rad/s
    evalin('base','TNO_Veh_PARAM.InitVel.Vehicle = 20;'); %m/s
    % SET DRIVE VARIANT
    set_param([bdroot '/6-DOF Joint'],'PxTorqueActuationMode','InputTorque');
    set_param([bdroot '/6-DOF Joint'],'PxMotionActuationMode','ComputedMotion');
    set_param([bdroot '/Drive/Enable Motion'],'Gain','0');
    % SET SOLVER
    set_param(bdroot,'Solver','ode45');
elseif (strcmp(tire_test,'sinewithdwell'))
    % SET ROAD INPUT VARIANT
    for i = 1:length(ri_bpth)
        set_param(char(ri_bpth(i)),'OverrideUsingVariant','NonMoving');
    end
    set_param([bdroot '/World/Road'],'OverrideUsingVariant','NoRoad');
    % SET STEERING INPUT VARIANT
    set_param([bdroot '/Steering Input'],'OverrideUsingVariant','SineWithDwell');
    % SETTINGS FOR MF-TYRE
    for i = 1:length(TNOblk_pth)
        set_param(char(TNOblk_pth(i)),'cnt_mode','(x1xx) smooth road');
        set_param(char(TNOblk_pth(i)),'dyn_mode','(xx2x) relaxation behaviour - non-linear');
        set_param(char(TNOblk_pth(i)),'mf_mode','(xxx4) combined');
        set_param(char(TNOblk_pth(i)),'rdfname','which(''TNO_FlatRoad.rdf'')');
    end
    % SET INITIAL STATES FOR WHEELS AND CAR
    evalin('base','TNO_Veh_PARAM.InitVel.LF = 66;'); %rad/s
    evalin('base','TNO_Veh_PARAM.InitVel.RF = 66;'); %rad/s
    evalin('base','TNO_Veh_PARAM.InitVel.LR = 66;'); %rad/s
    evalin('base','TNO_Veh_PARAM.InitVel.RR = 66;'); %rad/s
    evalin('base','TNO_Veh_PARAM.InitVel.Vehicle = 20;'); %m/s
    % SET DRIVE VARIANT
    set_param([bdroot '/6-DOF Joint'],'PxTorqueActuationMode','InputTorque');
    set_param([bdroot '/6-DOF Joint'],'PxMotionActuationMode','ComputedMotion');
    set_param([bdroot '/Drive/Enable Motion'],'Gain','0');
    % SET SOLVER
    set_param(bdroot,'Solver','ode15s');
elseif (strcmp(tire_test,'parking'))
    % SET ROAD INPUT VARIANT
    for i = 1:length(ri_bpth)
        set_param(char(ri_bpth(i)),'OverrideUsingVariant','NonMoving');
    end
    set_param([bdroot '/World/Road'],'OverrideUsingVariant','NoRoad');
    % SET STEERING INPUT VARIANT
    set_param([bdroot '/Steering Input'],'OverrideUsingVariant','Parking');
    % SETTINGS FOR MF-TYRE
    for i = 1:length(TNOblk_pth)
        set_param(char(TNOblk_pth(i)),'cnt_mode','(x1xx) smooth road');
        set_param(char(TNOblk_pth(i)),'dyn_mode','(xx2x) relaxation behaviour - non-linear');
        set_param(char(TNOblk_pth(i)),'mf_mode','(xxx5) combined+turnslip');
        set_param(char(TNOblk_pth(i)),'rdfname','which(''TNO_FlatRoad.rdf'')');
    end
    % SET INITIAL STATES FOR WHEELS AND CAR
    evalin('base','TNO_Veh_PARAM.InitVel.LF = 0;'); %rad/s
    evalin('base','TNO_Veh_PARAM.InitVel.RF = 0;'); %rad/s
    evalin('base','TNO_Veh_PARAM.InitVel.LR = 0;'); %rad/s
    evalin('base','TNO_Veh_PARAM.InitVel.RR = 0;'); %rad/s
    evalin('base','TNO_Veh_PARAM.InitVel.Vehicle = 0;'); %m/s
    % SET DRIVE VARIANT
    delete_line(bdroot,'Drive/Lconn1','6-DOF Joint/Lconn2')
    set_param([bdroot '/6-DOF Joint'],'PxTorqueActuationMode','ComputedTorque');
    set_param([bdroot '/6-DOF Joint'],'PxMotionActuationMode','InputMotion');
    set_param([bdroot '/Drive/Enable Motion'],'Gain','1');
    add_line(bdroot,'Drive/Lconn1','6-DOF Joint/Lconn2','autorouting','on')
    % SET SOLVER
    set_param(bdroot,'Solver','ode45');
elseif (strcmp(tire_test,'slalom'))
    % SET ROAD INPUT VARIANT
    for i = 1:length(ri_bpth)
        set_param(char(ri_bpth(i)),'OverrideUsingVariant','NonMoving');
    end
    set_param([bdroot '/World/Road'],'OverrideUsingVariant','NoRoad');
    % SET STEERING INPUT VARIANT
    set_param([bdroot '/Steering Input'],'OverrideUsingVariant','Slalom');
    % SETTINGS FOR MF-TYRE
    for i = 1:length(TNOblk_pth)
        set_param(char(TNOblk_pth(i)),'cnt_mode','(x1xx) smooth road');
        set_param(char(TNOblk_pth(i)),'dyn_mode','(xx2x) relaxation behaviour - non-linear');
        set_param(char(TNOblk_pth(i)),'mf_mode','(xxx4) combined');
        set_param(char(TNOblk_pth(i)),'rdfname','which(''TNO_FlatRoad.rdf'')');
    end
    % SET INITIAL STATES FOR WHEELS AND CAR
    evalin('base','TNO_Veh_PARAM.InitVel.LF = 66;'); %rad/s
    evalin('base','TNO_Veh_PARAM.InitVel.RF = 66;'); %rad/s
    evalin('base','TNO_Veh_PARAM.InitVel.LR = 66;'); %rad/s
    evalin('base','TNO_Veh_PARAM.InitVel.RR = 66;'); %rad/s
    evalin('base','TNO_Veh_PARAM.InitVel.Vehicle = 20;'); %m/s
    % SET DRIVE VARIANT
    set_param([bdroot '/6-DOF Joint'],'PxTorqueActuationMode','InputTorque');
    set_param([bdroot '/6-DOF Joint'],'PxMotionActuationMode','ComputedMotion');
    set_param([bdroot '/Drive/Enable Motion'],'Gain','0');
    % SET SOLVER
    set_param(bdroot,'Solver','ode15s');
end


