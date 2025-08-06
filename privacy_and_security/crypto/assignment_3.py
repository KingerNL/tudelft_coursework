import time
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
from phe import paillier
import sys, os
sys.path.append(os.path.join(os.path.dirname(__file__), 'ot'))
from ot import Alice, Bob

sns.set_theme(style="darkgrid")

# Initial data
x = np.array([1.0, 0.3, 0.1])   # x_i^0
n = len(x)
q = np.array([1.0, 1.0, 1.0])
u = x.copy()  # u_i^0 = x_i^0
bar_x = np.mean(x)
rho = 1.0
iter_max = 18

# --- OT Setup ---
secret_length = 4  # 4 bytes per pad

# Generate truly random pads as byte strings
secrets = [np.random.bytes(secret_length) for _ in range(n)]

# Instead of decoding, print the integer value for inspection:
print("Secret 0 as integer:", int.from_bytes(secrets[0], byteorder='big'))
print("Secret 1 as integer:", int.from_bytes(secrets[1], byteorder='big'))
print("Secret 2 as integer:", int.from_bytes(secrets[2], byteorder='big'))

alice = Alice(secrets, n, secret_length)
alice.setup()

# Each agent (the italian mafioso) retrieves its pad via OT.
vivaldi = Bob([0])  # Wants message at index 0
pavarotti = Bob([1])  # Wants message at index 1
leonardo = Bob([2])  # Wants message at index 2

# Setup each Bob with a unique file name
vivaldi.setup(file_name="bob_setup_1.json")
pavarotti.setup(file_name="bob_setup_2.json")
leonardo.setup(file_name="bob_setup_3.json")
    
alice.transmit()

def bytes_to_int(byte_data):
    return int.from_bytes(byte_data, byteorder="big", signed=False)

# Collect pads from each Bob, converting the received bytes to integers.
agent_pads = np.array([
    bytes_to_int(vivaldi.receive()[0]),
    bytes_to_int(pavarotti.receive()[0]),
    bytes_to_int(leonardo.receive()[0])
], dtype=np.float64)

# --- History for plotting ---
x_history = np.zeros((iter_max+1, n))
bar_x_history = np.zeros(iter_max+1)
x_history[0, :] = x
bar_x_history[0] = bar_x

# --- Main ADMM Loop ---
start_time = time.time()
for k in range(iter_max):
    iter_start = time.time()

    # 1) Local update: compute x_i^{k+1}
    x_next = np.zeros_like(x)
    for i in range(n):
        x_next[i] = (rho * (bar_x - u[i])) / (2 * q[i] + rho)

    # 2) Mask the local update using OT pad:
    x_masked = x_next + agent_pads

    # 3) Global update using masked values:
    bar_masked = np.mean(x_masked)
    bar_x_next = bar_masked - np.mean(agent_pads)

    # 4) Dual update:
    u_next = np.zeros_like(u)
    for i in range(n):
        u_next[i] = u[i] + x_next[i] - bar_x_next

    # Update variables:
    x = x_next
    bar_x = bar_x_next
    u = u_next

    x_history[k+1, :] = x
    bar_x_history[k+1] = bar_x

    iter_end = time.time()
    print("Iteration[", k+1, "] - Iteration time:", iter_end - iter_start, "s")

end_time = time.time()
total_time = end_time - start_time

print("Final x:", x)
print("Final bar_x:", bar_x)
print("Final u:", u)
print("Total time (s):", total_time)
print(x_history[:, 0])

# --- Plotting ---
plt.figure(figsize=(8, 5))
for i in range(n):
    plt.plot(x_history[:, i], label=f"x_{i}")
plt.plot(bar_x_history, 'k--', label="bar_x")
plt.xlabel("Iteration k")
plt.ylabel("Value")
plt.title("ADMM Consensus with OT-based One-Time Pads")
plt.legend()
plt.grid(True)
plt.tight_layout()
plt.show()
