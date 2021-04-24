/// tl_value_get_save_id(valueid, value)
/// @arg valueid
/// @arg value

function tl_value_get_save_id(vid, val)
{
	if (vid = e_value.TEXTURE_OBJ && val = 0)
		return "none"
	
	if (vid = e_value.ATTRACTOR || vid = e_value.TEXTURE_OBJ || vid = e_value.SOUND_OBJ || vid = e_value.TEXT_FONT)
		return save_id_get(val)
	
	return val
}
