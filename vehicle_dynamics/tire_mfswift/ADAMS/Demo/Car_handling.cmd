!
!-------------------------- Default Units for Model ---------------------------!
!
!
defaults units  &
   length = meter  &
   angle = rad  &
   force = newton  &
   mass = kg  &
   time = sec
!
defaults units  &
   coordinate_system_type = cartesian  &
   orientation_type = body313
!
!------------------------ Default Attributes for Model ------------------------!
!
!
defaults attributes  &
   inheritance = bottom_up  &
   icon_visibility = off  &
   grid_visibility = off  &
   size_of_icons = 0.12  &
   spacing_for_grid = 0.12
!
!------------------------------ Adams/View Model ------------------------------!
!
!
model create  &
   model_name = model_1  &
   title = "ADAMS/View model name: mod1"
!
view erase
!
!---------------------------- ADAMS/View Variables ----------------------------!
!
!
variable create  &
   variable_name = .model_1.WZ_front  &
   real_value = 0.0
!
variable create  &
   variable_name = .model_1.WZ_rear  &
   real_value = 0.0
!
variable create  &
   variable_name = .model_1.Z_front  &
   real_value = 0.2908
!
variable create  &
   variable_name = .model_1.X_front  &
   real_value = 1.5
!
variable create  &
   variable_name = .model_1.Z_rear  &
   real_value = 0.2909
!
variable create  &
   variable_name = .model_1.X_rear  &
   real_value = -1.5
!
variable create  &
   variable_name = .model_1.VX  &
   real_value = 20.0
!
!
variable create  &
   variable_name = .model_1.Y_left  &
   real_value = 0.8
!
!
variable create  &
   variable_name = .model_1.Y_right  &
   real_value = -0.8
!
variable create  &
   variable_name = .model_1.Z_rollaxis_front  &
   real_value = 0.0
!
variable create  &
   variable_name = .model_1.Z_rollaxis_rear  &
   real_value = 0.05
!
!-------------------------------- Data storage --------------------------------!
!
!
!-------------------------------- Rigid Parts ---------------------------------!
!
! Create parts and their dependent markers and graphics
!
!----------------------------------- ground -----------------------------------!
!
!
! ****** Ground Part ******
!
defaults model  &
   part_name = ground
!
defaults coordinate_system  &
   default_coordinate_system = .model_1.ground
!
! ****** Markers for current part ******
!
marker create  &
   marker_name = .model_1.ground.groundmarker  &
   location = 0.0, 0.0, 0.0  &
   orientation = 0.0, 0.0, 0.0
!
marker create  &
   marker_name = .model_1.ground.road_nr_1_ref_1  &
   location = 0.0, 0.0, 0.0  &
   orientation = 0.0, 0.0, 0.0
!
marker attributes  &
   marker_name = .model_1.ground.road_nr_1_ref_1  &
   visibility = off
!
! ****** Floating Markers for current part ******
!
floating_marker create  &
   floating_marker_name = .model_1.ground.tyre_1_tire_jf_1
!
floating_marker create  &
   floating_marker_name = .model_1.ground.tyre_2_tire_jf_1
!
floating_marker create  &
   floating_marker_name = .model_1.ground.tyre_3_tire_jf_1
!
floating_marker create  &
   floating_marker_name = .model_1.ground.tyre_4_tire_jf_1
!
!--------------------------------- front_axle ---------------------------------!
!
!
defaults coordinate_system  &
   default_coordinate_system = .model_1.ground
!
part create rigid_body name_and_position  &
   part_name = .model_1.front_axle  &
   location = 0.0, 0.0, 0.0  &
   orientation = 0.0, 0.0, 0.0
!
part create rigid_body initial_velocity  &
   part_name = .model_1.front_axle  &
   vx = (.model_1.VX)  &
   vy = 0.0  &
   vz = 0.0  &
   wx = 0.0  &
   wy = 0.0  &
   wz = 0.0
!
defaults coordinate_system  &
   default_coordinate_system = .model_1.front_axle
!
! ****** Markers for current part ******
!
marker create  &
   marker_name = .model_1.front_axle.CG  &
   location = (.model_1.X_front), 0.0, 0.3  &
   orientation = 0.0, 0.0, 0.0
!
marker attributes  &
   marker_name = .model_1.front_axle.CG  &
   active = on  &
   visibility = on  &
   name_visibility = on
!
marker create  &
   marker_name = .model_1.front_axle.left  &
   location = (.model_1.X_front), (.model_1.Y_left), (.model_1.Z_front)  &
   orientation = 0.0, 0.0, 0.0
!
marker attributes  &
   marker_name = .model_1.front_axle.left  &
   active = on  &
   visibility = on  &
   name_visibility = on
!
marker create  &
   marker_name = .model_1.front_axle.right  &
   location = (.model_1.X_front), (.model_1.Y_right), (.model_1.Z_front)  &
   orientation = 0.0, 0.0, 0.0
!
marker attributes  &
   marker_name = .model_1.front_axle.right  &
   active = on  &
   visibility = on  &
   name_visibility = on
!
marker create  &
   marker_name = .model_1.front_axle.front  &
   location = (.model_1.X_front), 0.0, (.model_1.Z_rollaxis_front)  &
   orientation = 1.5707963268, 1.5707963268, 4.7123889804
!
marker attributes  &
   marker_name = .model_1.front_axle.front  &
   active = on  &
   visibility = on  &
   name_visibility = on
!
marker create  &
   marker_name = .model_1.front_axle.request_marker_front  &
   location = (.model_1.X_front), 0.0, 0.0  &
   orientation = 0.0, 0.0, 0.0
