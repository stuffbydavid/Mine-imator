/// action_tl_frame_camrotatezangle(value, add)
/// @arg value
/// @arg add

tl_value_set_start(action_tl_frame_camrotatezangle, true)
tl_value_set(CAMROTATEZANGLE, argument0, argument1)

if (frame_editor.camera.look_at_rotate)
	tl_value_set(XROT, tl_edit.value[CAMROTATEZANGLE], false)

tl_value_set_done()
