/// temp_update_model()
/// @desc Gets the correct file and texture from the name and state.

var model = mc_assets.model_name_map[?model_name];

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
	
	// Texture in file < Texture in root < Texture in state < Texture by user < Texture in part < Texture in shape
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