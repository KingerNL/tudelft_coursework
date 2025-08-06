function [varinf]=dteval(filnam,inputs,use_mode)
%DTEVAL evaluate Magic Formula for series of input variables.
%   VARINF = DTEVAL(FILNAM,INPUTS,USE_MODE) calculates tyre forces using
%   the Magic Formula coefficients specified in the tyre property file FILNAM.
%
%   FILNAM may refer to a MF-Tyre, MF-MCTyre or SWIFT tyre property file
%
%   The inputs to the tyre model should be specified columnwise:
%   INPUTS=[FZ KAPPA ALPHA GAMMA PHIT VX], where
%     FZ       = normal load on the tyre  (N)
%     KAPPA    = longitudinal slip        (dimensionless, -1: locked wheel)
%     ALPHA    = side slip angle          (radians)
%     GAMMA    = inclination angle        (radians)
%     PHIT     = turnslip                 (1/m)
%     VX       = forward velocity         (m/s)
%
%   USE_MODE specifies the type of calculation performed:
%      0: Fz only, no Magic Formula evaluation
%      1: Fx,My only
%      2: Fy,Mx,Mz only
%      3: Fx,Fy,Mx,My,Mz uncombined force/moment calculation
%      4: combined force/moment calculation
%      5: combined force/moment calculation + turnslip
%
%   VARINF consists of 20 columns:
%     1 - Fx: longitudinal force         11 - Vx: longitudinal velocity
%     2 - Fy: lateral force              12 -
%     3 - Fz: normal force               13 - Re: effective rolling radius
%     4 - Mx: overturning moment         14 - tyre deflection 
%     5 - My: rolling resistance moment  15 - contact length
%     6 - Mz: self aligning moment       16 - pneumatic trail
%     7 - kappa: longitudinal slip       17 - longitudinal friction coefficient
%     8 - alpha: side slip angle         18 - lateral friction coefficient
%     9 - gamma: inclination angle       19 -
%    10 - phit: turnslip                 20 -
%
%   NOTE: all calculations are made using the ISO sign convention; the 
%   units will be SI (N,m,s,rad,kg).
%
%   (C) Copyright 1996-2013 TNO Automotive
