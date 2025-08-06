import cvxpy as cp
import numpy as np
import matplotlib.pyplot as plt
from numpy.linalg import inv, cholesky
from scipy.linalg import solve_discrete_are

# =============================================================================
# Define System Parameters and Matrices (Platoon system, Sec. V)
# =============================================================================
dt = 0.5
beta = -0.1
kp = 0.2
kd = 0.3

F = np.array([
    [1,       0,    -dt,      dt,             0],
    [0,       1,      0,      -dt,            dt], 
    [kp,      0,  (1 + beta) - kd,  kd,        0],
    [-kp,    kp,     kd,  (1 + beta) - 2*kd,    kd],
    [0,     -kp,      0,       kd,  (1 + beta) - kd]
])
G = np.zeros((5, 3))
G[2:, :] = dt * np.eye(3)

gamma = np.array([1.2, 0.8, 1.1])
m = len(gamma)
R_gamma = np.diag(1 / gamma)  # Original physical input bounds

# =============================================================================
# Problem (8): Compute ellipsoidal bound for the original reachable set
# =============================================================================
# Here we choose a = 0.85 (you may motivate this based on trade-offs between 
# feasibility and ellipsoid volume; see the assignment explanation)
a = 0.85

# Decision variable P (symmetric and positive definite)
P = cp.Variable((5, 5), symmetric=True)

# Construct the LMI for Problem (8)
LMI = cp.bmat([
    [a * P - F.T @ P @ F,       -F.T @ P @ G],
    [      -G.T @ P @ F, (1 - a) * R_gamma - G.T @ P @ G]
])
constraints = [P >> 0, LMI >> 0]

# Solve the optimization (minimize -log(det(P)) so as to maximize det(P))
prob = cp.Problem(cp.Minimize(-cp.log_det(P)), constraints)
prob.solve()
P_val = P.value

# =============================================================================
# Problem (13): Synthesize new (safe) actuator bounds with red constraints
# =============================================================================
# Define the half-space constraints for the dangerous set:
# We want to enforce that the first two states satisfy:  d̃_i ≤ -1, for i=1,2.
# In our formulation we use c1 and c2 as:
c1 = np.array([-1, 0, 0, 0, 0])  # corresponds to -d̃1
c2 = np.array([0, -1, 0, 0, 0])  # corresponds to -d̃2
b_val = 1  # because the hyperplane is at d̃_i = -1

# Decision variables: Y (symmetric) and scalars r1, r2, r3 > 0 to form R_hat.
Y = cp.Variable((5, 5), symmetric=True)
r1 = cp.Variable(pos=True)
r2 = cp.Variable(pos=True)
r3 = cp.Variable(pos=True)
R_hat = cp.diag(cp.hstack([r1, r2, r3]))

# Build the augmented LMI as in Problem (13)
bigLMI = cp.bmat([
    [a * Y,                 np.zeros((5, 3)),         Y @ F.T],
    [np.zeros((3, 5)), (1 - a) * R_hat,                   G.T],
    [F @ Y,                         G,                    Y]
])

constraints2 = [
    Y >> 0,
    R_hat >> R_gamma,  # New bounds should be no larger than the original bounds
    cp.quad_form(c1, Y) <= (b_val ** 2) / m,
    cp.quad_form(c2, Y) <= (b_val ** 2) / m,
    bigLMI >> 0
]

# Objective: minimize the trace of R_hat (which is related to maximizing the new bounds)
objective = cp.Minimize(cp.trace(R_hat))
prob2 = cp.Problem(objective, constraints2)
prob2.solve()

Y_val = Y.value

# =============================================================================
# Visualization: Plotting the Ellipsoidal Bounds (projection onto first 2 states)
# =============================================================================
theta = np.linspace(0, 2*np.pi, 200)
circle = np.array([np.cos(theta), np.sin(theta)])

# Original ellipsoid from Problem (8) (using the inverse of the first 2x2 block of P)
P_inv = inv(P_val[:2, :2])
ellipse_orig = cholesky(m * P_inv) @ circle

# Safe ellipsoid from Problem (13) (using the inverse of the first 2x2 block of Y)
Y11 = Y_val[:2, :2]
Y_inv = inv(Y11)
ellipse_safe = cholesky(m * Y_inv) @ circle

plt.figure(figsize=(6,6))
plt.plot(ellipse_orig[0], ellipse_orig[1], 'k-', linewidth=0.5, label="orig constr")
plt.fill(ellipse_orig[0], ellipse_orig[1], color='skyblue', alpha=0.75)
plt.plot(ellipse_safe[0], ellipse_safe[1], 'k-', linewidth=0.5, label="Safe constraints (D1 + D2)")
plt.fill(ellipse_safe[0], ellipse_safe[1], color='red', alpha=0.75)
plt.axhline(-1, linestyle='--', color='red')
plt.axvline(-1, linestyle='--', color='red')
plt.xlabel(r'$\tilde{d}_1$')
plt.ylabel(r'$\tilde{d}_2$')
plt.title("Reachable Set Projection for Platooning System")
plt.legend()
plt.grid(True)
plt.tight_layout()
plt.show()

# =============================================================================
# Reporting Results for Problem (8) and (13)
# =============================================================================
print("Problem (8):")
print("Chosen a:", a)
print("Optimized P matrix:\n", P_val)
print("det(P):", np.linalg.det(P_val))
print("Eigenvalues of P:", np.linalg.eigvals(P_val))

