/// @arg valueid
/// @arg value

function tl_value_get_save_id(vid, val)
{
	if (tl_value_is_texture(vid) && val = 0)
		return "none"
	
	if (tl_value_is_obj(vid))
		return save_id_get(val)
	
	return val
}
