import cvxpy as cp
import numpy as np
from scipy.linalg import expm, solve_discrete_are
from qpsolvers import solve_qp
import matplotlib.pyplot as plt

# ---------------------------
# System parameters
# ---------------------------
m0 = 1.0  # Cart mass
m1 = 0.1  # Mass of first pendulum
m2 = 0.1  # Mass of second pendulum
l1 = 1.0  # Length of first pendulum
l2 = 1.0  # Length of second pendulum
g = 9.81  # Gravity
dt = 0.1  # Sampling time (0.1 s)

# ---------------------------
# Continuous linearized system
# ---------------------------
p = 1 / (4*m0*m1 + 3*m0*m2 + m1**2 + m1*m2)

a42 = -3/2 * p * (2*m1 + 5*m1*m2 + 2*m2**2) * g
a43 = 3/2 * p * m1*m2 * g
a52 = 3/2 * p / l1 * (4*m0*m1 + 8*m0*m2 + 4*m1**2 + 9*m1*m2 + 2*m2**2) * g
a53 = -9/2 * p / l1 * (2*m0*m2 + m1*m2) * g
a62 = -9/2 * p / l2 * (2*m0*m1 + 4*m0*m2 + m1**2 + 2*m1*m2)
a63 = 3/2 * p / l2 * (m1**2 + 4*m0*m1 + 12*m0*m2 + 4*m1*m2)

b4 = p * (4*m1 + 3*m2)
b5 = -3 * p / l1 * (2*m1 + m2)
b6 = 3 * p * m2 / l2

