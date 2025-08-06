import time
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns

sns.set_theme(style="darkgrid")

# Initial data
x = np.array([1.0, 0.3, 0.1])   # x_i^0
n = len(x)
q = np.array([1.0, 1.0, 1.0])   # q_i
u = x               # u_i^0 = x_i^0
bar_x = np.mean(x)              # global variable, initial guess
rho = 1.0
iter_max = 18

# -- To store history for plotting:
x_history = np.zeros((iter_max+1, n))
bar_x_history = np.zeros(iter_max+1)
x_history[0, :] = x
bar_x_history[0] = bar_x

# -- Overall start time:
start_time = time.time()

for k in range(iter_max):
    
    iter_start = time.time()
    
    x_next = np.zeros_like(x)
    
    for i in range(n):
        x_next[i] = (rho*(bar_x - u[i])) / (2*q[i] + rho)
    
    bar_x_next = np.mean(x_next)
    
    u_next = np.zeros_like(u)
    
    for i in range(n):
        u_next[i] = u[i] + x_next[i] - bar_x_next
    
    # Move updated values to the "current" arrays
    x = x_next
    bar_x = bar_x_next
    u = u_next
    
    # Record for plotting
    x_history[k+1, :] = x
    bar_x_history[k+1] = bar_x
    
    iter_end = time.time()
    print("Iteration[", k+1 , "] - Iteration time: ", iter_end - iter_start, "s")


end_time = time.time()
total_time = end_time - start_time

print("Final x:", x)
print("Final bar_x:", bar_x)
print("Final u:", u)

print("Time taken (s):", total_time)

# --------------------
# PLOTTING
# --------------------
plt.figure(figsize=(8, 5))

# Plot each x_i over iterations
for i in range(n):
    plt.plot(x_history[:, i], label=f"x_{i}")

# Also plot bar_x
plt.plot(bar_x_history, 'k--', label="bar_x")

plt.xlabel("Iteration k")
plt.ylabel("Value")
plt.title("ADMM Consensus: x_i^k and bar_x^k over Iterations")
plt.legend()
plt.grid(True)
plt.tight_layout()
plt.show()
