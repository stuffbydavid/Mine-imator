/// action_tl_frame_texture_material_obj(object)
/// @arg object

function action_tl_frame_texture_material_obj(object)
{
	tl_value_set_start(action_tl_frame_texture_material_obj, false)
	tl_value_set(e_value.TEXTURE_MATERIAL_OBJ, object, false)
	tl_value_set_done()
}
