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
C_out = np.eye(dim_x)  # y = x (track full state)
dim_y = C_out.shape[0]

Q = np.eye(dim_x)      # Stage cost
R = np.eye(dim_u)      # Input cost

# Terminal cost (via the discrete ARE)
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
    dim_x = Ad.shape[0]
    dim_u = Bd.shape[1]
    dim_y = C_out.shape[0]
    # 1) Build prediction matrices T and S.
    T, S = gen_prediction_matrices(Ad, Bd, N)
    # 2) Build stacked output prediction matrices.
    I_Np1 = np.eye(N+1)
    T_y = np.kron(I_Np1, C_out) @ T
    S_y = np.kron(I_Np1, C_out) @ S
    # 3) Build Q_bar: stage cost Q for steps 0...N-1, terminal cost P for step N.
    Q_bar = np.kron(np.eye(N), Q)
    Q_bar = np.block([[Q_bar,                np.zeros((N*dim_y, dim_y))],
                      [np.zeros((dim_y, N*dim_y)), P]])
    R_bar = np.kron(np.eye(N), R)
    # 4) Form cost matrices.
    H = S_y.T @ Q_bar @ S_y + R_bar
    h = S_y.T @ Q_bar @ (T_y @ x0)
    H = 0.5 * (H + H.T)
    return H, h, T, S

# ---------------------------
# Constraint Matrices
# ---------------------------
def gen_constraint_matrices(u_lb, u_ub, N):
    dim_u = u_lb.size
    Gu = np.vstack((np.eye(dim_u), -np.eye(dim_u)))
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
    u_bar = solve_qp(H, h, G=Gu_bar, h=gu_bar, solver='quadprog')
    if u_bar is None:
        print("QP solver returned None -> infeasible or solver error.")
    return u_bar[:1]

# ---------------------------
# Simulation function for a given disturbance value
# ---------------------------
def simulate_system(disturbance_value, disturbance_start_time=10, simulation_length=200, N=10):
    disturbance_start_step = int(disturbance_start_time / dt)
    x_hist = np.zeros((simulation_length+1, dim_x))
    u_hist = np.zeros(simulation_length)
    x_hist[0] = x0.copy()
    for t in range(simulation_length):
        u = solve_mpc_output(Ad, Bd, C_out, Q, R, P, x_hist[t], N, u_lb, u_ub)
        # Apply the given disturbance value at the specified time step.
        d = disturbance_value if t == disturbance_start_step else 0.0
        x_hist[t+1] = Ad @ x_hist[t] + Bd @ (u + d)
        u_hist[t] = u
    return x_hist, u_hist

# ---------------------------
# Main simulation for specific disturbance values
# ---------------------------
disturbance_values = [1, 5, 10, 20, 25, 28, 30]  # Disturbance values to test
results = {}  # Dictionary to store trajectories for each disturbance

# Define initial state and simulation parameters globally
x0 = np.array([0, 0, 0.1, 0, -0.1, 0])
simulation_length = 200
N = 10
u_lb = np.array([-30])
u_ub = np.array([30])
disturbance_start_time = 10  # seconds

for d_val in disturbance_values:
    x_hist, u_hist = simulate_system(d_val, disturbance_start_time, simulation_length, N)
    results[d_val] = x_hist
    final_norm = np.linalg.norm(x_hist[-1])
    print(f"Disturbance d = {d_val:.2f} -> Final state norm = {final_norm:.3f}")

# ---------------------------
# Plot results: Cart Position over time for each disturbance value
# ---------------------------
time = dt * np.arange(simulation_length+1)
plt.figure(figsize=(10, 6))
for d_val in disturbance_values:
    x_hist = results[d_val]
    plt.plot(time, x_hist[:, 0], '-o', markersize=3, label=f'd = {d_val}')
plt.xlabel('Time [s]')
plt.ylabel('Cart Position [m]')
plt.title('Cart Position vs Time for Different Disturbance Magnitudes')
plt.grid(True)
plt.legend()
plt.show()
