/// tl_new_part(part)
/// @arg part

function tl_new_part(part)
{
	with (new_obj(obj_timeline))
	{
		type = e_tl_type.BODYPART
		temp = other.temp
		
		model_part = part
		model_part_name = part.name
		
		part_of = other.id
		inherit_alpha = true
		inherit_color = true
		inherit_texture = true
		inherit_surface = true
		inherit_subsurface = true
		inherit_rot_point = true
		scale_resize = false
		lock_bend = part.lock_bend
		part_mixing_shapes = part.part_mixing_shapes
		colors_ext = part_mixing_shapes
		backfaces = part.backfaces
		
		part_parent_save_id = ""
		
		show_tool_position = part.show_position
		
		depth = part.depth
		
		tl_set_parent(other.id)
		tl_update_depth()
		tl_value_spawn()
		
		return id
	}
}