!
marker attributes  &
   marker_name = .model_1.front_axle.request_marker_front  &
   active = on  &
   visibility = on  &
   name_visibility = on
!
marker create  &
   marker_name = .model_1.front_axle.graphic_left  &
   location = (.model_1.X_front), (.model_1.Y_left), 0.3  &
   orientation = 0.0, 1.5707963268, 0.0
!
marker attributes  &
   marker_name = .model_1.front_axle.graphic_left  &
   active = on  &
   visibility = on  &
   name_visibility = on
!
part create rigid_body mass_properties  &
   part_name = .model_1.front_axle  &
   mass = 95.0  &
   center_of_mass_marker = .model_1.front_axle.CG  &
   ixx = 1.0  &
   iyy = 1.0  &
   izz = 1.0  &
   ixy = 0.0  &
   izx = 0.0  &
   iyz = 0.0
!
! ****** Graphics for current part ******
!
geometry create shape cylinder  &
   cylinder_name = .model_1.front_axle.front_axle  &
   center_marker = .model_1.front_axle.graphic_left  &
   angle_extent = 6.2831853072  &
   length = ((.model_1.Y_left)+(.model_1.Y_right))  &
   radius = 3.0E-002  &
   side_count_for_body = 20  &
   segment_count_for_ends = 20
!
geometry attributes  &
   geometry_name = .model_1.front_axle.front_axle  &
   active = on
!
!---------------------------------- mainbody ----------------------------------!
!
!
defaults coordinate_system  &
   default_coordinate_system = .model_1.ground
!
part create rigid_body name_and_position  &
   part_name = .model_1.mainbody  &
   location = 0.0, 0.0, 0.0  &
   orientation = 0.0, 0.0, 0.0
!
part create rigid_body initial_velocity  &
   part_name = .model_1.mainbody  &
   vx = (.model_1.VX)  &
   vy = 0.0  &
   vz = 0.0  &
   wx = 0.0  &
   wy = 0.0  &
   wz = 0.0
!
defaults coordinate_system  &
   default_coordinate_system = .model_1.mainbody
!
! ****** Markers for current part ******
!
marker create  &
   marker_name = .model_1.mainbody.CG  &
   location = 0.0, 0.0, 0.55  &
   orientation = 0.0, 0.0, 0.0
!
marker attributes  &
   marker_name = .model_1.mainbody.CG  &
   active = on  &
   visibility = on  &
   name_visibility = on
!
marker create  &
   marker_name = .model_1.mainbody.front  &
   location = (.model_1.X_front), 0.0, 0.3  &
   orientation = 0.0, 0.0, 0.0
!
marker attributes  &
   marker_name = .model_1.mainbody.front  &
   active = on  &
   visibility = on  &
   name_visibility = on
!
marker create  &
   marker_name = .model_1.mainbody.rear  &
   location = (.model_1.X_rear), 0.0, 0.3  &
   orientation = 0.0, 0.0, 0.0
!
marker attributes  &
   marker_name = .model_1.mainbody.rear  &
   active = on  &
   visibility = on  &
   name_visibility = on
!
marker create  &
   marker_name = .model_1.mainbody.to_trans_front  &
   location = (.model_1.X_front), 0.0, 0.1  &
   orientation = 0.0, 0.0, 0.0
!
marker attributes  &
   marker_name = .model_1.mainbody.to_trans_front  &
   active = on  &
   visibility = on  &
   name_visibility = on
!
marker create  &
   marker_name = .model_1.mainbody.to_trans_rear  &
   location = (.model_1.X_rear), 0.0, 0.1  &
   orientation = 0.0, 0.0, 0.0
!
marker attributes  &
   marker_name = .model_1.mainbody.to_trans_rear  &
   active = on  &
   visibility = on  &
   name_visibility = on
!
marker create  &
   marker_name = .model_1.mainbody.shell_marker  &
   location = (.model_1.X_front+0.1), 0.0, 0.3  &
   orientation = 0.0, 0.0, 0.0
!
part create rigid_body mass_properties  &
   part_name = .model_1.mainbody  &
   mass = 1600.0  &
   center_of_mass_marker = .model_1.mainbody.CG  &
   ixx = 600.0  &
   iyy = 3000.0  &
   izz = 3200.0  &
   ixy = 0.0  &
   izx = 0.0  &
   iyz = 0.0
!
! ****** Graphics for current part ******
!
geometry create shape block  &
   block_name = .model_1.mainbody.BOX_70001  &
   corner_marker = .model_1.mainbody.shell_marker  &
   diag_corner_coords = (.model_1.X_rear-.model_1.X_front-0.2), 0.5, 0.3
!
geometry attributes  &
   geometry_name = .model_1.mainbody.BOX_70001  &
   active = on  &
   color = YELLOW  &
   visibility = on
!
geometry create shape block  &
   block_name = .model_1.mainbody.BOX_70002  &
   corner_marker = .model_1.mainbody.shell_marker  &
   diag_corner_coords = (.model_1.X_rear-.model_1.X_front-0.2), -0.5, 0.3
!
geometry attributes  &
   geometry_name = .model_1.mainbody.BOX_70002  &
   active = on  &
   color = YELLOW  &
   visibility = on
!
!--------------------------------- rear_axle ----------------------------------!
!
!
defaults coordinate_system  &
   default_coordinate_system = .model_1.ground
!
part create rigid_body name_and_position  &
   part_name = .model_1.rear_axle  &
   location = 0.0, 0.0, 0.0  &
   orientation = 0.0, 0.0, 0.0
