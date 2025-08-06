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
   size_of_icons = 0.14  &
   spacing_for_grid = 0.14
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
!-------------------------------- Data storage --------------------------------!
!
!
!---------------------------- Adams/View Variables ----------------------------!
!
!
variable create  &
   variable_name = .model_1.Vx  &
   units = "no_units"  &
   real_value = 10.0
!
variable create  &
   variable_name = .model_1.Oy  &
   units = "no_units"  &
   real_value = 34.0
!
variable create  &
   variable_name = .model_1.hcg  &
   units = "no_units"  &
   real_value = 0.295
!
variable create  &
   variable_name = .model_1.camber  &
   units = "no_units"  &
   real_value = (20*PI/180)
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
   marker_name = .model_1.ground.road_nr_1_ref_1  &
   adams_id = 5  &
   location = 0.0, 0.0, 0.0  &
   orientation = 0.0, 0.0, 0.0
!
marker create  &
   marker_name = .model_1.ground.MARKER_19  &
   adams_id = 19  &
   location = 0.0, 0.0, (.model_1.hcg)  &
   orientation = 1.5707963268, 1.5707963268, (.model_1.camber)
!
marker create  &
   marker_name = .model_1.ground.VPG_road_ref_1  &
   adams_id = 22  &
   location = 0.0, 0.0, 0.0  &
   orientation = 0.0, 0.0, 0.0
!
marker attributes  &
   marker_name = .model_1.ground.VPG_road_ref_1  &
   visibility = off
!
! ****** Floating Markers for current part ******
!
floating_marker create  &
   floating_marker_name = .model_1.ground.tyre_left_tire_jf_1  &
   adams_id = 23
!
!----------------------------------- dummy ------------------------------------!
!
!
defaults coordinate_system  &
   default_coordinate_system = .model_1.ground
!
part create rigid_body name_and_position  &
   part_name = .model_1.dummy  &
   adams_id = 14  &
   location = 0.0, 0.0, (.model_1.hcg)  &
   orientation = 0.0, (.model_1.camber), 0.0
!
part create rigid_body initial_velocity  &
   part_name = .model_1.dummy  &
   vx = (.model_1.Vx)
!
defaults coordinate_system  &
   default_coordinate_system = .model_1.dummy
!
! ****** Markers for current part ******
!
marker create  &
   marker_name = .model_1.dummy.MARKER_3  &
   adams_id = 15  &
   location = 0.0, -0.15, 0.0  &
   orientation = 3.1415926536, 1.5707963268, 1.5707963268
!
marker create  &
   marker_name = .model_1.dummy.cm  &
   adams_id = 24  &
   location = 0.0, 0.0, 0.0  &
   orientation = 0.0, 0.0, 0.0
!
marker create  &
   marker_name = .model_1.dummy.MARKER_18  &
   adams_id = 18  &
   location = 0.0, 0.0, 0.0  &
   orientation = 1.5707963268, 1.5707963268, 0.0
!
marker create  &
   marker_name = .model_1.dummy.MARKER_21  &
   adams_id = 21  &
   location = 0.0, 0.0, 0.0  &
   orientation = 0.0, 1.5707963268, 0.0
!
part create rigid_body mass_properties  &
   part_name = .model_1.dummy  &
   mass = 1e-3  &
   center_of_mass_marker = .model_1.dummy.cm  &
   ixx = 1.0e-3  &
   iyy = 1.0e-3  &
   izz = 1.0e-3  &
   ixy = 0.0  &
   izx = 0.0  &
   iyz = 0.0
!
! ****** Graphics for current part ******
!
geometry create shape cylinder  &
   cylinder_name = .model_1.dummy.CYLINDER_1  &
   adams_id = 19  &
   center_marker = .model_1.dummy.MARKER_3  &
   angle_extent = 6.2831853072  &
   length = 0.3000770568  &
   radius = 3.7509632096E-002  &
   side_count_for_body = 20  &
   segment_count_for_ends = 20
!
part attributes  &
   part_name = .model_1.dummy  &
   color = MAIZE  &
   name_visibility = off
!
!----------------------------------- Joints -----------------------------------!
!
!
constraint create joint translational  &
   joint_name = .model_1.LONGDISPW  &
   adams_id = 2  &
   i_marker_name = .model_1.dummy.MARKER_18  &
   j_marker_name = .model_1.ground.MARKER_19
!
constraint attributes  &
   constraint_name = .model_1.LONGDISPW  &
   name_visibility = off
!
!----------------------------------- Forces -----------------------------------!
!
!
!---------------------------------- Motions -----------------------------------!
!
!
constraint create motion_generator  &
   motion_name = .model_1.mLONGDISPW  &
   adams_id = 4  &
   type_of_freedom = translational  &
   joint_name = .model_1.LONGDISPW  &
   function = ""
!
constraint attributes  &
   constraint_name = .model_1.mLONGDISPW  &
   name_visibility = off
!
!----------------------------- Simulation Scripts -----------------------------!
!
!
simulation script create  &
   sim_script_name = .model_1.SIM_SCRIPT_1  &
   solver_commands = "! Insert ACF commands here:",  &
                     "Preferences/SOLVERBIAS=F77",  &
                     "SIMULATE/DYNAMIC, END=1.0, STEPS=1000"
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
   instance_name = .model_1.VPG_road  &
   definition_name = .MDI.Forces.vpg_road  &
   location = 0.0, 0.0, 0.0  &
   orientation = 0.0, 0.0, 0.0
!
ude attributes  &
   instance_name = .model_1.VPG_road  &
   color = DimGray  &
   visibility = on
