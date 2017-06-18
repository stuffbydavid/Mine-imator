/// new_tl(type)
/// @arg type

with (new(obj_timeline))
{
	type = argument0
	
    tl_parent_root()
    tl_update_type_name()
    tl_update_display_name()
    tl_update_value_types()
    tl_update_rot_point()
    tl_update_depth()
    tl_value_spawn()
	
	return id
}