!
part create rigid_body initial_velocity  &
   part_name = .model_1.rear_axle  &
   vx = (.model_1.VX)  &
   vy = 0.0  &
   vz = 0.0  &
   wx = 0.0  &
   wy = 0.0  &
   wz = 0.0
!
defaults coordinate_system  &
   default_coordinate_system = .model_1.rear_axle
!
! ****** Markers for current part ******
!
marker create  &
   marker_name = .model_1.rear_axle.CG  &
   location = (.model_1.X_rear), 0.0, 0.3  &
   orientation = 0.0, 0.0, 0.0
!
marker attributes  &
   marker_name = .model_1.rear_axle.CG  &
   active = on  &
   visibility = on  &
   name_visibility = on
!
marker create  &
   marker_name = .model_1.rear_axle.left  &
   location = (.model_1.X_rear), (.model_1.Y_left), (.model_1.Z_rear)  &
   orientation = 0.0, 1.5707963268, 0.0
!
marker attributes  &
   marker_name = .model_1.rear_axle.left  &
   active = on  &
   visibility = on  &
   name_visibility = on
!
marker create  &
   marker_name = .model_1.rear_axle.right  &
   location = (.model_1.X_rear), (.model_1.Y_right), (.model_1.Z_rear)  &
   orientation = 0.0, 1.5707963268, 0.0
!
marker attributes  &
   marker_name = .model_1.rear_axle.right  &
   active = on  &
   visibility = on  &
   name_visibility = on
!
marker create  &
   marker_name = .model_1.rear_axle.rear  &
   location = (.model_1.X_rear), 0.0, (.model_1.Z_rollaxis_rear)  &
   orientation = 1.5707963268, 1.5707963268, 4.7123889804
!
marker attributes  &
   marker_name = .model_1.rear_axle.rear  &
   active = on  &
   visibility = on  &
   name_visibility = on
!
marker create  &
   marker_name = .model_1.rear_axle.request_marker_rear  &
   location = (.model_1.X_rear), 0.0, 0.1  &
   orientation = 0.0, 0.0, 0.0
!
marker attributes  &
   marker_name = .model_1.rear_axle.request_marker_rear  &
   active = on  &
   visibility = on  &
   name_visibility = on
!
part create rigid_body mass_properties  &
   part_name = .model_1.rear_axle  &
   mass = 90.0  &
   center_of_mass_marker = .model_1.rear_axle.CG  &
   ixx = 1.0  &
   iyy = 1.0  &
   izz = 1.0  &
   ixy = 0.0  &
   izx = 0.0  &
   iyz = 0.0
!
! ****** Graphics for current part ******
!
geometry create shape cylinder  &
   cylinder_name = .model_1.rear_axle.rear_axle  &
   center_marker = .model_1.rear_axle.left  &
   angle_extent = 6.2831853072  &
   length = ((.model_1.Y_left)+(.model_1.Y_right))  &
   radius = 3.0E-002  &
   side_count_for_body = 20  &
   segment_count_for_ends = 20
!
geometry attributes  &
   geometry_name = .model_1.rear_axle.rear_axle  &
   active = on
!
!--------------------------- steering_kingpin_left ----------------------------!
!
!
defaults coordinate_system  &
   default_coordinate_system = .model_1.ground
!
part create rigid_body name_and_position  &
   part_name = .model_1.steering_kingpin_left  &
   location = 0.0, 0.0, 0.0  &
   orientation = 0.0, 0.0, 0.0
!
part create rigid_body initial_velocity  &
   part_name = .model_1.steering_kingpin_left  &
   vx = (.model_1.VX)  &
   vy = 0.0  &
   vz = 0.0  &
   wx = 0.0  &
   wy = 0.0  &
   wz = 0.0
!
defaults coordinate_system  &
   default_coordinate_system = .model_1.steering_kingpin_left
!
! ****** Markers for current part ******
!
marker create  &
   marker_name = .model_1.steering_kingpin_left.CG  &
   location = (.model_1.X_front), (.model_1.Y_left), (.model_1.Z_front)  &
   orientation = 0.0, 0.0, 0.0
!
marker attributes  &
   marker_name = .model_1.steering_kingpin_left.CG  &
   active = on  &
   visibility = on  &
   name_visibility = on
!
marker create  &
   marker_name = .model_1.steering_kingpin_left.tyre_left  &
   location = (.model_1.X_front), (.model_1.Y_left), (.model_1.Z_front)  &
   orientation = 0.0, 1.5707963268, 0.0
!
marker attributes  &
   marker_name = .model_1.steering_kingpin_left.tyre_left  &
   active = on  &
   visibility = on  &
   name_visibility = on
!
part create rigid_body mass_properties  &
   part_name = .model_1.steering_kingpin_left  &
   mass = 1.0E-03  &
   center_of_mass_marker = .model_1.steering_kingpin_left.CG  &
   ixx = 1.0  &
   iyy = 1.0  &
   izz = 1.0  &
   ixy = 0.0  &
   izx = 0.0  &
   iyz = 0.0
!
! ****** Graphics for current part ******
!
geometry create shape cylinder  &
   cylinder_name = .model_1.steering_kingpin_left.steering_kingpin_left  &
   center_marker = .model_1.steering_kingpin_left.CG  &
   angle_extent = 6.2831853072  &
   length = -0.1  &
   radius = 5.0E-002  &
   side_count_for_body = 20  &
   segment_count_for_ends = 20
!
geometry attributes  &
   geometry_name = .model_1.steering_kingpin_left.steering_kingpin_left  &
   active = on
!
!--------------------------- steering_kingpin_right ---------------------------!
!
!
defaults coordinate_system  &
   default_coordinate_system = .model_1.ground
