import numpy as np
import matplotlib.pyplot as plt
from scipy.linalg import expm
from qpsolvers import solve_qp
from scipy.linalg import solve_discrete_are
# import seaborn as sns
# sns.set_theme(style="dark")

# ---------------------------
# System parameters
# ---------------------------
m0 = 1.0
m1 = 0.1
m2 = 0.1
l1 = 1.0
l2 = 1.0
g  = 9.81
dt = 0.1

p = 1 / (4*m0*m1 + 3*m0*m2 + m1**2 + m1*m2)

a42 = -(3/2) * p * (2*m1**2 + 5*m1*m2 + 2*m2**2)*g
a43 = (3/2)*p*m1*m2*g
a52 = (3*p)/(2*l1)*(4*m0*m1 + 8*m0*m2 + 4*m1**2 + 9*m1*m2 + 2*m2**2)*g
a53 = -(9*p)/(2*l1)*(2*m0*m2 + m1*m2)*g
a62 = -(9*p)/(2*l2) * (2*m0*m1 + 4*m0*m2 + m1**2 + 2*m1*m2)
a63 = (3*p)/(2*l2)*(m1**2 + 4*m0*m1 + 12*m0*m2 + 4*m1*m2)

b4 = p*(4*m1 + 3*m2)
b5 = -(3*p)/l1*(2*m1 + m2)
b6 = (3*p*m2)/l2

Ac = np.array([
    [0, 0, 0, 1, 0, 0],
    [0, 0, 0, 0, 1, 0],
    [0, 0, 0, 0, 0, 1],
    [0, a42, a43, 0, 0, 0],
    [0, a52, a53, 0, 0, 0],
    [0, a62, a63, 0, 0, 0]
])

Bc = np.array([
    [0],
    [0],
    [0],
    [b4],
    [b5],
    [b6]
])

dim_x = Ac.shape[0]  # 6
dim_u = Bc.shape[1]  # 1

# ---------------------------
# Discretization
# ---------------------------
ABc = np.zeros((dim_x + dim_u, dim_x + dim_u))
ABc[:dim_x, :dim_x]   = Ac
ABc[:dim_x, dim_x:]   = Bc
expm_ABc = expm(ABc * dt)
Ad = expm_ABc[:dim_x, :dim_x]
Bd = expm_ABc[:dim_x, dim_x:]

# ---------------------------
# Output matrix and weights
# ---------------------------
# We track the entire state as output: y = x.
C_out = np.eye(dim_x)
dim_y = C_out.shape[0]

# Stage cost: adjusting Q affects convergence speed.
Q = np.eye(dim_x)

# Input cost.
R = np.eye(dim_u)

# Terminal cost in output space via the discrete ARE.
P = solve_discrete_are(Ad, Bd, Q, R)

# ---------------------------
# Prediction Matrices
# ---------------------------
def gen_prediction_matrices(Ad, Bd, N):
    T = np.zeros((dim_x*(N+1), dim_x))
    S = np.zeros((dim_x*(N+1), dim_u*N))
    
    power_matrices = [np.eye(dim_x)]
    for k in range(N):
        power_matrices.append(power_matrices[k] @ Ad)
    
    for k in range(N+1):
        T[k*dim_x:(k+1)*dim_x, :] = power_matrices[k]
        for j in range(N):
            if k > j:
                S[k*dim_x:(k+1)*dim_x, j*dim_u:(j+1)*dim_u] = power_matrices[k-j-1] @ Bd
    return T, S

# ---------------------------
# Cost Matrices in OUTPUT Space
# ---------------------------
def gen_cost_matrices_output(Ad, Bd, C_out, Q, R, P, x0, N):
    """
    Formulate the QP cost: 
      J(u) = 0.5 u^T H u + h^T u,
    with
      H = S_y.T @ Q_bar @ S_y + R_bar,
      h = S_y.T @ Q_bar @ (T_y @ x0),
    where Q_bar is a block-diagonal matrix with Q for the stage and P for the terminal step.
    """
    dim_x = Ad.shape[0]
    dim_u = Bd.shape[1]
    dim_y = C_out.shape[0]

    # 1) Build T, S (prediction matrices) for states.
    T, S = gen_prediction_matrices(Ad, Bd, N)
    
    # 2) Build stacked output prediction matrices.
    I_Np1 = np.eye(N+1)
    T_y = np.kron(I_Np1, C_out) @ T  # Stacked outputs: size ((N+1)*dim_y, dim_x)
    S_y = np.kron(I_Np1, C_out) @ S  # size ((N+1)*dim_y, N*dim_u)
    
    # 3) Build the block diagonal matrix Q_bar.
    # The first N blocks are Q (stage cost) and the final block is P (terminal cost).
    Q_bar = np.kron(np.eye(N), Q)
    Q_bar = np.block([[Q_bar,                np.zeros((N*dim_y, dim_y))],
                      [np.zeros((dim_y, N*dim_y)), P]])
    
    # Build R_bar for the inputs.
    R_bar = np.kron(np.eye(N), R)
    
    # 4) Form the quadratic cost matrices H and h.
    H = S_y.T @ Q_bar @ S_y + R_bar
    h = S_y.T @ Q_bar @ (T_y @ x0)  # Note: the reference is assumed zero.
    
    # Ensure symmetry.
    H = 0.5 * (H + H.T)
    return H, h, T, S

