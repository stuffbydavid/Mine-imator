/// @desc Create an empty structure at a position with an unique name.
/// @arg position

function tl_new_structure(pos)
{
	with (new_tl(e_tl_type.STRUCTURE))
	{
		// Name the new structure
		var basename, suffix, found;
		basename = text_get("build_tool/structure")
		suffix = 2
		name = basename
					
		found = true
		while (found)
		{
			found = false
			with (obj_timeline)
				if (id != other.id && name = other.name)
					found = true
						
			if (found)
			{
				name = basename + " " + string(suffix)
				suffix++
			}
		}
		
		animated = false

		texture_filtering = true
		inherit_rot_point = true
		inherit_alpha = true
		inherit_color = true
		inherit_texture = true
		
		tl_value_set_vec3(e_value.POS_X, pos)
		tl_value_set_vec3(e_value.POS_X, pos, true)
		tl_update_display_name()
		
		return id
	}
}