!
part create rigid_body name_and_position  &
   part_name = .model_1.steering_kingpin_right  &
   location = 0.0, 0.0, 0.0  &
   orientation = 0.0, 0.0, 0.0
!
part create rigid_body initial_velocity  &
   part_name = .model_1.steering_kingpin_right  &
   vx = (.model_1.VX)  &
   vy = 0.0  &
   vz = 0.0  &
   wx = 0.0  &
   wy = 0.0  &
   wz = 0.0
!
defaults coordinate_system  &
   default_coordinate_system = .model_1.steering_kingpin_right
!
! ****** Markers for current part ******
!
marker create  &
   marker_name = .model_1.steering_kingpin_right.CG  &
   location = (.model_1.X_front), (.model_1.Y_right), (.model_1.Z_front)  &
   orientation = 0.0, 0.0, 0.0
!
marker attributes  &
   marker_name = .model_1.steering_kingpin_right.CG  &
   active = on  &
   visibility = on  &
   name_visibility = on
!
marker create  &
   marker_name = .model_1.steering_kingpin_right.tyre_right  &
   location = (.model_1.X_front), (.model_1.Y_right), (.model_1.Z_front)  &
   orientation = 0.0, 1.5707963268, 0.0
!
marker attributes  &
   marker_name = .model_1.steering_kingpin_right.tyre_right  &
   active = on  &
   visibility = on  &
   name_visibility = on
!
part create rigid_body mass_properties  &
   part_name = .model_1.steering_kingpin_right  &
   mass = 1.0E-03  &
   center_of_mass_marker = .model_1.steering_kingpin_right.CG  &
   ixx = 1.0  &
   iyy = 1.0  &
   izz = 1.0  &
   ixy = 0.0  &
   izx = 0.0  &
   iyz = 0.0
!
! ****** Graphics for current part ******
!
geometry create shape cylinder  &
   cylinder_name = .model_1.steering_kingpin_right.steering_kingpin_right  &
   center_marker = .model_1.steering_kingpin_right.CG  &
   angle_extent = 6.2831853072  &
   length = -0.1  &
   radius = 5.0E-002  &
   side_count_for_body = 20  &
   segment_count_for_ends = 20
!
geometry attributes  &
   geometry_name = .model_1.steering_kingpin_right.steering_kingpin_right  &
   active = on
!
!---------------------------------- dummy_fr ----------------------------------!
!
!
defaults coordinate_system  &
   default_coordinate_system = .model_1.ground
!
part create rigid_body name_and_position  &
   part_name = .model_1.dummy_fr  &
   comments = " Including vertical and rotational degrees of freedom"  &
   location = 0.0, 0.0, 0.0  &
   orientation = 0.0, 0.0, 0.0
!
part create rigid_body initial_velocity  &
   part_name = .model_1.dummy_fr  &
   vx = (.model_1.VX)  &
   vy = 0.0  &
   vz = 0.0  &
   wx = 0.0  &
   wy = 0.0  &
   wz = 0.0
!
defaults coordinate_system  &
   default_coordinate_system = .model_1.dummy_fr
!
! ****** Markers for current part ******
!
marker create  &
   marker_name = .model_1.dummy_fr.to_trans  &
   location = (.model_1.X_front), 0.0, (.model_1.Z_rollaxis_front)  &
   orientation = 0.0, 0.0, 0.0
!
marker attributes  &
   marker_name = .model_1.dummy_fr.to_trans  &
   active = on  &
   visibility = on  &
   name_visibility = on
!
marker create  &
   marker_name = .model_1.dummy_fr.to_rev  &
   location = (.model_1.X_front), 0.0, (.model_1.Z_rollaxis_front)  &
   orientation = 1.5707963268, 1.5707963268, 4.7123889804
!
marker attributes  &
   marker_name = .model_1.dummy_fr.to_rev  &
   active = on  &
   visibility = on  &
   name_visibility = on
!
marker create  &
   marker_name = .model_1.dummy_fr.cm  &
   location = (.model_1.X_front), 0.0, 0.0  &
   orientation = 0.0, 0.0, 0.0
!
marker attributes  &
   marker_name = .model_1.dummy_fr.cm  &
   active = on  &
   visibility = on  &
   name_visibility = on
!
part create rigid_body mass_properties  &
   part_name = .model_1.dummy_fr  &
   mass = 1.0e-3  &
   center_of_mass_marker = .model_1.dummy_fr.cm  &
   ixx = 1.0  &
   iyy = 1.0  &
   izz = 1.0  &
   ixy = 0.0  &
   izx = 0.0  &
   iyz = 0.0
!
!--------------------------------- dummy_rear ---------------------------------!
!
!
defaults coordinate_system  &
   default_coordinate_system = .model_1.ground
!
part create rigid_body name_and_position  &
   part_name = .model_1.dummy_rear  &
   location = 0.0, 0.0, 0.0  &
   orientation = 0.0, 0.0, 0.0
!
part create rigid_body initial_velocity  &
   part_name = .model_1.dummy_rear  &
   vx = (.model_1.VX)  &
   vy = 0.0  &
   vz = 0.0  &
   wx = 0.0  &
   wy = 0.0  &
   wz = 0.0
!
defaults coordinate_system  &
   default_coordinate_system = .model_1.dummy_rear
!
! ****** Markers for current part ******
!
marker create  &
   marker_name = .model_1.dummy_rear.to_rev  &
   location = (.model_1.X_rear), 0.0, (.model_1.Z_rollaxis_rear)  &
   orientation = 1.5707963268, 1.5707963268, 4.7123889804
