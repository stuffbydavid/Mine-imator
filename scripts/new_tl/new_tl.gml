/// new_tl(type)
/// @arg type

with (new(obj_timeline))
{
	type = argument0
	
	tl_update()
	
	tl_set_parent_root()
	tl_value_spawn()
	
	return id
}