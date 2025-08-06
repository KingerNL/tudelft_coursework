function check_inertia_parameters(block)
% Performs a dteval simulation to check the correct functioning of dteval
% in the mask of the parent subsystem. This is required because a bug in
% MATLAB 2006a prevents the mask to show the errors (unclear where an error
% comes from) and to stop the simulation as a result of this error. 
%
% As a result, this function will not be executed if an error occurs in the
% mask in newer versions of MATLAB in which this issue is solved.
%  
%   Copyright 2009 TNO Automotive.
%   $First Version: F. Leneman: 11 Nov. 2009  
  
%%   
setup(block);
  
%endfunction

function setup(block)

  % Register number of ports
  block.NumInputPorts  = 0;
  block.NumOutputPorts = 0;
  
  % Setup port properties to be inherited or dynamic
  block.SetPreCompInpPortInfoToDynamic;
  block.SetPreCompOutPortInfoToDynamic;


  % Register parameters
  block.NumDialogPrms     = 3;
  block.DialogPrmsTunable = {'Tunable','Tunable','Tunable'};

  % Register sample times
  %  [0 offset]            : Continuous sample time
  %  [positive_num offset] : Discrete sample time
  %
  %  [-1, 0]               : Port-based sample time
  %  [-2, 0]               : Variable sample time
  block.SampleTimes = [-1 0];
  
  %% -----------------------------------------------------------------
  %% Options
  %% -----------------------------------------------------------------
  % Specify if Accelerator should use TLC or call back into 
  % M-file
  block.SetAccelRunOnTLC(false);
  
  %% -----------------------------------------------------------------
  %% register block methods
  %% -----------------------------------------------------------------
    
  block.RegBlockMethod('CheckParameters', @CheckPrms);

%endfunction

%%
function CheckPrms(block)
  
  b=get_param(gcb,'maskwsvariables');
  ii = find(b(3).Value);%is typarr
  if isempty(ii)
      % assumed if typarr is not empty, structure input is used: in this
      % case 'dteval' does not need to be checked (like in mask)
      [x,typarr]=dteval(b(1).Value,[1 2 3 4 5 6],1);
  end
