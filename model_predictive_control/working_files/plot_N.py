import numpy as np
from scipy.linalg import expm
from qpsolvers import solve_qp
import matplotlib.pyplot as plt

plt.rcParams.update({'font.size': 16})  # Set global font size





# System parameters
m0 = 1.0  # Cart mass
m1 = 0.1  # Mass of first pendulum
m2 = 0.1  # Mass of second pendulum
l1 = 1.0  # Length of first pendulum
l2 = 1.0  # Length of second pendulum
g = 9.81  # Gravity
dt = 0.1  # Sampling time (0.1 s)



# Continuous linearized system
p = 1 / (4*m0*m1 + 3*m0*m2 + m1**2 + m1*m2)

a42 = -3/2*p*(2*m1 + 5*m1*m2 + 2*m2**2)*g
a43 = 3/2*p*m1*m2*g
a52 = 3/2*p/l1*(4*m0*m1 + 8*m0*m2 + 4*m1**2 + 9*m1*m2 + 2*m2**2)*g
a53 = -9/2*p/l1*(2*m0*m2 + m1*m2)*g
a62 = -9/2*p/l2*(2*m0*m1 + 4*m0*m2 + m1**2 + 2*m1*m2)
a63 = 3/2*p/l2*(m1**2 + 4*m0*m1 + 12*m0*m2 + 4*m1*m2)

b4 = p*(4*m1 + 3*m2)
b5 = -3*p/l1*(2*m1 + m2)
b6 = 3*p*m2/l2

Ac = np.array([
    [0, 0, 0, 1, 0, 0],
    [0, 0, 0, 0, 1, 0],
    [0, 0, 0, 0, 0, 1],
    [0, a42, a42, 0, 0, 0],
    [0, a52, a53, 0, 0, 1],
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



# Discretization using matrix exponential
dim_x = Ac.shape[0]  # [x, x_dot, theta1, theta1_dot, theta2, theta2_dot] (6)
dim_u = Bc.shape[1]  # [Force] (1)

ABc = np.zeros((dim_x + dim_u, dim_x + dim_u))
ABc[:dim_x, :dim_x] = Ac
ABc[:dim_x, dim_x:] = Bc
expm_ABc = expm(ABc * dt)
Ad = expm_ABc[:dim_x, :dim_x]
Bd = expm_ABc[:dim_x, dim_x:]



# Quadratic cost function
Q = 0.1 * np.eye(dim_x)  # State cost
R = 1 * np.eye(dim_u)  # Control cost
P = 100 * np.eye(dim_x)  # Terminal cost



# Prediction matrices
def gen_prediction_matrices(Ad, Bd, N):
    T = np.zeros(((dim_x * (N + 1), dim_x)))
    S = np.zeros(((dim_x * (N + 1), dim_u * N)))

    power_matrices = [np.eye(dim_x)]
    for k in range(N):
        power_matrices.append(power_matrices[k] @ Ad)

    for k in range(N + 1):
        T[k * dim_x:(k + 1) * dim_x, :] = power_matrices[k]
        for j in range(N):
            if k > j:
                S[k * dim_x:(k + 1) * dim_x, j * dim_u:(j + 1) * dim_u] = power_matrices[k - j - 1] @ Bd

    return T, S



# Cost matrices
def gen_cost_matrices(Q, R, P, T, S, x0, N):
    Q_bar = np.zeros(((dim_x * (N + 1), dim_x * (N + 1))))
    Q_bar[-dim_x:, -dim_x:] = P  # Terminal cost
    Q_bar[:dim_x * N, :dim_x * N] = np.kron(np.eye(N), Q)
    R_bar = np.kron(np.eye(N), R)

    H = S.T @ Q_bar @ S + R_bar
    h = S.T @ Q_bar @ T @ x0

    H = 0.5 * (H + H.T)  # Ensure symmetry

    return H, h



def gen_constraint_matrices(u_lb, u_ub, N):
    Gu = np.vstack((np.eye(dim_u), -np.eye(dim_u)))  # [I; -I]
    gu = np.hstack((u_ub, -u_lb))

    Gu_bar = np.kron(np.eye(N), Gu)
    gu_bar = np.kron(np.ones(N), gu)

    return Gu_bar, gu_bar



# Solve MPC
def solve_mpc(Ad, Bd, Q, R, P, x0, N, u_lb, u_ub):
    T, S = gen_prediction_matrices(Ad, Bd, N)
    H, h = gen_cost_matrices(Q, R, P, T, S, x0, N)
    Gu_bar, gu_bar = gen_constraint_matrices(u_lb, u_ub, N)

    u_bar = solve_qp(H, h, G=Gu_bar, h=gu_bar, solver='quadprog')
    u = u_bar[:dim_u]  # Extract first control action

    return u



# Simulation prediction horizon N
def simulate_pendulum_for_N(N):
    x0 = np.array([0, 0, -0.1, 0, -0.1, 0])  # Initial state
    N_sim = 100  # Simulation time steps
    u_lb = np.array([-3])
    u_ub = np.array([3])

    x_hist = np.zeros((N_sim + 1, dim_x))
    x_hist[0, :] = x0
    u_hist = np.zeros((N_sim, dim_u))  # Store control inputs


    for t in range(N_sim):
        u = solve_mpc(Ad, Bd, Q, R, P, x_hist[t, :], N, u_lb, u_ub)
        x_hist[t + 1, :] = Ad @ x_hist[t, :] + Bd @ u
        u_hist[t, :] = u  # Store control input

    return x_hist[:, 4]  # Return the angle of pendulum 2 (theta_2)



# Simulation for different N values
N_values = [20, 25, 30]  # min: 17, max: 33
angles = {}



for N in N_values:
    print(N)
    angles[N] = simulate_pendulum_for_N(N)

# Plot results
plt.figure(figsize=(10, 6))
for N, angle in angles.items():
    plt.plot(np.arange(len(angle)) * dt, angle, label=f'$N$ = {N}', linewidth=2)
plt.xlabel('Time [$s$]')
plt.ylabel(r'$\theta_2$ [$rad$]')
plt.legend()
plt.grid()
plt.show()
