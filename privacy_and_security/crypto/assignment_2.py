import time
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
from phe import paillier

sns.set_theme(style="darkgrid")

# Initial data
x = np.array([1.0, 0.3, 0.1])   # x_i^0
n = len(x)
q = np.array([1.0, 1.0, 1.0])   # q_i
u = x               # u_i^0 = x_i^0
bar_x = np.mean(x)              # global variable, initial guess
rho = 1.0
iter_max = 18

# Generate Paillier key pair (this can be done once)
print("Creating Paillier keys...")
public_key, private_key = paillier.generate_paillier_keypair()
print("keys created.")

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
    
    # Encrypt x_next values
    encrypted_vals = [public_key.encrypt(x_val) for x_val in x_next]
    encrypted_sum = sum(encrypted_vals)  # Homomorphic addition
    bar_x_next = private_key.decrypt(encrypted_sum) / n  # Compute the average
    
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


# --------------------
# PRINTING
# --------------------
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