# ---------------------------
# Constraint Matrices
# ---------------------------
def gen_constraint_matrices(u_lb, u_ub, N):
    dim_u = u_lb.size
    Gu = np.vstack((np.eye(dim_u), -np.eye(dim_u)))  # [I; -I]
    gu = np.hstack((u_ub, -u_lb))
    Gu_bar = np.kron(np.eye(N), Gu)
    gu_bar = np.kron(np.ones(N), gu)
    return Gu_bar, gu_bar

# ---------------------------
# MPC Solver (Output-based)
# ---------------------------
def solve_mpc_output(Ad, Bd, C_out, Q, R, P, x0, N, u_lb, u_ub):
    H, h, _, _ = gen_cost_matrices_output(Ad, Bd, C_out, Q, R, P, x0, N)
    Gu_bar, gu_bar = gen_constraint_matrices(u_lb, u_ub, N)
    
    # Solve the QP.
    u_bar = solve_qp(H, h, G=Gu_bar, h=gu_bar, solver='quadprog')
    
    if u_bar is None:
        print("QP solver returned None -> infeasible or solver error.")
    return u_bar[:1]  # Return only the first control input.

# ---------------------------
# Simulation
# ---------------------------
N = 10                         # Prediction horizon
x0 = np.array([0, 0, 0.1, 0, -0.1, 0])   # Initial state
simulation_length = 200        # Number of simulation steps

u_lb = np.array([-30])         # Lower bound for control input
u_ub = np.array([30])          # Upper bound for control input

x_hist = np.zeros((simulation_length+1, dim_x))
x_hist[0] = x0
u_hist = np.zeros(simulation_length)

disturbance = -2              # Disturbance magnitude
disturbance_start_time = 8    # Disturbance begins at 10 seconds
disturbance_start_time2 = 10    # Disturbance begins at 10 seconds
disturbance_start_time3 = 14    # Disturbance begins at 10 seconds
disturbance_start_step = int(disturbance_start_time / dt)
disturbance_start_step2 = int(disturbance_start_time2 / dt)
disturbance_start_step3 = int(disturbance_start_time3 / dt)

for t in range(simulation_length):
    # Solve MPC to drive the output (here, x) to 0.
    u = solve_mpc_output(Ad, Bd, C_out, Q, R, P, x_hist[t], N, u_lb, u_ub)
    
    # Apply disturbance at the designated time.
    if t == disturbance_start_step:
        d = disturbance 
    elif t == disturbance_start_step2:
        d = disturbance * -1
    elif t == disturbance_start_step3:
        d = disturbance
    else:
        d = 0.0

    
    
    # State update with disturbance added to the input.
    x_hist[t+1] = Ad @ x_hist[t] + Bd @ (u + d)
    u_hist[t] = u

# ---------------------------
# Plots
# ---------------------------
time = dt * np.arange(simulation_length+1)
fig, axs = plt.subplots(3, 1, figsize=(8, 8), sharex=True)

axs[0].plot(time, x_hist[:, 0], '-o', label='x (Cart Position)', markersize=3)
axs[0].set_ylabel('Position [m]')
axs[0].legend(), axs[0].grid()

axs[1].plot(time, x_hist[:, 2], '-o', label=r'$\theta_1$', markersize=3)
axs[1].plot(time, x_hist[:, 4], '-o', label=r'$\theta_2$', markersize=3)
axs[1].set_ylabel('Angle [rad]')
axs[1].legend(), axs[1].grid()

axs[2].step(time[:-1], u_hist, label='Control Input')
# axs[2].axvline(disturbance_start_time, color='k', linestyle='--', label='Disturbance On')
axs[2].set_xlabel('Time [s]')
axs[2].set_ylabel('Input [N]')
axs[2].legend(), axs[2].grid()

plt.tight_layout()
plt.show()