print("\nProblem (13):")
print("First 2x2 block inverse of Y (Y^-1):\n", Y_inv)
print("Eigenvalues of Y^-1:", np.linalg.eigvals(Y_inv))
print("Values r1, r2, r3:", r1.value, r2.value, r3.value)
print("Eigenvalues of R_hat (from r1, r2, r3):", np.linalg.eigvals(np.diag([r1.value, r2.value, r3.value])))

# =============================================================================
# LQR Controller Design and Attack Simulation (Optional Part)
# =============================================================================
# LQR 1: Standard design using Q and R.
Q = np.diag([1, 1, 0.1, 0.1, 0.1])
R = np.eye(3)
P_lqr1 = solve_discrete_are(F, G, Q, R)
K_lqr1 = inv(G.T @ P_lqr1 @ G + R) @ (G.T @ P_lqr1 @ F)
A_cl1 = F - G @ K_lqr1

print("\nLQR1 gain K:\n", K_lqr1)
print("Eigenvalues of closed-loop A (LQR1):", np.linalg.eigvals(A_cl1))

# LQR 2: Using safe Q and R matrices derived from Y and r values.
Q_safe = inv(Y_val)
R_safe = np.diag([r1.value, r2.value, r3.value])
Q_safe = 0.5 * (Q_safe + Q_safe.T)
R_safe = 0.5 * (R_safe + R_safe.T)
P_lqr2 = solve_discrete_are(F, G, Q_safe, R_safe)
K_lqr2 = inv(G.T @ P_lqr2 @ G + R_safe) @ (G.T @ P_lqr2 @ F)
A_cl2 = F - G @ K_lqr2

print("\nLQR2 gain K:\n", K_lqr2)
print("Eigenvalues of closed-loop A (LQR2):", np.linalg.eigvals(A_cl2))

# =============================================================================
# Attack Simulation and Control Input Plotting (Optional Part)
# =============================================================================
T = 100  # Number of time steps
x0 = np.array([4, 4, 16, 16, 16])
attack_w = np.array([0.6681, 0.0, 0.0])

def simulate_with_attack(F, G, K, x0, attack=None, gamma_bound=None):
    x = np.zeros((F.shape[0], T + 1))
    u_hist = np.zeros((G.shape[1], T))
    x[:, 0] = x0
    for t in range(T):
        u = -K @ x[:, t]
        if gamma_bound is not None:
            u = np.clip(u, -gamma_bound, gamma_bound)
        w = attack if attack is not None else np.zeros(3)
        u_hist[:, t] = u
        x[:, t + 1] = F @ x[:, t] + G @ (u + w)
    return x, u_hist

# Simulate for both LQR controllers under clean and attacked conditions.
x1_clean, u1_clean = simulate_with_attack(F, G, K_lqr1, x0)
x1_attacked, u1_attacked = simulate_with_attack(F, G, K_lqr1, x0, attack=attack_w, gamma_bound=gamma)
x2_clean, u2_clean = simulate_with_attack(F, G, K_lqr2, x0)
x2_attacked, u2_attacked = simulate_with_attack(F, G, K_lqr2, x0, attack=attack_w, gamma_bound=1 / np.diag(R_safe))

# Plotting state trajectories for the first two states
fig, ax = plt.subplots(1, 2, figsize=(12, 5))
t = np.arange(T + 1)
ax[0].plot(t, x1_clean[0], 'b--', label='LQR1 clean')
ax[0].plot(t, x1_attacked[0], 'b-', label='LQR1 attacked')
ax[0].plot(t, x2_clean[0], 'g--', label='LQR2 clean')
ax[0].plot(t, x2_attacked[0], 'g-', label='LQR2 attacked')
ax[0].set_title(r"$\tilde{d}_1$ state over time")
ax[0].set_xlabel("Time step")
ax[0].set_ylabel(r"$\tilde{d}_1$")
ax[0].grid(True)
ax[0].legend()

ax[1].plot(t, x1_clean[1], 'b--', label='LQR1 clean')
ax[1].plot(t, x1_attacked[1], 'b-', label='LQR1 attacked')
ax[1].plot(t, x2_clean[1], 'g--', label='LQR2 clean')
ax[1].plot(t, x2_attacked[1], 'g-', label='LQR2 attacked')
ax[1].set_title(r"$\tilde{d}_2$ state over time")
ax[1].set_xlabel("Time step")
ax[1].set_ylabel(r"$\tilde{d}_2$")
ax[1].grid(True)
ax[1].legend()

plt.tight_layout()
plt.show()

# Plot control inputs (optional)
fig, ax = plt.subplots(3, 1, figsize=(10, 6), sharex=True)
labels = ["$u_1$", "$u_2$", "$u_3$"]
colors = ['r', 'g', 'b']
for i in range(3):
    ax[i].plot(t[:-1], u1_clean[i], '--', color=colors[i], label='LQR1 clean')
    ax[i].plot(t[:-1], u1_attacked[i], '-', color=colors[i], label='LQR1 attacked')
    ax[i].plot(t[:-1], u2_clean[i], '--', color=colors[i], linestyle='dotted', label='LQR2 clean')
    ax[i].plot(t[:-1], u2_attacked[i], '-', color=colors[i], linestyle='dashdot', label='LQR2 attacked')
    ax[i].set_ylabel(labels[i])
    ax[i].grid(True)
    ax[i].legend()

ax[-1].set_xlabel("Time step")
plt.suptitle("Control Inputs under Attack and No Attack")
plt.tight_layout(rect=[0, 0.03, 1, 0.95])
plt.show()
