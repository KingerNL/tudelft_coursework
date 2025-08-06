import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns

sns.set_theme(style="darkgrid")

# Parameters
v = np.array([0.1, 0.5, 0.4, 0.2, 0.1, 0.5, 0.4, 0.2])
n = v.size  
T = 50      
q = 0.6     
p = 0.9     
c = 1       
consensus = np.average(v)  

epsilon = 10**5  
C2 = 3  

A = np.ones((n, n)) / n  
x = np.random.uniform(-1, 1, n)  

# Initialize live plot
plt.ion()  
fig, ax = plt.subplots()
lines = [ax.plot([], [], label=f"x_{i+1}(t)")[0] for i in range(n)] # Create a line for each agent, for 1 agent it will look cleaner
ax.axhline(consensus, color='blue', linestyle='--', label='True Consensus ~ 0.3')
ax.set_xlabel("Iteration")
ax.set_ylabel("Value")
ax.set_title("Private Distributed Projected Gradient Method n=8 eps=0.1")
ax.legend(loc="lower right")

# Store trajectory
trajectories2 = [x.copy()]  

for t in range(T):
    # Compute noise and update
    b_t = 2 * C2 * np.sqrt(n) * (c*p)/(epsilon*(p-q)) * p**t
    noise = np.random.laplace(loc=0.0, scale=b_t, size=n)
    z = A @ x  
    grad = np.gradient(abs(z - v)**2)  
    gamma_t = c * (q**t)
    x = np.clip(z - gamma_t * grad + noise, -1, 1)
    
    trajectories2.append(x.copy())

    # Update the live plot
    x_vals = np.arange(len(trajectories2))  # This is why np.arange(t+2) is used
    y_vals = np.array(trajectories2)  # Convert list to array for indexing

    for i, line in enumerate(lines):
        line.set_xdata(x_vals)
        line.set_ydata(y_vals[:, i])

    ax.relim()
    ax.autoscale_view()
    plt.pause(0.1)

plt.ioff()
plt.show()