!
marker attributes  &
   marker_name = .model_1.dummy_rear.to_rev  &
   active = on  &
   visibility = on  &
   name_visibility = on
!
marker create  &
   marker_name = .model_1.dummy_rear.to_trans  &
   location = (.model_1.X_rear), 0.0, (.model_1.Z_rollaxis_rear)  &
   orientation = 0.0, 0.0, 0.0
!
marker attributes  &
   marker_name = .model_1.dummy_rear.to_trans  &
   active = on  &
   visibility = on  &
   name_visibility = on
!
marker create  &
   marker_name = .model_1.dummy_rear.cm  &
   location = (.model_1.X_rear), 0.0, 0.1  &
   orientation = 0.0, 0.0, 0.0
!
marker attributes  &
   marker_name = .model_1.dummy_rear.cm  &
   active = on  &
   visibility = on  &
   name_visibility = on
!
part create rigid_body mass_properties  &
   part_name = .model_1.dummy_rear  &
   mass = 1.0e-3  &
   center_of_mass_marker = .model_1.dummy_rear.cm  &
   ixx = 1.0  &
   iyy = 1.0  &
   izz = 1.0  &
   ixy = 0.0  &
   izx = 0.0  &
   iyz = 0.0
!
!----------------------------------- Joints -----------------------------------!
!
!
constraint create joint revolute  &
   joint_name = .model_1.JOI_steer_left  &
   comments = " "  &
   i_marker_name = .model_1.steering_kingpin_left.CG  &
   j_marker_name = .model_1.front_axle.left
!
constraint attributes  &
   constraint_name = .model_1.JOI_steer_left  &
   active = on
!
constraint create joint revolute  &
   joint_name = .model_1.JOI_steer_right  &
   i_marker_name = .model_1.steering_kingpin_right.CG  &
   j_marker_name = .model_1.front_axle.right
!
constraint attributes  &
   constraint_name = .model_1.JOI_steer_right  &
   active = on
!
constraint create joint revolute  &
   joint_name = .model_1.rev_front  &
   i_marker_name = .model_1.dummy_fr.to_rev   &
   j_marker_name = .model_1.front_axle.front  
!
constraint attributes  &
   constraint_name = .model_1.rev_front  &
   active = on
!
constraint create joint translational  &
   joint_name = .model_1.trans_front  &
   i_marker_name = .model_1.dummy_fr.to_trans  &
   j_marker_name = .model_1.mainbody.to_trans_front
!
constraint attributes  &
   constraint_name = .model_1.trans_front  &
   active = on
!
constraint create joint revolute  &
   joint_name = .model_1.rev_rear  &
   i_marker_name = .model_1.dummy_rear.to_rev   &
   j_marker_name = .model_1.rear_axle.rear  
!
constraint attributes  &
   constraint_name = .model_1.rev_rear  &
   active = on
!
constraint create joint translational  &
   joint_name = .model_1.trans_rear  &
   i_marker_name = .model_1.dummy_rear.to_trans  &
   j_marker_name = .model_1.mainbody.to_trans_rear
!
constraint attributes  &
   constraint_name = .model_1.trans_rear  &
   active = on
!
!----------------------------------- Forces -----------------------------------!
!
!
force create element_like rotational_spring_damper  &
   spring_damper_name = .model_1.rot_spr_damp_front  &
   i_marker_name = .model_1.dummy_fr.to_rev  &
   j_marker_name = .model_1.front_axle.front &
   damping = 2050.0  &
   stiffness = 6.6E+004  &
   preload = 0.0  &
   displacement_at_preload = 0.0
!
force attributes  &
   force_name = .model_1.rot_spr_damp_front  &
   active = on
!
force create element_like translational_spring_damper  &
   spring_damper_name = .model_1.trans_spr_damp_front  &
   i_marker_name = .model_1.dummy_fr.to_trans  &
   j_marker_name = .model_1.mainbody.to_trans_front &
   damping = 3500.0  &
   stiffness = 4.0E+004  &
   preload = 8E+003  &
   displacement_at_preload = 0.1
!
force attributes  &
   force_name = .model_1.trans_spr_damp_front  &
   active = on
!
force create element_like translational_spring_damper  &
   spring_damper_name = .model_1.trans_spr_damp_rear  &
   i_marker_name = .model_1.dummy_rear.to_trans  &
   j_marker_name = .model_1.mainbody.to_trans_rear  &
   damping = 3500.0  &
   stiffness = 5.0E+004  &
   preload = 8000.0  &
   displacement_at_preload = 0.05
!
force attributes  &
   force_name = .model_1.trans_spr_damp_rear  &
   active = on
!
force create element_like rotational_spring_damper  &
   spring_damper_name = .model_1.rot_spr_damp_rear  &
   i_marker_name = .model_1.dummy_rear.to_rev  &
   j_marker_name = .model_1.rear_axle.rear  &
   damping = 2050.0  &
   stiffness = 2.75E+004  &
   preload = 0.0  &
   displacement_at_preload = 0.0
!
force attributes  &
   force_name = .model_1.rot_spr_damp_rear  &
   active = on
!
!---------------------------------- Motions -----------------------------------!
!
!
constraint create motion_generator  &
   motion_name = .model_1.MOT_left  &
   type_of_freedom = rotational  &
   joint_name = .model_1.JOI_steer_left  &
   function = ""
!
constraint attributes  &
   constraint_name = .model_1.MOT_left  &
   active = on
!
constraint create motion_generator  &
   motion_name = .model_1.MOT_right  &
   type_of_freedom = rotational  &
   joint_name = .model_1.JOI_steer_right  &
   function = ""
