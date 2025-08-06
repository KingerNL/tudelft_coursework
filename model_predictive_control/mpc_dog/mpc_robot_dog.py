import numpy as np
import do_mpc
from casadi import *

# Initialize the model
model_type = 'discrete'
model = do_mpc.model.Model(model_type)

# Define parameters
mass = 30.0
g = 9.81
l = 1.1  # body length
w_dim = 0.2  # body width
h_dim = 0.2  # body height

# Compute inertia components (cuboid approximation)
Ixx = 1/12 * mass * (w_dim**2 + h_dim**2)
Iyy = 1/12 * mass * (l**2 + h_dim**2)
Izz = 1/12 * mass * (l**2 + w_dim**2)
I_mat = DM([[Ixx, 0, 0],
            [0, Iyy, 0],
            [0, 0, Izz]])

# Define state variables: q for CoM position, v for linear velocity, w for angular velocity.
q = model.set_variable(var_type='_x', var_name='q', shape=(3,1))
v = model.set_variable(var_type='_x', var_name='v', shape=(3,1))
w = model.set_variable(var_type='_x', var_name='w', shape=(3,1))

# Define control inputs: GRF for each of the four legs (each 3x1 vector).
f1 = model.set_variable(var_type='_u', var_name='f1', shape=(3,1))
f2 = model.set_variable(var_type='_u', var_name='f2', shape=(3,1))
f3 = model.set_variable(var_type='_u', var_name='f3', shape=(3,1))
f4 = model.set_variable(var_type='_u', var_name='f4', shape=(3,1))

# Define algebraic (parameter) variables for Euler angles (if you plan to use them)
psi   = model.set_variable(var_type='parameter', var_name='psi', shape=(1,1))
theta = model.set_variable(var_type='parameter', var_name='theta', shape=(1,1))
phi   = model.set_variable(var_type='parameter', var_name='phi', shape=(1,1))

# ----- Set up the system dynamics -----

# 1. Position dynamics: The derivative of CoM position is the linear velocity.
model.set_rhs('q', v)

# 2. Linear acceleration: Sum of GRFs divided by mass minus gravity.
grav = vertcat(0, 0, g)  # adjust sign if your coordinate frame differs
model.set_rhs('v', (f1 + f2 + f3 + f4)/mass - grav)

# 3. Angular acceleration:
# Define the leg attachment (or contact) points relative to the CoM.
r1 = vertcat(l/2,  w_dim/2, 0)
r2 = vertcat(l/2, -w_dim/2, 0)
r3 = vertcat(-l/2,  w_dim/2, 0)
r4 = vertcat(-l/2, -w_dim/2, 0)

# Compute the net moment as the sum of cross products for each leg.
moment_net = cross(r1, f1) + cross(r2, f2) + cross(r3, f3) + cross(r4, f4)
# Angular acceleration: I^{-1} * net moment.
model.set_rhs('w', solve(I_mat, moment_net))

# Assume p_dot = v, v_dot = (f1+f2+f3+f4)/mass - gravity, and
# omega_dot = I^{-1} * (cross(r1,f1) + cross(r2,f2) + cross(r3,f3) + cross(r4,f4))

p_dot     = v
v_dot     = (f1 + f2 + f3 + f4) / mass - vertcat(0, 0, g)  # adjust gravity sign as needed
omega_dot = solve(I_mat, cross(r1, f1) + cross(r2, f2) + cross(r3, f3) + cross(r4, f4))

# Combine into a single vector
rhs = vertcat(p_dot, v_dot, omega_dot)

model.setup()

mpc = do_mpc.controller.MPC(model)

setup_mpc = {
    'n_horizon': 20,
    't_step': 0.1,
    'n_robust': 1,
    'store_full_solution': True,
}

mpc.set_param(**setup_mpc)