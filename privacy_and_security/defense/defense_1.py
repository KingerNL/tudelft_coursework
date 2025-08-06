import cvxpy as cp
import numpy as np
import matplotlib.pyplot as plt
from scipy.linalg import sqrtm, eigvals

# System parameters (from Section IV)
F = np.array([[0.7, 0.4],
              [-0.7, 0.2]])

G = np.array([[0.07, 0.42],
              [0.23, 0.1]])

n = F.shape[0]
m = G.shape[1]

# Actuator bounds: [u1^2 <= 8, u2^2 <= 10]
gamma = np.array([8.0, 10.0])

# Define R as in the paper: R = diag(1/gamma_i)
R = np.diag(1.0 / gamma)

# --------------------------
# Problem (8): Original reachable set
# --------------------------
P = cp.Variable((n, n), symmetric=True)

# can be chosen between 0 and 1
a_orig = 0.65

M1 = cp.bmat([
    [a_orig * P - F.T @ P @ F,         -F.T @ P @ G],
    [-G.T @ P @ F,  (1 - a_orig) * R - G.T @ P @ G]
])

constraints_p8 = [P >> 1e-6 * np.eye(n), M1 >> 0]

obj1 = cp.Minimize(-cp.log_det(P))

prob1 = cp.Problem(obj1, constraints_p8)
prob1.solve(solver=cp.SCS)

P_opt = P.value

print("Problem (8) P:", P_opt)
print("Eigenvalues of P:", np.linalg.eigvals(P_opt))
# --------------------------
# Problem (13): Modified bounds to avoid dangerous states
# --------------------------
def solve_problem13(a_val, extra_constraints=[]):
    Y = cp.Variable((n, n), symmetric=True)
    r_hat = cp.Variable(m, pos=True)
    hat_R = cp.diag(r_hat)
    
    constraints = [Y >> 1e-6 * np.eye(n)]
    for i in range(m):
        constraints.append(r_hat[i] >= R[i, i])
    
    # Dangerous constraint D1: c1 = [0.1, 1], b1 = 3.
    c1 = np.array([0.1, 1.0])
    b1 = 3.0
    constraints.append(cp.quad_form(c1, Y) <= (b1**2) / m)
    
    for (c, b) in extra_constraints:
        constraints.append(cp.quad_form(c, Y) <= (b**2) / m)
    
    M2 = cp.bmat([
        [a_val * Y,           np.zeros((n, m)),  Y @ F.T],
        [np.zeros((m, n)), (1 - a_val) * hat_R,    G.T],
        [F @ Y,               G,               Y]
    ])
    
    constraints.append(M2 >> 0)
    
    obj2 = cp.Minimize(cp.trace(hat_R))
    prob2 = cp.Problem(obj2, constraints)
    prob2.solve(solver=cp.SCS)
    
    Y_opt = Y.value
    hat_R_opt = np.diag(r_hat.value)
    eig_Yinv = eigvals(np.linalg.inv(Y_opt))
    eig_hat_R = eigvals(hat_R_opt)
    
    return Y_opt, hat_R_opt, eig_Yinv, eig_hat_R, prob2.value

# (i) Solve Problem (13) with red constraint only, with a = 0.65.
a_red = 0.65
Y_opt_red, hat_R_opt_red, eig_Yinv_red, eig_hat_R_red, obj_red = solve_problem13(a_red)
Y_inv_red = np.linalg.inv(Y_opt_red)
print("\nProblem (13) with red constraint only (D1):")
print("Optimal Y^{-1} (from Y):")
print(Y_inv_red)
print("Optimal objective (trace(hat_R)):", obj_red)

# (ii) Solve Problem (13) with both red and green constraints, with a = 0.65.
c2 = np.array([2.0, -1.0])
b2 = 2 * np.sqrt(5)
a_both = 0.65
Y_opt_both, hat_R_opt_both, eig_Yinv_both, eig_hat_R_both, obj_both = solve_problem13(a_both, extra_constraints=[(c2, b2)])
Y_inv_both = np.linalg.inv(Y_opt_both)
print("\nProblem (13) with red and green constraints (D1 and D2):")
print("Optimal Y^{-1} (from Y):")
print(Y_inv_both)
print("Optimal objective (trace(hat_R)):", obj_both)

# --------------------------
# Plotting the Ellipsoids
# --------------------------
# Each ellipsoid is defined as { x in R^2 : x^T A x <= m }.
# For Problem (8): A = P_opt.
# For Problem (13): A = Y^{-1}.
def plot_ellipse(A, m_val, facecolor, edgecolor, label, alpha=1.0, zorder=1, 
                 rotation_angle=0, scale=1.0):
    # Eigen-decomposition for the ellipse { x^T A x = m_val }
    vals, vecs = np.linalg.eig(A)
    axes = np.sqrt(m_val / np.real(vals))
    t = np.linspace(0, 2*np.pi, 200)
    ellipse = (vecs @ np.diag(axes)) @ np.array([np.cos(t), np.sin(t)])
    
    # Apply scaling factor to the ellipse points
    ellipse *= scale

    # If a rotation angle is provided, rotate the ellipse points
    if rotation_angle != 0:
        R_theta = np.array([[np.cos(rotation_angle), -np.sin(rotation_angle)],
                            [np.sin(rotation_angle),  np.cos(rotation_angle)]])
        ellipse = R_theta @ ellipse

    # Fill the ellipse completely (opaque fill)
    plt.fill(
        ellipse[0, :], ellipse[1, :],
        facecolor=facecolor,
        edgecolor=edgecolor,
        alpha=alpha,
        zorder=zorder,
        label=label
    )
    
    # Plot the boundary on top to emphasize the outline
    plt.plot(
        ellipse[0, :], ellipse[1, :],
        color=edgecolor,
        zorder=zorder + 1
    )



plt.figure(figsize=(8,8))

# Plot the Problem (8) ellipsoid rotated by 30 degrees:
plot_ellipse(P_opt, m, facecolor='lightblue', edgecolor='black',
             label='Original Reachable Set (Problem 8) rotated',
             alpha=0.8, zorder=1)

plot_ellipse(Y_inv_red, m, facecolor='red', edgecolor='black',
             label='Modified Set (Red Constraint Only)',
             alpha=0.8, zorder=2)


plot_ellipse(Y_inv_both, m, facecolor='green', edgecolor='black',
             label='Modified Set (Red + Green Constraints)',
             alpha=0.8, zorder=3)


plt.axis([-6, 6, -6, 6])
plt.xlabel('$x_1$')
plt.ylabel('$x_2$')
plt.title('Ellipsoidal Bounds on the Reachable Set')
plt.legend()
plt.grid(True)
plt.axis('equal')
plt.show()
