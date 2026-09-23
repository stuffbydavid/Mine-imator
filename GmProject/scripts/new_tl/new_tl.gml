/// new_tl(type)
/// @arg type

function new_tl(tlype)
{
	with (new_obj(obj_timeline))
	{
		type = tlype
		has_temp = (type < e_temp_type.amount)
		animated = !type_is_block(type)
		if (type = e_tl_type.BLOCK)
			has_temp = false
		
		tl_update()
		
		tl_set_parent_root()
		tl_value_spawn()
		
		return id
	}
}
