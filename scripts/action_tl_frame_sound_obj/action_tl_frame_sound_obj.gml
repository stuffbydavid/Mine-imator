/// action_tl_frame_sound_obj(object)
/// @arg object

function action_tl_frame_sound_obj(object)
{
	tl_value_set_start(action_tl_frame_sound_obj, false)
	tl_value_set(e_value.SOUND_OBJ, object, false)
	tl_value_set_done()
	tl_update_length()
}