!
constraint attributes  &
   constraint_name = .model_1.MOT_right  &
   active = on
!
!---------------------------------- Requests ----------------------------------!
!
!
output_control create request  &
   request_name = .model_1.REQUEST_1  &
   component_names =   &
                     "Fr_DZ", "Re_DZ", "Fr_Fz", "Re_Fz", "Fz_AY", "Re_AY", "Fr_Mz", "Re_Mz"  &
   f1 = ""  &
   f2 = ""  &
   f3 = ""  &
   f4 = ""  &
   f5 = ""  &
   f6 = ""  &
   f7 = ""  &
   f8 = ""
!
output_control create request  &
   request_name = .model_1.REQUEST_3  &
   component_names = "X", "Y", "Z", "X_vel", "Y_vel", "Z_vel","",""  &
   f1 = ""  &
   f2 = ""  &
   f3 = ""  &
   f4 = ""  &
   f5 = ""  &
   f6 = ""
!
output_control create request  &
   request_name = .model_1.REQUEST_4  &
   component_names = "PITCH_rate", "ROLL_rate", "YAW_rate","","","","",""  &
   f1 = ""  &
   f2 = ""  &
   f3 = ""
!
!-------------------------- Adams/View UDE Instances --------------------------!
!
!
defaults coordinate_system  &
   default_coordinate_system = .model_1.ground
!
undo begin_block suppress = yes
!
ude create instance  &
   instance_name = .model_1.road_nr_1  &
   definition_name = .MDI.Forces.vpg_road  &
   location = 0.0, 0.0, 0.0  &
   orientation = 0.0, 0.0, 0.0
!
ude attributes  &
   instance_name = .model_1.road_nr_1  &
   color = DimGray  &
   visibility = on
!
ude create instance  &
   instance_name = .model_1.tyre_1  &
   definition_name = .MDI.Forces.vpg_tire  &
   location = (.model_1.X_front), (.model_1.Y_left), (.model_1.Z_front)  &
   orientation = 0.0, 1.5707963268, 0.0
!
ude create instance  &
   instance_name = .model_1.tyre_2  &
   definition_name = .MDI.Forces.vpg_tire  &
   location = (.model_1.X_front), (.model_1.Y_right), (.model_1.Z_front)  &
   orientation = 0.0, 1.5707963268, 0.0
!
ude create instance  &
   instance_name = .model_1.tyre_3  &
   definition_name = .MDI.Forces.vpg_tire  &
   location = (.model_1.X_rear), (.model_1.Y_left), (.model_1.Z_rear)  &
   orientation = 0.0, 1.5707963268, 0.0
!
ude create instance  &
   instance_name = .model_1.tyre_4  &
   definition_name = .MDI.Forces.vpg_tire  &
   location = (.model_1.X_rear), (.model_1.Y_right), (.model_1.Z_rear)  &
   orientation = 0.0, 1.5707963268, 0.0
!
!-------------------------- Adams/View UDE Instance ---------------------------!
!
!
variable modify  &
   variable_name = .model_1.road_nr_1.ref_marker  &
   object_value = .model_1.ground.road_nr_1_ref_1
!
variable modify  &
   variable_name = .model_1.road_nr_1.road_property_file  &
   string_value = "TNO_FlatRoad.rdf"
!
ude modify instance  &
   instance_name = .model_1.road_nr_1
!
!-------------------------- Adams/View UDE Instance ---------------------------!
!
!
variable modify  &
   variable_name = .model_1.tyre_1.cm_offset  &
   real_value = 0.0
!
variable modify  &
   variable_name = .model_1.tyre_1.center_offset  &
   real_value = 0.0
!
variable modify  &
   variable_name = .model_1.tyre_1.long_vel  &
   real_value = (.model_1.VX)
!
variable modify  &
   variable_name = .model_1.tyre_1.spin_vel  &
   real_value = (.model_1.WZ_front)
!
variable modify  &
   variable_name = .model_1.tyre_1.side  &
   string_value = "left"
!
variable modify  &
   variable_name = .model_1.tyre_1.road_property_file  &
   string_value = (.model_1.road_nr_1.road_property_file)
!
variable modify  &
   variable_name = .model_1.tyre_1.j_fmarker  &
   object_value = .model_1.ground.tyre_1_tire_jf_1
!
variable modify  &
   variable_name = .model_1.tyre_1.ref_marker  &
   object_value = (.model_1.road_nr_1.ref_marker.object_value)
!
variable modify  &
   variable_name = .model_1.tyre_1.wheel_tire_mass  &
   real_value = 20.0
!
variable modify  &
   variable_name = .model_1.tyre_1.Ixx_Iyy  &
   real_value = 1.0
!
variable modify  &
   variable_name = .model_1.tyre_1.Izz  &
   real_value = 2.0
!
variable modify  &
   variable_name = .model_1.tyre_1.property_file  &
   string_value = "TNO_car205_60R15.tir"
!
variable modify  &
   variable_name = .model_1.tyre_1.road_name  &
   string_value = (.model_1.road_nr_1)
!
ude modify instance  &
   instance_name = .model_1.tyre_1
!
!-------------------------- Adams/View UDE Instance ---------------------------!
!
!
variable modify  &
   variable_name = .model_1.tyre_2.cm_offset  &
   real_value = 0.0
!
variable modify  &
   variable_name = .model_1.tyre_2.center_offset  &
   real_value = 0.0
!
variable modify  &
   variable_name = .model_1.tyre_2.long_vel  &
   real_value = (.model_1.VX)
!
variable modify  &
   variable_name = .model_1.tyre_2.spin_vel  &
   real_value = (.model_1.WZ_front)
