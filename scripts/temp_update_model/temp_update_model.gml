/// temp_update_model()
/// @desc Gets the correct file and texture from the name and state.
///		  Also updates the affected timelines.

var model = mc_version.model_name_map[?model_name];

if (is_undefined(model))
{
	model_file = null
	model_texture_name = ""
	return 0
}
	
var vars = model_state_map;
	
// Set file and texture
with (model)
{
	var curfile, curtexname;
	curfile = file
	curtexname = ""
	
	// Texture in file < Texture in root < Texture in state (< Texture by user)
	if (file != null)
		curtexname = file.texture_name
	if (texture_name != "")
		curtexname = texture_name
	
	if (states_map != null)
	{
		var curstate = ds_map_find_first(states_map);
		while (!is_undefined(curstate))
		{
			if (!is_undefined(vars[?curstate]))
			{
				// This state has a set value, check if it matches any of the possibilities
				with (states_map[?curstate])
				{
					for (var v = 0; v < value_amount; v++)
					{
						if (vars[?curstate] != value_name[v])
							continue
							
						// Match found, get the properties and stop checking further values in this state
						
						if (value_file[v] != null)
						{
							curfile = value_file[v]
							if (curtexname = "")
								curtexname = curfile.texture_name
						}
								
						if (value_texture_name[v] != "")
							curtexname = value_texture_name[v]
								
						break
					}
				}
			}
			curstate = ds_map_find_next(states_map, curstate)
		}
	}
	
	other.model_file = curfile
	other.model_texture_name = curtexname
}

// Update timelines
with (obj_timeline)
{
	if (temp != other.id || part_of != null)
		continue
			
	// Remove empty timelines and set others to root
	for (var p = 0; p < ds_list_size(part_list); p++)
	{
		with (part_list[|p])
		{
			// Check if unused
			if (ds_list_size(keyframe_list) = 0)
			{
				var unused = true;
				
				for (var mp = 0; mp < ds_list_size(temp.model_file.file_part_list); mp++)
				{
					if (temp.model_file.file_part_list[|mp].name = model_part_name)
					{
						unused = false
						break
					}
				}
				
				if (unused)
				{
					instance_destroy()
					p--
					continue
				}
			}
			
			model_part = null
			tl_set_parent(other.id)
			tl_update_value_types()
			tl_update_type_name()
			tl_update_display_name()
		}
	}
	
	// Add missing parts
	for (var mp = 0; mp < ds_list_size(temp.model_file.file_part_list); mp++)
	{
		// Check if there is a previous body part with the 
		// same name, and re-use that one if that's the case
		var part, tlexists;
		part = temp.model_file.file_part_list[|mp]
		tlexists = false
		
		for (var p = 0; p < ds_list_size(part_list); p++)
		{
			if (part_list[|p].model_part_name = part.name)
			{
				tlexists = true
				break
			}	
		}
		
		// Otherwise create a timeline for it
		if (!tlexists)
			tl_new_part(part)
	}
	
	tl_update_part_list(temp.model_file, id)
	tl_update_type_name()
	tl_update_display_name()
	update_matrix = true
}