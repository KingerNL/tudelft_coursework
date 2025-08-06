import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
import pandas as pd

sns.set_theme(style="darkgrid")

# -=-=-=-=-=- Parameters -=-=-=-=-=- #

# For both alghorithms
v = np.array([0.1, 0.5, 0.4, 0.2])  # private data
v_2 = np.array([0.1, 0.5, 0.4, 0.2, 0.1, 0.5, 0.4, 0.2])

n = v.size  # n is the number of elements within v (your private data)
n_2 = v_2.size

T = 50      # Number of iterations, from the assignment 50 was chosen
q = 0.6     # q can be chosen anywhere between 0 to 1, from the assignment 0.6 was chosen
p = 0.9     # Parameter in (q, t) used for noise scale
c = 1       # c can be chosen for any number > 0, from the assigment 1 was chosen
consensus = np.average(v) # in the paper, consensus is defined as an agreement on the average, so in this case the average of v (0.3)

# For alghrithm 2 specifically 
epsilon = 0.001 # epsilon can be chosen for how secure your alghorithm is, should be > 0, smaller = more secure
C2 = 3 # C2 should we > or = to the gradient. Which is 3  because you do 1.5 * 2

# Connectivity matrix, given as A = [a_ij] are within R^(nxn), it should suffice:
# 1. Double stochastic (each row and column sums to 1)
# 2. Irreducible (fully connected)
# 3. Nenzero entries are 1/n
A = np.ones((n, n)) / n # chosen for fully connected (complete) matrix
A_2 = np.ones((n_2, n_2)) / n_2

# Initialize x(0) as a n long array, which is arbitrarily (e.g., random in [-1,1])
x = np.random.uniform(-1, 1, n)
x_2 = np.random.uniform(-1, 1, n_2)

# -=-=-=-=-=- Algorithm 1 [2pts] -=-=-=-=-=- #

trajectories1 = [x.copy()]

for t in range(1, T):
    
    # 1) Sending/Receiving (matrix-vector multiply with A, the i'th component of z is z_i)
    z = A @ x
    
    # 2) Gradient at z_i(t): grad f_i(z_i) = 2 * (z_i - v_i)
    grad = 2 * (z - v)
    
    gamma_t = c * (q**t)
     
    # 3) Update + projection
    x_next = z - gamma_t * grad
    
    # Project into [-1,1]
    x_next = np.clip(x_next, -1, 1)
    
    x = x_next
    trajectories1.append(x.copy())

trajectories1 = np.array(trajectories1)  # shape: (T+1, n)

# Convert to DataFrame for Seaborn
df = pd.DataFrame(trajectories1)
df["Iteration"] = df.index
df = df.melt(id_vars="Iteration", var_name="Agent", value_name="Value")

# Plot
# plt.figure()
# for i in range(n):
#     plt.plot(trajectories1[:, i], label=f"x_{i+1}(t)")
# plt.axhline(consensus, color='blue', linestyle='--', label='Consensus = 0.3') 
# plt.xlabel("Iteration")
# plt.ylabel("Value")
# plt.title("Distributed Projected Gradient Method")
# plt.legend(loc="upper right")
# plt.show()


# -=-=-=-=-=- Algorithm 2 with epsilon: 0.001 [4pts] -=-=-=-=-=- #

x = np.random.uniform(-1, 1, n)
trajectories2 = [x.copy()]

for t in range(T):
    
    # calculate b_t (same as in paper)
    b_t = 2 * C2 * np.sqrt(n) * (c*p)/(epsilon*(p-q)) * p**t
    
    # 1) sending (This is the "private" message each agent sends out.)
    noise = np.random.laplace(loc=0.0, scale=b_t, size=n) #For each user i, add noise M_i(t) to x_i(t) to get y_i(t).

    # 2) receiving
    z = A @ x # Matrix-vector multiplication, Each user i computes z_i(t) = sum_j a_{ij} * y_j(t).

    grad = 2 * (z - v)

    gamma_t = c * (q**t)
    
    x_next = z - gamma_t * grad + noise
    x_next = np.clip(x_next, -1, 1)

    #    - Store trajectory for plotting and Update x for the next iteration 
    x = x_next
    trajectories2.append(x.copy())

