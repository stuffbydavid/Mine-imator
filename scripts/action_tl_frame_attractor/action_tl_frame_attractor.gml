/// action_tl_frame_attractor(attractor)
/// @arg attractor

var attr = argument0;

if (attr = app)
	attr = null

tl_value_set_start(action_tl_frame_attractor, false)
tl_value_set(e_value.ATTRACTOR, argument0, false)
tl_value_set_done()
