% TNO_TIR2STRUCT
%   Reads a tir file and converts it to the (MATLAB) structure typarr_struct
% 
%   Syntax:
%     typarr_struct = tno_tir2struct(tirfile)
%   
%   Description:
%     TNO_TIR2STRUCT reads the tyre property file TIRFILE and converts it to
%     the (MATLAB)structure TYPARR_STRUCT. This structure containing tyre 
%     properties may be used as input in the mask of the 'STI tyre' or 
%     'SimMechanics Wheel + tyre'.
% 
%     TIRFILE may refer to a MF-Tyre, MF-MCTyre or SWIFT tyre property file.
% 
%     TYPARR_STRUCT is structure similar to the tyre property file, 
%     containing at level:
%       1. sections 
%       2. tyre parameters
%     E.g. 
%       - TYPARR_STRUCT.UNITS.LENGTH = 'meter'
%       - TYPARR_STRUCT.MODEL.FITTYP = 61
% 
%   Note:
%   - Additional fields may be added to the structure. These will be ignored
%     by the tyre model.
%   - The first block of comments (indicated with lines starting with '!')
%     are stored in the variable COMMENT.
% 
%   (C) Copyright 1996-2011 TNO Automotive
%