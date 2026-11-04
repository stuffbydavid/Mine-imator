/// @arg valueid
/// @arg oldvalue
/// @arg newvalue

function tl_value_find_save_id(vid, oldval, newval)
{
	if (tl_value_is_texture(vid) && newval = "none")
		return 0
	
	if (tl_value_is_obj(vid))
		return save_id_find(newval)
	
	return newval
}
