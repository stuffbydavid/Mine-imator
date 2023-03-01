/// action_tl_frame_path_offset_set_length()

function action_tl_frame_path_offset_set_length()
{
	var path = tl_edit.value[e_value.PATH_OBJ];
	
	tl_value_set_start(action_tl_frame_path_offset_set_length, false)
	tl_value_set(e_value.PATH_OFFSET, path.path_length, false)
	tl_value_set_done()
}
