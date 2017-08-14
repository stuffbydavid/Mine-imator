/// temp_update_char_model()
/// @desc Gets the correct file and texture from the name and state.
///		  Also updates the affected timelines.

// TODO dont render missing models instead of errors

var model = mc_version.model_name_map[?char_model_name];

if (is_undefined(model))
	return 0
	
var vars = char_model_state_map;
	
// Set file and texture
with (model)
{
	var curfile, curtex;
	curfile = file
	curtex = ""
	
	// Texture in file < Texture in root < Texture in state (< Texture by user)
	if (file != null)
		curtex = file.texture
	if (texture != "")
		curtex = texture
	
	if (states_map != null)
	{
		var curstate = ds_map_find_first(states_map);
		while (!is_undefined(curstate))
		{
			log("curstate",curstate)
			if (!is_undefined(vars[?curstate]))
			{
				log("compare with vars")
				// This state has a set value, check if it matches any of the possibilities
				with (states_map[?curstate])
				{
					for (var v = 0; v < value_amount; v++)
					{
						log("value_name[v]",value_name[v])
						log("vars[?curstate]",vars[?curstate])
						if (vars[?curstate] != value_name[v])
							continue
							
						// Match found, get the properties and stop checking further values in this state
						
						if (value_file[v] != null)
						{
							curfile = value_file[v]
							if (curtex = "")
								curtex = curfile.texture
						}
								
						if (value_texture[v] != "")
							curtex = value_texture[v]
								
						break
					}
				}
			}
			curstate = ds_map_find_next(states_map, curstate)
		}
	}
	
	other.char_model_file = curfile
	other.char_model_texture_name = curtex
}

// Re-arrange timelines TODO
/*
temp_update_display_name()

with (obj_timeline) { // Rearrange hierarchy
	if (temp != other.id || part_of)
		continue
		
	for (var p = 0; p < part_amount; p++) // Set parent to root
		with (part[p])
			tl_parent_set(other.id)
			
	for (var p = 0; p < part_amount; p++) // Remove unused with 0 keyframe_amount
		with (part[p])
			if (p >= temp.char_model.part_amount && keyframe_amount = 0) 
				instance_destroy()
			
	for (var p = part_amount - 1; p >= 0; p--) { // Trim
		if (part[p])
			break
		part_amount--
	}
	
	for (var p = 0; p < temp.char_model.part_amount; p++) { // Add missing
		if (p < part_amount && part[p])
			continue
		with (new(obj_timeline)) {
			type = "bodypart"
			temp = other.temp
			bodypart = p
			part_of = other.id
			inherit_alpha = true
			inherit_color = true
			value_type_show[POSITION] = temp.char_model.part_show_position[p]
			other.part[p] = id
			other.part_amount = max(other.part_amount, p + 1)
			tl_parent_root()
		}
	}
	
	for (var p = temp.char_model.part_amount - 1; p >= 0; p--) { // Set parents
		var par = temp.char_model.part_parent[p];
		with (part[p]) {
			if (par < 0)
				tl_parent_set(other.id)
			else
				tl_parent_set(other.part[par])
			tl_update_type_name()
			tl_update_display_name()
			tl_update_value_types()
			tl_update_depth()
		}
	}
	
	tl_update_type_name()
	update_matrix = true
}*/
