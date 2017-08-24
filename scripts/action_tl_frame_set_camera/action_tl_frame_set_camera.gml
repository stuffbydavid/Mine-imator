/// action_tl_frame_set_camera(fov, rotate, rotatedistance, rotatexyangle, rotatezangle, dof, dofdepth, dofrange, doffadesize, width, height)
/// @arg fov
/// @arg rotate
/// @arg rotatedistance
/// @arg rotatexyangle
/// @arg rotatezangle
/// @arg dof
/// @arg dofdepth
/// @arg dofrange
/// @arg doffadesize
/// @arg width
/// @arg height

tl_value_set_start(action_tl_frame_set_camera, false)
tl_value_set(e_value.CAM_FOV, argument0, false)
tl_value_set(e_value.CAM_ROTATE, argument1, false)
tl_value_set(e_value.CAM_ROTATE_DISTANCE, argument2, false)
tl_value_set(e_value.CAM_ROTATE_ANGLE_XY, argument3, false)
tl_value_set(e_value.CAM_ROTATE_ANGLE_Z, argument4, false)
tl_value_set(e_value.CAM_DOF, argument5, false)
tl_value_set(e_value.CAM_DOF_DEPTH, argument6, false)
tl_value_set(e_value.CAM_DOF_RANGE, argument7, false)
tl_value_set(e_value.CAM_DOF_FADE_SIZE, argument8, false)
tl_value_set(e_value.CAM_WIDTH, argument9, false)
tl_value_set(e_value.CAM_HEIGHT, argument10, false)
tl_value_set_done()
