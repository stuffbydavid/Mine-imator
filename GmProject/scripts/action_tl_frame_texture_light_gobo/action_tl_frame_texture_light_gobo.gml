/// action_tl_frame_texture_normal_obj(object)
/// @arg object

function action_tl_frame_texture_light_gobo(object)
{
	tl_value_set_start(action_tl_frame_texture_light_gobo, false)
	tl_value_set(e_value.TEXTURE_OBJ, object, false)
	tl_value_set_done()

}
