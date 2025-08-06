function [] = crg_demo_gen_road()
% CRG_DEMO_GEN_ROAD CRG demo to generate a synthetic crg-file.
%   CRG_DEMO_GEN_ROAD() demonstrates how a road inluding walkline etc. can
%   be generated.
%
%   Example:
%   crg_demo_gen_road    runs this demo to generate "syntheticRoad.crg"
%
%   See also CRG_INTRO, CRG_GEN_CSB2CRG0.

%   Copyright 2005-2010 OpenCRG - VIRES Simulationstechnologie GmbH - HHelmich
%   Based on Dr. Klaus Mueller (DAIMLER AG) Matlab implementation to generate a synthetic road 
%
%   Licensed under the Apache License, Version 2.0 (the "License");
%   you may not use this file except in compliance with the License.
%   You may obtain a copy of the License at
% 
%       http://www.apache.org/licenses/LICENSE-2.0
% 
%   Unless required by applicable law or agreed to in writing, software
%   distributed under the License is distributed on an "AS IS" BASIS,
%   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
%   See the License for the specific language governing permissions and
%   limitations under the License.
%
%   More Information on OpenCRG open file formats and tools can be found at
%
%       http://www.opencrg.org
%
%   $Id: crg_demo_gen_road.m,v 1.1 2010/06/16 12:44:55 tsn\hofstadrhmtvd Exp $

%% default settings

filename = 'syntheticRoad.crg';

uinc =    0.5;
ubeg =  -20;
uend =  750;

u = (ubeg:uinc:uend)';

%% create longitudenal and lateral profile(s)

% l -> left  hand side
% r -> right hand side
% u-coordinate    begin                 middle range          end
% v-coordinate    left                  origin                right
ulane_range  = [  ubeg                                        uend  ];    % lane range
ulane_prof   = [  1                                           1     ];
vlane_space  = [  4                     -uinc                -4     ];    % right and left lane space
vlane_prof   = [  ones(size(vlane_space))                           ];

ulwalk_range = [  ubeg                300 302  460 470        uend  ];    % sidewalk range on left hand side
ulwalk_prof  = [  0                   0   1    1   0          0     ];
vlwalk_space = [  2             0.01    0                           ];    % sidewalk on left hand side
vlwalk_prof  = [  1             1       0                           ];

ulcurb_range = [  ubeg                                        uend  ];    % left road shoulder range
ulcurb_prof  = [  1                                           1     ];
vlcurb_space = [  1             0.2     0                           ];    % left road shoulder
vlcurb_prof  = [  1             1       0                           ];

urcurb_range = [  ubeg                                        uend  ];    % right road shoulder range
urcurb_prof  = [  1                                           1     ];
vrcurb_space = [                        0   -0.3             -3     ];    % right road shoulder
vrcurb_prof  = [                        0    1                1     ];

urmark_range = [  ubeg                                        uend  ];    % right road marking range
urmark_prof  = [  1                                           1     ];
vrmark_space = [  0.11     0.1                    -0.1       -0.11  ];    % right road marking
vrmark_prof  = [  0        1                        1         0     ];

