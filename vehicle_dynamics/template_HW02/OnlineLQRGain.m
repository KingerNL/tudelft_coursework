function OnlineLQRSFunction(block)
  setup(block);
end

function setup(block)
  block.NumInputPorts  = 4;
  block.NumOutputPorts = 2;

  block.SetPreCompInpPortInfoToDynamic;
  block.SetPreCompOutPortInfoToDynamic;

  for i = 1:4
    block.InputPort(i).Dimensions        = 1;
    block.InputPort(i).DatatypeID        = 0;
    block.InputPort(i).Complexity        = 'Real';
    block.InputPort(i).DirectFeedthrough = true;
  end

  block.OutputPort(1).Dimensions = 1;
  block.OutputPort(1).DatatypeID = 0;
  block.OutputPort(1).Complexity = 'Real';

  block.OutputPort(2).Dimensions = [1 3];
  block.OutputPort(2).DatatypeID = 0;
  block.OutputPort(2).Complexity = 'Real';

  block.SampleTimes = [-1 0];
  block.SimStateCompliance = 'DefaultSimState';

  block.RegBlockMethod('Outputs', @Outputs);
  block.RegBlockMethod('SetInputPortSamplingMode', @SetInpPortFrameData);
end

function SetInpPortFrameData(block, idx, fd)
  block.InputPort(idx).SamplingMode  = fd;
  block.OutputPort(1).SamplingMode   = fd;
  block.OutputPort(2).SamplingMode   = fd;
end

function Outputs(block)
  vy        = block.InputPort(1).Data;
  yaw_rate  = block.InputPort(2).Data;
  error_int = block.InputPort(3).Data;
  Vx        = block.InputPort(4).Data;
  
  Vx = max(Vx, 0.1);  % prevent division by zero or negative velocity
  
  mass = 1380;
  Izz  = 2634.5;
  l_f  = 1.384;
  L    = 2.79;
  l_r  = L - l_f;
  Calpha_f = 120000;
  Calpha_r = 190000;

  A = zeros(2,2);
  B = zeros(2,1);

  A(1,1) = -(Calpha_f + Calpha_r) / (mass * Vx);
  A(1,2) = (-l_f*Calpha_f + l_r*Calpha_r)/(mass*Vx) - Vx;
  A(2,1) = (-l_f*Calpha_f + l_r*Calpha_r)/(Izz * Vx);
  A(2,2) = -((l_f^2)*Calpha_f + (l_r^2)*Calpha_r)/(Izz * Vx);
  B(1) = Calpha_f / mass;
  B(2) = l_f * Calpha_f / Izz;

  C_out = [0 1];
  A_aug = [A, zeros(2,1); -C_out, 0];
  B_aug = [B; 0];
    
  Q = 1e5 * diag([1, 10, 5]);
  R = Vx;

  K_now = lqr(A_aug, B_aug, Q, R);
  x_aug = [vy; yaw_rate; error_int];
  Mz = max(min(-K_now * x_aug, 1000), -1000);

  block.OutputPort(1).Data = Mz;
  block.OutputPort(2).Data = K_now;
end