Ac = np.array([
    [0, 0,   0, 1, 0, 0],
    [0, 0,   0, 0, 1, 0],
    [0, 0,   0, 0, 0, 1],
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

# Full-state tracking matrix (not used for output here)
C = np.eye(6)

dim_x = Ac.shape[0]  # [x, x_dot, theta1, theta1_dot, theta2, theta2_dot] (6)
dim_u = Bc.shape[1]  # [Force] (1)

# ---------------------------
# Discretization using matrix exponential
# ---------------------------
ABc = np.zeros((dim_x + dim_u, dim_x + dim_u))
ABc[:dim_x, :dim_x] = Ac
ABc[:dim_x, dim_x:] = Bc
expm_ABc = expm(ABc * dt)
Ad = expm_ABc[:dim_x, :dim_x]
Bd = expm_ABc[:dim_x, dim_x:]

# ---------------------------
# Cost function matrices (for tracking)
# ---------------------------
# We define an output matrix for tracking the tip.
# Here we assume the tip's horizontal position is approximated as: x_tip = x + l1 * theta1
C_out = np.array([[1, 0, l1, 0, 0, 0]])  # shape (1,6)
dim_y = C_out.shape[0]

# Stage cost weight (for output error tracking)
# Here we choose Q_out for output tracking and R for control
Q_out = 10 * np.eye(dim_y)
R = 1 * np.eye(dim_u)
# Terminal cost weight on output error (could be tuned further)
P_out = 100 * np.eye(dim_y)

# ---------------------------
# Prediction matrices
# ---------------------------
def gen_prediction_matrices(Ad, Bd, N):
    T = np.zeros(((dim_x * (N + 1)), dim_x))
    S = np.zeros(((dim_x * (N + 1)), dim_u * N))
    
    power_matrices = [np.eye(dim_x)]
    for k in range(N):
        power_matrices.append(power_matrices[k] @ Ad)
    
    for k in range(N + 1):
        T[k*dim_x:(k+1)*dim_x, :] = power_matrices[k]
        for j in range(N):
            if k > j:
                S[k*dim_x:(k+1)*dim_x, j*dim_u:(j+1)*dim_u] = power_matrices[k - j - 1] @ Bd
                
    return T, S

# ---------------------------
# Cost matrices for tracking MPC
# ---------------------------
def gen_cost_matrices_tracking(Q_out, R, P_out, T, S, x0, r_bar, N, C_out):
    # Build block-diagonal matrices for stage and terminal cost for outputs.
    Q_bar = np.kron(np.eye(N), Q_out)
    Q_bar = np.block([
        [Q_bar, np.zeros((N*dim_y, dim_y))],
        [np.zeros((dim_y, N*dim_y)), P_out]
    ])
    R_bar = np.kron(np.eye(N), R)
    
    # Build stacked output prediction matrices. 
    # For each step, the predicted output is C_out*x.
    T_y = np.kron(np.eye(N+1), C_out) @ T  # shape: ((N+1)*dim_y, dim_x)
    S_y = np.kron(np.eye(N+1), C_out) @ S  # shape: ((N+1)*dim_y, N*dim_u)
    
    H = S_y.T @ Q_bar @ S_y + R_bar
    h = S_y.T @ Q_bar @ (T_y @ x0 - r_bar)
    # Ensure H is symmetric
    H = 0.5 * (H + H.T)
    return H, h

# ---------------------------
# Constraint matrices
# ---------------------------
def gen_constraint_matrices(u_lb, u_ub, N):
    Gu = np.vstack((np.eye(dim_u), -np.eye(dim_u)))  # [I; -I]
    gu = np.hstack((u_ub, -u_lb))
    
    Gu_bar = np.kron(np.eye(N), Gu)
    gu_bar = np.kron(np.ones(N), gu)
    return Gu_bar, gu_bar

# ---------------------------
# MPC solver for tracking
# ---------------------------
def solve_mpc_tracking(Ad, Bd, Q_out, R, P_out, x0, N, u_lb, u_ub, C_out, r_bar):
    T, S = gen_prediction_matrices(Ad, Bd, N)
    H, h = gen_cost_matrices_tracking(Q_out, R, P_out, T, S, x0, r_bar, N, C_out)
    Gu_bar, gu_bar = gen_constraint_matrices(u_lb, u_ub, N)
    
    # Solve the QP: minimize 0.5*u_bar^T H u_bar + h^T u_bar subject to constraints
    u_bar = solve_qp(H, h, G=Gu_bar, h=gu_bar, solver='quadprog')
    u = u_bar[:dim_u]  # Use only the first control input
    return u

# ---------------------------
# Reference Trajectory Setup
# ---------------------------
N = 20  # Prediction Horizon
# We want the tip position (output) to reach 1. Create a stacked reference.
# For a horizon of N steps (plus terminal), r_bar has (N+1)*dim_y elements.
r_single = np.array([1])  # desired tip position (in x-direction)
r_bar = np.kron(np.ones(N+1), r_single)  # constant reference over horizon

# ---------------------------
# Simulation parameters
# ---------------------------
# Initial state: [x, x_dot, theta1, theta1_dot, theta2, theta2_dot]
x0 = np.array([0, 0, 0.1, 0, -0.1, 0])
N_sim = 100  # number of simulation steps

# Input limits
u_lb = np.array([-3])
u_ub = np.array([3])

x_hist = np.zeros((N_sim+1, dim_x))
x_hist[0, :] = x0
u_hist = np.zeros((N_sim, dim_u))

# ---------------------------
# Simulation loop
# ---------------------------
for t in range(N_sim):
    u = solve_mpc_tracking(Ad, Bd, Q_out, R, P_out, x_hist[t, :], N, u_lb, u_ub, C_out, r_bar)
    x_hist[t+1, :] = Ad @ x_hist[t, :] + Bd @ u
    u_hist[t, :] = u

# ---------------------------
# Plotting results
# ---------------------------
time = dt * np.arange(N_sim+1)

# Plot the cart position, pendulum angle, and tip position
fig, axs = plt.subplots(3, 1, figsize=(8, 8), sharex=True)
axs[0].plot(time, x_hist[:, 0], '-o', label='x (Cart Position)')
axs[0].set_ylabel('Position [m]')
axs[0].legend(), axs[0].grid()

axs[1].plot(time, x_hist[:, 2], '-o', label=r'$\theta_1$ (Pendulum 1)')
axs[1].set_ylabel('Angle [rad]')
axs[1].legend(), axs[1].grid()

# Compute tip position from state using: x_tip = x + l1 * theta1
x_tip = x_hist[:, 0] + l1 * x_hist[:, 2]
axs[2].plot(time, x_tip, '-o', label='Tip Position')
axs[2].plot(time, np.ones_like(time)*1, 'k--', label='Reference (1 m)')
axs[2].set_xlabel('Time [s]')
axs[2].set_ylabel('Tip Position [m]')
axs[2].legend(), axs[2].grid()

plt.tight_layout()
plt.show()

# Plot control inputs
plt.figure(figsize=(8, 4))
plt.step(dt * np.arange(N_sim), u_hist, label='Input Force')
plt.xlabel('Time [s]')
plt.ylabel('Force [N]')
plt.legend(), plt.grid()
plt.show()
