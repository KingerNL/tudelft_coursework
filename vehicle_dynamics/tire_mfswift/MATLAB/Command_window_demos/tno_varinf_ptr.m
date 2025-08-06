function varinf_ptr = tno_varinf_ptr()

% tyre model output pointers

% tyre contact forces/moments in the contact point:
varinf_ptr.FXC             = 1;    % longitudinal force Fxw [N]
varinf_ptr.FYC             = 2;    % lateral force Fyw [N]
varinf_ptr.FZC             = 3;    % vertical force Fzw [N]
varinf_ptr.MXC             = 4;    % overturning moment Mxw [Nm] 
varinf_ptr.MYC             = 5;    % rolling resistance moment Myw [Nm]
varinf_ptr.MZC             = 6;    % self aligning moment Mzw [Nm]

% slip quantities:
varinf_ptr.KAPSTS          = 7;    % longitudinal slip [-]
varinf_ptr.ALPSTS          = 8;    % sideslip angle [rad]
varinf_ptr.ICAM            = 9;    % inclination angle [rad]
varinf_ptr.ITURN           = 10;   % turn slip [1/m]

% additional tyre outputs:
varinf_ptr.IVXT            = 11;   % wheel contact centre forward velocity [m/s]
varinf_ptr.IREF            = 13;   % effective rolling radius [m]
varinf_ptr.IDEFL           = 14;   % tyre deflection [m]
varinf_ptr.CON_LEN_PTR     = 15;   % tyre contact length [m]
varinf_ptr.IPT             = 16;   % pneumatic trail [m]
varinf_ptr.MUXCNT          = 17;   % longitudinal friction coefficient [-]
varinf_ptr.MUYCNT          = 18;   % lateral friction coefficient [-]
varinf_ptr.ISGKP0          = 19;   % longitudinal relaxation length [m]
varinf_ptr.ISGAL0          = 20;   % lateral relaxation length [m]
varinf_ptr.IVSX            = 21;   % longitudinal wheel slip velocity [m/s]
varinf_ptr.IVSY            = 22;   % lateral wheel slip velocity [m/s]
varinf_ptr.IVZT            = 23;   % tyre compression velocity [m/s]
varinf_ptr.IPSIDOT         = 24;   % tyre yaw velocity [m/s]
varinf_ptr.DIS_TRA_PTR     = 28;   % travelled distance [m]

% tyre contact point:
varinf_ptr.IRCPX           = 31;   % global x coordinate contact point [m]
varinf_ptr.IRCPY           = 32;   % global y coordinate contact point [m]
varinf_ptr.IRCPZ           = 33;   % global z coordinate contact point [m]
varinf_ptr.IRNX            = 34;   % global x component road normal [-]
varinf_ptr.IRNY            = 35;   % global y component road normal [-]
varinf_ptr.IRNZ            = 36;   % global z component road normal [-]
varinf_ptr.EFF_PLA_HEI_PTR = 37;   % effective road height [m]
varinf_ptr.EFF_PLA_ANG_PTR = 38;   % effective forward slope [rad]
varinf_ptr.EFF_PLA_CUR_PTR = 39;   % effective road curvature [1/m]
varinf_ptr.EFF_PLA_BNK_PTR = 40;   % effective road banking [rad]