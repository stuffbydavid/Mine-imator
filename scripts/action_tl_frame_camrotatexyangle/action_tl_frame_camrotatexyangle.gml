/// action_tl_frame_camrotatexyangle(value, add)
/// @arg value
/// @arg add

tl_value_set_start(action_tl_frame_camrotatexyangle, true)
tl_value_set(CAMROTATEXYANGLE, argument0, argument1)

if (frame_editor.camera.look_at_rotate)
	tl_value_set(ZROT, tl_edit.value[CAMROTATEXYANGLE], false)

tl_value_set_done()
