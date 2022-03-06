/// action_tl_frame_path(path)
/// @arg path

function action_tl_frame_path(path)
{
	tl_value_set_start(action_tl_frame_path, false)
	tl_value_set(e_value.PATH_OBJ, path, false)
	tl_value_set_done()
}