ucmark_range = [  u'                                                ];    % center road marking range
ucmark_prof  = [  (mod(u',10)<0.3*10)                               ];    % 10 m period with 3m marking 
vcmark_space = [  0.11     0.1                    -0.1       -0.11  ];    % center road marking
vcmark_prof  = [  0        1                        1         0     ];

ulmark_range = [  ubeg                                        uend  ];    % left road marking range
ulmark_prof  = [  1                                           1     ];
vlmark_space = [  0.11     0.1                    -0.1      -0.11   ];    % left road marking
vlmark_prof  = [  0        1                       1         0      ];

ugutt_range  = [  ubeg                                        uend  ];    % gutter range
ugutt_prof   = [  1                                           1     ];
vgutt_space  = [  0.16     0.15                   -0.15     -0.16   ];    % gutter
vgutt_prof   = [  0        1                       1         0      ];

ulrut_range  = [  ubeg                                        uend  ];    % left rut range
ulrut_prof   = [  1                                           1     ];
vlrut_space  = [                   0.3:-0.05:-0.3                   ];    % left rut
vlrut_prof   = [          (cos(pi*(0.3:-0.05:-0.3)/0.6)).^2         ];

urrut_range  = [  ubeg                                        uend  ];    % right rut range
urrut_prof   = [  1                                           1     ];
vrrut_space  = [                   0.3:-0.05:-0.3                   ];    % right rut
vrrut_prof   = [          (cos(pi*(0.3:-0.05:-0.3)/0.6)).^2         ];

%                           amplitude                 offset to center       amplitude
%                           |                         |                      |
upvp = { ...
       ; { [  ulane_range;  1     *  ulane_prof ]  [  0    +  vlane_space;   0     *  vlane_prof ] } ...  % lane   profile
       ; { [ ulmark_range;  1     * ulmark_prof ]  [  3.5  + vlmark_space;   0.003 * vlmark_prof ] } ...  % left   marker line 
       ; { [ ucmark_range;  1     * ucmark_prof ]  [  0    + vcmark_space;   0.002 * vcmark_prof ] } ...  % center marker line
       ; { [ urmark_range;  1     * urmark_prof ]  [ -3.5  + vrmark_space;   0.001 * vrmark_prof ] } ...  % right  marker line
       ; { [  ugutt_range;  1     *  ugutt_prof ]  [  3.8  +  vgutt_space;  -0.015 *  vgutt_prof ] } ...  % gutter
       ; { [  ulrut_range;  1     *  ulrut_prof ]  [ -0.75 +  vlrut_space;  -0.01  *  vlrut_prof ] } ...  % left   rut
       ; { [  urrut_range;  1     *  urrut_prof ]  [ -2.75 +  vrrut_space;  -0.012 *  vrrut_prof ] } ...  % right  rut
       ; { [ ulwalk_range;  1     * ulwalk_prof ]  [  4    + vlwalk_space;   0.1   * vlwalk_prof ] } ...  % sidewalk on left hand side
       ; { [ urcurb_range;  1     * urcurb_prof ]  [ -4    + vrcurb_space;  -0.05  * vrcurb_prof ] } ...  % road shoulder on right hand side
       ; { [ ulcurb_range;  1     * ulcurb_prof ]  [  6    + vlcurb_space;  -0.1   * vlcurb_prof ] } ...  % road shoulder on left hand side
       };  
[vn] = size(upvp, 1);
v = [];
for ii = 1:vn
    v = unique([v upvp{ii,1}{1,2}(1,:)]);
end

%% curvature

LC1  =  120;      R1s  =  inf;    R1e  =  inf;
LC2  =   50;      R2s  =  inf;    R2e  =  -50;
LC3  =  185.5;    R3s  =  -50;    R3e  =  -50;
LC4  =   50;      R4s  =  -50;    R4e  =  inf;
LC5  =   65;      R5s  =  inf;    R5e  =  inf;
LC6  =   20;      R6s  =  inf;    R6e  =   30;
LC7  =  126.5;    R7s  =   30;    R7e  =   30;
LC8  =   10;      R8s  =   30;    R8e  =  inf;
LC9  =   10;      R9s  =  inf;    R9e  =  inf;

c = { ...
    ;  LC1   { 1/R1s  ( 1/R1e  - 1/R1s  )/LC1  }  ...
    ;  LC2   { 1/R2s  ( 1/R2e  - 1/R2s  )/LC2  }  ...
    ;  LC3   { 1/R3s  ( 1/R3e  - 1/R3s  )/LC3  }  ...
    ;  LC4   { 1/R4s  ( 1/R4e  - 1/R4s  )/LC4  }  ...
    ;  LC5   { 1/R5s  ( 1/R5e  - 1/R5s  )/LC5  }  ...
    ;  LC6   { 1/R6s  ( 1/R6e  - 1/R6s  )/LC6  }  ...
    ;  LC7   { 1/R7s  ( 1/R7e  - 1/R7s  )/LC7  }  ...
    ;  LC8   { 1/R8s  ( 1/R8e  - 1/R8s  )/LC8  }  ...
    ;  LC9   { 1/R9s  ( 1/R9e  - 1/R9s  )/LC9  }  ...
    };

%% slope

LS1  = 120;      S1s  =  0;        S1e  =  0;
LS2  =  25;      S2s  =  0;        S2e  =  0;
LS3  =  25;      S3s  =  0;        S3e  =  0.03;
LS4  = 185.5;    S4s  =  0.03;     S4e  =  0.03; 
LS5  =  25;      S5s  =  0.03;     S5e  =  0; 
LS6  =  25;      S6s  =  0;        S6e  =  0;
LS7  =  65;      S7s  =  0;        S7e  = -0.01;
LS8  =  20;      S8s  = -0.01;     S8e  = -0.04;
LS9  = 126.5;    S9s  = -0.04;     S9e  = -0.04;
LS10 =  20;      S10s = -0.04;     S10e =  0;

s = { ...
    ; LS1   { S1s  ( S1e  - S1s  )/LS1  }  ...
    ; LS2   { S2s  ( S2e  - S2s  )/LS2  }  ...
    ; LS3   { S3s  ( S3e  - S3s  )/LS3  }  ...
    ; LS4   { S4s  ( S4e  - S4s  )/LS4  }  ...
    ; LS5   { S5s  ( S5e  - S5s  )/LS5  }  ...
    ; LS6   { S6s  ( S6e  - S6s  )/LS6  }  ...
    ; LS7   { S7s  ( S7e  - S7s  )/LS7  }  ...
    ; LS8   { S8s  ( S8e  - S8s  )/LS8  }  ...
    ; LS9   { S9s  ( S9e  - S9s  )/LS9  }  ...
    ; LS10  { S10s ( S10e - S10s )/LS10 }  ...
    };

%% banking

LB1  = 120;      B1s  =  0;        B1e  =  0;
LB2  =  50;      B2s  =  0;        B2e  =  0.02;
LB3  = 185.5;    B3s  =  0.02;     B3e  =  0.02;
LB4  =  50;      B4s  =  0.02;     B4e  =  0;
LB5  =  65;      B5s  =  0;        B5e  = -0.02;
LB6  =  20;      B6s  = -0.02;     B6e  = -0.05;
LB7  = 126.5;    B7s  = -0.05;     B7e  = -0.02;
LB8  =  10;      B8s  = -0.02;     B8e  = -0.02;
LB9  =  10;      B9s  = -0.02;     B9e  =  0.0;

% coefficients for smooth non linear Banking (spline), a demonstration 
B7_a =  1*B7s;
B7_b =  0;
B7_c =  3*( B7e  - B7s  )/LB7^2;
B7_d = -2*( B7e  - B7s  )/LB7^3;

b = { ...
    ; LB1   { B1s  ( B1e  - B1s  )/LB1  }  ...
    ; LB2   { B2s  ( B2e  - B2s  )/LB2  }  ...
    ; LB3   { B3s  ( B3e  - B3s  )/LB3  }  ...
    ; LB4   { B4s  ( B4e  - B4s  )/LB4  }  ...
    ; LB5   { B5s  ( B5e  - B5s  )/LB5  }  ...
    ; LB6   { B6s  ( B6e  - B6s  )/LB6  }  ...
%    ; LB7   { B7s  ( B7e  - B7s  )/LB7  }  ...
    ; LB7   { B7_a  B7_b  B7_c   B7_d   }  ...
    ; LB8   { B8s  ( B8e  - B8s  )/LB8  }  ...
    ; LB9   { B9s  ( B9e  - B9s  )/LB9  }  ...
    };

%% generate synthetical straight crg file

data = crg_gen_csb2crg0(uinc, [ubeg uend], v, c, s, b);

%% add profile(s) to surface

nu = size(data.z, 1);

for ii = 1:vn
    up = zeros(nu,1);
    up = up + interp1(upvp{ii,1}{1,1}(1,:), upvp{ii,1}{1,1}(2,:), u, 'linear', 0);
    zp = zeros(1,size(v,2));
    zp = zp + interp1(upvp{ii,1}{1,2}(1,:), upvp{ii,1}{1,2}(2,:), v, 'linear', 0);
    data.z = data.z + single(up*zp);
end
txtnum = length(data.ct) + 1; data.ct{txtnum} = 'CRG lateral and longitudinal profile added to surface';

%% check and write data to file

txtnum = txtnum + 1; data.ct{txtnum} = '... finished';
data = crg_single(data);
data = crg_check(data);
crg_write(data, filename);

%% display result

crg_show(data);

end