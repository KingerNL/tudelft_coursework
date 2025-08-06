%% CRG_DEMO_CONVERT2BIN
% Convert handmade_curved.crg demo road to binary representation.

%   Copyright 2005-2009 OpenCRG - Daimler AG - Jochen Rauh
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
%   $Id: crg_demo_convert2bin.m,v 1.4 2010/06/29 11:38:18 tsn\hofstadrhmtvd Exp $

%% clear enviroment

clear all
close all

%% load demo road

ipl = ipl_read('../../Road Data Files/handmade_curved.crg');

%% write it as binary verison (single precision)

ipl_write(ipl, 'handmade_curved-bin-single.crg', 'KRBI');

%% read and visualize result

crg = crg_read('handmade_curved-bin-single.crg');
crg_show(crg);