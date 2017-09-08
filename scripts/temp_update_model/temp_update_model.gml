/// temp_update_model()
/// @desc Gets the correct file and textures from the name and state.

var model = mc_assets.model_name_map[?model_name];

// Each key in the map points to a part texture, key "" points to root texture
if (model_texture_name_map = null)
	model_texture_name_map = ds_map_create()
ds_map_clear(model_texture_name_map)

// Invalid model
if (is_undefined(model))
{
	model_file = null
	return 0
}
	
// Set file and texture
var tempstatevars, temptexnamemap, curfile;
tempstatevars = model_state_map
temptexnamemap = model_texture_name_map

with (model)
{
	curfile = file
	
	if (texture_name_map != null)
		ds_map_merge(temptexnamemap, texture_name_map)
	
	if (states_map != null)
	{
		var curstate = ds_map_find_first(states_map);
		while (!is_undefined(curstate))
		{
			if (!is_undefined(tempstatevars[?curstate]))
			{
				// This state has a set value, check if it matches any of the possibilities
				with (states_map[?curstate])
				{
					for (var v = 0; v < value_amount; v++)
					{
						if (tempstatevars[?curstate] != value_name[v])
							continue
							
						// Match found, get the properties and stop checking further values in this state
						
						if (value_file[v] != null)
							curfile = value_file[v]
								
						if (value_texture_name_map[v] != null)
							ds_map_merge(temptexnamemap, value_texture_name_map[v], true)
								
						break
					}
				}
			}
			curstate = ds_map_find_next(states_map, curstate)
		}
	}
}
	
model_file = curfile
	
// Get default texture from file if not defined
if (model_file != null && is_undefined(model_texture_name_map[?""]))
	model_texture_name_map[?""] = curfile.texture_name