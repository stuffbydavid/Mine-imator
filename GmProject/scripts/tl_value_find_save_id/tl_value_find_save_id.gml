/// @arg valueid
/// @arg oldvalue
/// @arg newvalue

function tl_value_find_save_id(vid, oldval, newval)
{
	if (tl_value_is_texture(vid) && newval = "none")
		return 0
	
	if (vid = e_value.PATH_OBJ ||
		vid = e_value.ATTRACTOR ||
		vid = e_value.IK_TARGET ||
		vid = e_value.IK_TARGET_ANGLE ||
		tl_value_is_texture(vid) ||
		vid = e_value.SOUND_OBJ ||
		vid = e_value.TEXT_FONT)
		return save_id_find(newval)
	
	return newval
}