!
variable modify  &
   variable_name = .model_1.tyre_2.side  &
   string_value = "right"
!
variable modify  &
   variable_name = .model_1.tyre_2.road_property_file  &
   string_value = (.model_1.road_nr_1.road_property_file)
!
variable modify  &
   variable_name = .model_1.tyre_2.j_fmarker  &
   object_value = .model_1.ground.tyre_2_tire_jf_1
!
variable modify  &
   variable_name = .model_1.tyre_2.ref_marker  &
   object_value = (.model_1.road_nr_1.ref_marker.object_value)
!
variable modify  &
   variable_name = .model_1.tyre_2.wheel_tire_mass  &
   real_value = 20.0
!
variable modify  &
   variable_name = .model_1.tyre_2.Ixx_Iyy  &
   real_value = 1.0
!
variable modify  &
   variable_name = .model_1.tyre_2.Izz  &
   real_value = 2.0
!
variable modify  &
   variable_name = .model_1.tyre_2.property_file  &
   string_value = "TNO_car205_60R15.tir"
!
variable modify  &
   variable_name = .model_1.tyre_2.road_name  &
   string_value = (.model_1.road_nr_1)
!
ude modify instance  &
   instance_name = .model_1.tyre_2
!
!-------------------------- Adams/View UDE Instance ---------------------------!
!
!
variable modify  &
   variable_name = .model_1.tyre_3.cm_offset  &
   real_value = 0.0
!
variable modify  &
   variable_name = .model_1.tyre_3.center_offset  &
   real_value = 0.0
!
variable modify  &
   variable_name = .model_1.tyre_3.long_vel  &
   real_value = (.model_1.VX)
!
variable modify  &
   variable_name = .model_1.tyre_3.spin_vel  &
   real_value = (.model_1.WZ_rear)
!
variable modify  &
   variable_name = .model_1.tyre_3.side  &
   string_value = "left"
!
variable modify  &
   variable_name = .model_1.tyre_3.road_property_file  &
   string_value = (.model_1.road_nr_1.road_property_file)
!
variable modify  &
   variable_name = .model_1.tyre_3.j_fmarker  &
   object_value = .model_1.ground.tyre_3_tire_jf_1
!
variable modify  &
   variable_name = .model_1.tyre_3.ref_marker  &
   object_value = (.model_1.road_nr_1.ref_marker.object_value)
!
variable modify  &
   variable_name = .model_1.tyre_3.wheel_tire_mass  &
   real_value = 20.0
!
variable modify  &
   variable_name = .model_1.tyre_3.Ixx_Iyy  &
   real_value = 1.0
!
variable modify  &
   variable_name = .model_1.tyre_3.Izz  &
   real_value = 2.0
!
variable modify  &
   variable_name = .model_1.tyre_3.property_file  &
   string_value = "TNO_car205_60R15.tir"
!
variable modify  &
   variable_name = .model_1.tyre_3.road_name  &
   string_value = (.model_1.road_nr_1)
!
ude modify instance  &
   instance_name = .model_1.tyre_3
!
!-------------------------- Adams/View UDE Instance ---------------------------!
!
!
variable modify  &
   variable_name = .model_1.tyre_4.cm_offset  &
   real_value = 0.0
!
variable modify  &
   variable_name = .model_1.tyre_4.center_offset  &
   real_value = 0.0
!
variable modify  &
   variable_name = .model_1.tyre_4.long_vel  &
   real_value = (.model_1.VX)
!
variable modify  &
   variable_name = .model_1.tyre_4.spin_vel  &
   real_value = (.model_1.WZ_rear)
!
variable modify  &
   variable_name = .model_1.tyre_4.side  &
   string_value = "right"
!
variable modify  &
   variable_name = .model_1.tyre_4.road_property_file  &
   string_value = (.model_1.road_nr_1.road_property_file)
!
variable modify  &
   variable_name = .model_1.tyre_4.j_fmarker  &
   object_value = .model_1.ground.tyre_4_tire_jf_1
!
variable modify  &
   variable_name = .model_1.tyre_4.ref_marker  &
   object_value = (.model_1.road_nr_1.ref_marker.object_value)
!
variable modify  &
   variable_name = .model_1.tyre_4.wheel_tire_mass  &
   real_value = 20.0
!
variable modify  &
   variable_name = .model_1.tyre_4.Ixx_Iyy  &
   real_value = 1.0
!
variable modify  &
   variable_name = .model_1.tyre_4.Izz  &
   real_value = 2.0
!
variable modify  &
   variable_name = .model_1.tyre_4.property_file  &
   string_value = "TNO_car205_60R15.tir"
!
variable modify  &
   variable_name = .model_1.tyre_4.road_name  &
   string_value = (.model_1.road_nr_1)
!
ude modify instance  &
   instance_name = .model_1.tyre_4
!
undo end_block
!
!--------------------------- UDE Dependent Objects ----------------------------!
!
!
constraint create joint revolute  &
   joint_name = .model_1.JOINT_1  &
   i_marker_name = .model_1.steering_kingpin_left.tyre_left  &
   j_marker_name = .model_1.tyre_1.wheel_part.wheel_cm
!
constraint create joint revolute  &
   joint_name = .model_1.JOINT_2  &
   i_marker_name = .model_1.steering_kingpin_right.tyre_right  &
   j_marker_name = .model_1.tyre_2.wheel_part.wheel_cm
!
constraint create joint revolute  &
   joint_name = .model_1.JOINT_3  &
   i_marker_name = .model_1.rear_axle.left  &
   j_marker_name = .model_1.tyre_3.wheel_part.wheel_cm
