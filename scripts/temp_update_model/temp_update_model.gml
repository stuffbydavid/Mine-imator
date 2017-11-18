/// temp_update_model()
/// @desc Gets the correct file and textures from the name and state or resource.

model_file = null
		
// Each key in the map points to a part texture, key "" points to root texture
if (model_texture_name_map = null)
	model_texture_name_map = ds_map_create()
ds_map_clear(model_texture_name_map)
	
// Parts to hide
if (model_hide_list = null)
	model_hide_list = ds_list_create()
ds_list_clear(model_hide_list)

// Get model from Minecraft assets list
if (type != e_temp_type.MODEL)
{
	// Invalid model
	if (is_undefined(mc_assets.model_name_map[?model_name]))
		return 0
	
	// Set file and texture
	var tempstatevars, temptexnamemap, temphidelist, curfile;
	tempstatevars = model_state
	temptexnamemap = model_texture_name_map
	temphidelist = model_hide_list

	with (mc_assets.model_name_map[?model_name])
	{
		curfile = file
	
		if (texture_name_map != null)
			ds_map_merge(temptexnamemap, texture_name_map)
	
		if (states_map != null)
		{
			var curstate = ds_map_find_first(states_map);
			while (!is_undefined(curstate))
			{
				var val = state_vars_get_value(tempstatevars, curstate);
				if (val != "")
				{
					// This state has a set value, check if it matches any of the possibilities
					with (states_map[?curstate])
					{
						for (var v = 0; v < value_amount; v++)
						{
							if (val != value_name[v])
								continue
							
							// Match found, get the properties and stop checking further values in this state
						
							if (value_file[v] != null)
								curfile = value_file[v]
								
							if (value_texture_name_map[v] != null)
								ds_map_merge(temptexnamemap, value_texture_name_map[v], true)
								
							if (value_hide_list[v] != null)
								ds_list_merge(temphidelist, value_hide_list[v])
						
							break
						}
					}
				}
				curstate = ds_map_find_next(states_map, curstate)
			}
		}
	}
	
	model_file = curfile
}
else if (model != null)
	model_file = model.model_file
	
// Get default texture from file if not defined
if (model_file != null && is_undefined(model_texture_name_map[?""]))
	model_texture_name_map[?""] = model_file.texture_name