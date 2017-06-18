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
tl_value_set(CAMFOV, argument0, false)
tl_value_set(CAMROTATE, argument1, false)
tl_value_set(CAMROTATEDISTANCE, argument2, false)
tl_value_set(CAMROTATEXYANGLE, argument3, false)
tl_value_set(CAMROTATEZANGLE, argument4, false)
tl_value_set(CAMDOF, argument5, false)
tl_value_set(CAMDOFDEPTH, argument6, false)
tl_value_set(CAMDOFRANGE, argument7, false)
tl_value_set(CAMDOFFADESIZE, argument8, false)
tl_value_set(CAMWIDTH, argument9, false)
tl_value_set(CAMHEIGHT, argument10, false)
tl_value_set_done()