# Convert to NumPy array for easy slicing/plotting
trajectories2 = np.array(trajectories2)

#     Plot
# plt.figure()
# for i in range(n):
#     plt.plot(trajectories2[:, i], label=f"x_{i+1}(t)")
# plt.axhline(consensus, color='blue', linestyle='--', label='True Consensus ~ 0.3')
# plt.xlabel("Iteration")
# plt.ylabel("Value")
# plt.title("Private Distributed Projected Gradient Method, eps = 0.001, c = 1")
# plt.legend(loc="lower right")
# plt.show()


# -=-=-=-=-=- Algorithm 2 with epsilon: 10^5 -=-=-=-=-=- #

epsilon = 10**5

x = np.random.uniform(-1, 1, n)
trajectories3 = [x.copy()]

for t in range(T):
    
    # calculate b_t (same as in paper)
    b_t = 2 * C2 * np.sqrt(n) * (c*p)/(epsilon*(p-q)) * p**t
    
    # 1) sending (This is the "private" message each agent sends out.)
    noise = np.random.laplace(loc=0.0, scale=b_t, size=n) #For each user i, add noise M_i(t) to x_i(t) to get y_i(t).

    # 2) receiving
    z = A @ x # Matrix-vector multiplication, Each user i computes z_i(t) = sum_j a_{ij} * y_j(t).

    grad = 2 * (z - v)

    gamma_t = c * (q**t)
    
    x_next = z - gamma_t * grad + noise
    x_next = np.clip(x_next, -1, 1)
    
    #    - Store trajectory for plotting and Update x for the next iteration 
    x = x_next
    trajectories3.append(x.copy())

# Convert to NumPy array for easy slicing/plotting
trajectories3 = np.array(trajectories3)

#     Plot
# plt.figure()
# for i in range(n):
#     plt.plot(trajectories3[:, i], label=f"x_{i+1}(t)")
# plt.axhline(consensus, color='blue', linestyle='--', label='True Consensus ~ 0.3')
# plt.xlabel("Iteration")
# plt.ylabel("Value")
# plt.title("Private Distributed Projected Gradient Method, eps = 10^5, c = 1")
# plt.legend(loc="upper right")
# plt.show()

# -=-=-=-=-=- Algorithm 2 with epsilon: 10 and lower c -=-=-=-=-=- #

epsilon = 1000
c = 2          # As can be seen from the equation, c should be any number > 0, and directly influences

x = np.random.uniform(-1, 1, n)
trajectories4 = [x.copy()]

for t in range(T):
    
    # calculate b_t (same as in paper)
    b_t = 2 * C2 * np.sqrt(n) * (c*p)/(epsilon*(p-q)) * p**t
    
    # 1) sending (This is the "private" message each agent sends out.)
    noise = np.random.laplace(loc=0.0, scale=b_t, size=n) #For each user i, add noise M_i(t) to x_i(t) to get y_i(t).

    # 2) receiving
    z = A @ x # Matrix-vector multiplication, Each user i computes z_i(t) = sum_j a_{ij} * y_j(t).

    grad = 2 * (z - v)

    gamma_t = c * (q**t)
    
    x_next = z - gamma_t * grad + noise
    x_next = np.clip(x_next, -1, 1)
    
    #    - Store trajectory for plotting and Update x for the next iteration 
    x = x_next
    trajectories4.append(x.copy())

# Convert to NumPy array for easy slicing/plotting
trajectories4 = np.array(trajectories4)

#     Plot
plt.figure()
for i in range(n):
    plt.plot(trajectories4[:, i], label=f"x_{i+1}(t)")
plt.axhline(consensus, color='blue', linestyle='--', label='True Consensus ~ 0.3')
plt.xlabel("Iteration")
plt.ylabel("Value")
plt.title("Private Distributed Projected Gradient Method, eps = 1000, c = 2")
plt.legend(loc="lower right")
plt.show()