!
constraint create joint revolute  &
   joint_name = .model_1.JOINT_4  &
   i_marker_name = .model_1.rear_axle.right  &
   j_marker_name = .model_1.tyre_4.wheel_part.wheel_cm
!
force create direct single_component_force  &
   single_component_force_name = .model_1.driving_torque_left  &
   type_of_freedom = rotational  &
   i_marker_name = .model_1.steering_kingpin_left.tyre_left  &
   j_marker_name = .model_1.tyre_1.wheel_part.wheel_cm  &
   action_only = on  &
   function = ""
!
force create direct single_component_force  &
   single_component_force_name = .model_1.driving_torque_right  &
   type_of_freedom = rotational  &
   i_marker_name = .model_1.steering_kingpin_right.tyre_right  &
   j_marker_name = .model_1.tyre_2.wheel_part.wheel_cm  &
   action_only = on  &
   function = ""
!---------------------------------- Accgrav -----------------------------------!
!
!
force create body gravitational  &
   gravity_field_name = ACC  &
   x_component_gravity = 0.0  &
   y_component_gravity = 0.0  &
   z_component_gravity = -10.0
!
!----------------------------- Analysis settings ------------------------------!
!
!
executive_control set numerical_integration_parameters  &
   model_name = model_1  &
   hmax_time_step = 1.0E-002
!
!---------------------------- ADAMS/View Variables ----------------------------!
!
!
variable create  &
   variable_name = .model_1.STEER  &
   real_value = 0.1
!
variable create  &
   variable_name = .model_1.TORQUE  &
   real_value = 0.0  &
   comments = "Drive torque"
!
!----------------------------- Simulation Scripts -----------------------------!
!
simulation script create  &
   sim_script_name = .model_1.SIM_SCRIPT_1  &
   type = auto_select  &
   initial_static = no  &
   number_of_steps = 1000 &
   end_time = 10.0
!
!---------------------------- Function definitions ----------------------------!
!
!
constraint modify motion_generator  &
   motion_name = .model_1.MOT_left  &
   function = "HAVSIN(time, 1.0, 0.0, 1.1, 1.0)*.model_1.STEER"
!
constraint modify motion_generator  &
   motion_name = .model_1.MOT_right  &
   function = "HAVSIN(time, 1.0, 0.0, 1.1, 1.0)*.model_1.STEER"
!
force modify direct single_component_force  &
   single_component_force_name = .model_1.driving_torque_left  &
   function = "HAVSIN(time, 1.0, 0.0, 1.1, 1.0)*.model_1.TORQUE"
!
force modify direct single_component_force  &
   single_component_force_name = .model_1.driving_torque_right  &
   function = "HAVSIN(time, 1.0, 0.0, 1.1, 1.0)*.model_1.TORQUE"
!
output_control modify request  &
   request_name = .model_1.REQUEST_1  &
   f1 = "DZ(.model_1.front_axle.request_marker_front, .model_1.dummy_fr.to_trans)"  &
   f2 = "DZ(.model_1.rear_axle.request_marker_rear, .model_1.dummy_rear.to_trans)"  &
   f3 = "SPDP(.model_1.trans_spr_damp_front, 0, 1, 0)"  &
   f4 = "SPDP(.model_1.trans_spr_damp_rear, 0, 1, 0)"  &
   f5 = "AX(.model_1.front_axle.CG, .model_1.mainbody.CG)"  &
   f6 = "AX(.model_1.rear_axle.CG, .model_1.mainbody.CG)"  &
   f7 = "-1*SPDP(.model_1.rot_spr_damp_front, 0, 8, .model_1.dummy_fr.to_rev)"  &
   f8 = "-1*SPDP(.model_1.rot_spr_damp_rear, 0, 8, .model_1.dummy_rear.to_rev)"
!
output_control modify request  &
   request_name = .model_1.REQUEST_3  &
   f1 = "DX(.model_1.mainbody.CG)"  &
   f2 = "DY(.model_1.mainbody.CG)"  &
   f3 = "DZ(.model_1.mainbody.CG)"  &
   f4 = "VX(.model_1.mainbody.CG, .model_1.ground.groundmarker, .model_1.mainbody.CG)"  &
   f5 = "VY(.model_1.mainbody.CG, .model_1.ground.groundmarker, .model_1.mainbody.CG)"  &
   f6 = "VZ(.model_1.mainbody.CG, .model_1.ground.groundmarker, .model_1.mainbody.CG)"
!
output_control modify request  &
   request_name = .model_1.REQUEST_4  &
   f1 = "WX(.model_1.mainbody.CG, .model_1.ground.groundmarker, .model_1.mainbody.CG)"  &
   f2 = "WY(.model_1.mainbody.CG, .model_1.ground.groundmarker, .model_1.mainbody.CG)"  &
   f3 = "WZ(.model_1.mainbody.CG, .model_1.ground.groundmarker, .model_1.mainbody.CG)"
!
!
!-------------------------- Adams/View Simulation conditions ---------------------------!
!
executive_control set numerical_integration_parameters  &
   model_name = model_1  &
   formulation = si2  &   
   error_tolerance = 1.0E-04  &
   hmax_time_step = 0.001   &
   integrator_type = gstiff
!
simulation set solver_preference = external
simulation set choice = fortran 
simulation set show_all_messages = yes
simulation single set update = none
simulation set save_files = yes
!
!
simulation set file_prefix="handling"
simulation single_run scripted  sim_script_name = .model_1.SIM_SCRIPT_1 reset_before_and_after = yes
! rename analysis
   entity modify entity = .model_1.Last_Run new = .model_1.handling