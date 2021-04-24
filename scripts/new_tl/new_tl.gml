/// new_tl(type)
/// @arg type

function new_tl(tlype)
{
	with (new_obj(obj_timeline))
	{
		type = tlype
		
		tl_update()
		
		tl_set_parent_root()
		tl_value_spawn()
		
		return id
	}
}