!
ude create instance  &
   instance_name = .model_1.tyre_left  &
   definition_name = .MDI.Forces.vpg_tire  &
   location = 0.0, 0.0, (.model_1.hcg)  &
   orientation = 0.0, (1.5707963268 + .model_1.camber), 0.0
!
marker create  &
   marker_name = .model_1.tyre_left.wheel_part.MARKER_20  &
   adams_id = 20  &
   location = 0.0, 0.0, (.model_1.hcg-.model_1.hcg)  &
   orientation = 0.0, (.model_1.camber-.model_1.camber) , 0.0
!
!-------------------------- Adams/View UDE Instance ---------------------------!
!
!
variable modify  &
   variable_name = .model_1.VPG_road.ref_marker  &
   object_value = .model_1.ground.VPG_road_ref_1
!
variable modify  &
   variable_name = .model_1.VPG_road.road_property_file  &
   string_value = "TNO_PlankRoad_2D.rdf"
!
variable modify  &
   variable_name = .model_1.VPG_road.road_graphics  &
   string_value = "off"
!
ude modify instance  &
   instance_name = .model_1.VPG_road
!
!-------------------------- Adams/View UDE Instance ---------------------------!
!
!
variable modify  &
   variable_name = .model_1.tyre_left.cm_offset  &
   real_value = 0.0
!
variable modify  &
   variable_name = .model_1.tyre_left.center_offset  &
   real_value = 0.0
!
variable modify  &
   variable_name = .model_1.tyre_left.long_vel  &
   real_value = (.model_1.Vx)
!
variable modify  &
   variable_name = .model_1.tyre_left.spin_vel  &
   real_value = (.model_1.Oy)
!
variable modify  &
   variable_name = .model_1.tyre_left.side  &
   string_value = "left"
!
variable modify  &
   variable_name = .model_1.tyre_left.road_property_file  &
   string_value = (.model_1.VPG_road.road_property_file)
!
variable modify  &
   variable_name = .model_1.tyre_left.j_fmarker  &
   object_value = .model_1.ground.tyre_left_tire_jf_1
!
variable modify  &
   variable_name = .model_1.tyre_left.ref_marker  &
   object_value = (.model_1.VPG_road.ref_marker.object_value)
!
variable modify  &
   variable_name = .model_1.tyre_left.wheel_tire_mass  &
   real_value = 10.0
!
variable modify  &
   variable_name = .model_1.tyre_left.Ixx_Iyy  &
   real_value = 1.0
!
variable modify  &
   variable_name = .model_1.tyre_left.Izz  &
   real_value = 0.3021
!
variable modify  &
   variable_name = .model_1.tyre_left.property_file  &
   string_value = "TNO_mc180_55ZR17_ride.tir"
!
variable modify  &
   variable_name = .model_1.tyre_left.road_name  &
   string_value = (.model_1.VPG_road)
!
ude modify instance  &
   instance_name = .model_1.tyre_left
!
undo end_block
!
!--------------------------- UDE Dependent Objects ----------------------------!
!
!
constraint create joint revolute  &
   joint_name = .model_1.WHROTANG  &
   adams_id = 3  &
   i_marker_name = .model_1.tyre_left.wheel_part.MARKER_20  &
   j_marker_name = .model_1.dummy.MARKER_21
!
constraint attributes  &
   constraint_name = .model_1.WHROTANG  &
   name_visibility = off
!
!---------------------------------- Accgrav -----------------------------------!
!
!
force create body gravitational  &
   gravity_field_name = ACCGRAV_1  &
   x_component_gravity = 0.0  &
   y_component_gravity = 0.0  &
   z_component_gravity = -9.81
!
!----------------------------- Analysis settings ------------------------------!
!
!
!---------------------------- Function definitions ----------------------------!
!
!
constraint modify motion_generator  &
   motion_name = .model_1.mLONGDISPW  &
   function = "(.model_1.Vx*time)"
!
!-------------------------- Adams/View UDE Instance ---------------------------!
!
!
ude modify instance  &
   instance_name = .model_1.VPG_road
!
!-------------------------- Adams/View UDE Instance ---------------------------!
!
!
ude modify instance  &
   instance_name = .model_1.tyre_left
!
!---------------------------------- Requests ----------------------------------!
!
!
output_control create request  &
   request_name = .model_1.Forces_Moments_Tydex_C  &
   adams_id = 1  &
   i_marker_name = .model_1.dummy.MARKER_21  &
   j_marker_name = .model_1.tyre_left.wheel_part.MARKER_20  &
!   r_marker_name = .model_1.dummy.cm  &
   output_type = force
!
output_control create request  &
   request_name = .model_1.omega  &
   adams_id = 2  &
   i_marker_name = .model_1.tyre_left.wheel_part.MARKER_20  &
   j_marker_name = .model_1.dummy.MARKER_21  &
   r_marker_name = .model_1.dummy.cm  &
   output_type = velocity
!
!------------------------- Part IC Reference Markers --------------------------!
!
!
part modify rigid_body initial_velocity  &
   part_name = .model_1.tyre_left.wheel_part  &
   vm = .model_1.tyre_left.wheel_part.wheel_cm  &
   wm = .model_1.tyre_left.wheel_part.wheel_cm
!
!--------------------------- Expression definitions ---------------------------!
!
model display  &
   model_name = model_1
!
!--------------------------- SET VIEW ORIENTATION -----------------------------!
!
view management orient  &
   view = Right  &
   up_axis = Z_pos  &
   forward_axis = Y_pos
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
simulation set file_prefix="MFSwift_for_motorcycle"
simulation single_run scripted  sim_script_name = .model_1.SIM_SCRIPT_1 reset_before_and_after = yes
! rename analysis
   entity modify entity = .model_1.Last_Run new = .model_1.MFSwift_for_motorcycle