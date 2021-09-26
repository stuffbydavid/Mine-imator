/// tl_value_find_save_id(valueid, oldvalue, newvalue)
/// @arg valueid
/// @arg oldvalue
/// @arg newvalue

function tl_value_find_save_id(vid, oldval, newval)
{
	if (vid = e_value.SOUND_OBJ && oldval != null)
	{
		var obj = save_id_find(oldval);
		if (obj != null)
			obj.count--
	}
	
	if (tl_value_is_texture(vid) && newval = "none")
		newval = 0
	else if (vid = e_value.ATTRACTOR || tl_value_is_texture(vid) || vid = e_value.SOUND_OBJ || vid = e_value.TEXT_FONT)
		newval = save_id_find(newval)
	
	if (vid = e_value.SOUND_OBJ && newval != null)
		newval.count++
	
	return newval
}
