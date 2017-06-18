/// action_tl_frame_camrotate(rotate)
/// @arg rotate

tl_value_set_start(action_tl_frame_camrotate, false)
tl_value_set(CAMROTATE, argument0, false)

if (frame_editor.camera.look_at_rotate)
{
	tl_value_set(ZROT, tl_edit.value[CAMROTATEXYANGLE], false)
	tl_value_set(XROT, tl_edit.value[CAMROTATEZANGLE], false)
}

tl_value_set_done()
