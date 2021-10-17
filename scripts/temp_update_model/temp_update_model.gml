/// temp_update_model()
/// @desc Gets the correct file and textures from the name and state or resource.

function temp_update_model()
{
	model_file = null
	
	// Each key in the map points to a part texture, key "" points to root texture
	if (model_texture_name_map = null)
		model_texture_name_map = ds_map_create()
	ds_map_clear(model_texture_name_map)
	
	if (model_texture_material_name_map = null)
		model_texture_material_name_map = ds_map_create()
	ds_map_clear(model_texture_material_name_map)
	
	if (model_tex_normal_name_map = null)
		model_tex_normal_name_map = ds_map_create()
	ds_map_clear(model_tex_normal_name_map)
	
	// Each key in the map points to a shape texture
	if (model_shape_texture_name_map = null)
		model_shape_texture_name_map = ds_map_create()
	ds_map_clear(model_shape_texture_name_map)
	
	if (model_shape_texture_material_name_map = null)
		model_shape_texture_material_name_map = ds_map_create()
	ds_map_clear(model_shape_texture_material_name_map)
	
	if (model_shape_tex_normal_name_map = null)
		model_shape_tex_normal_name_map = ds_map_create()
	ds_map_clear(model_shape_tex_normal_name_map)
	
	// Parts to hide
	if (model_hide_list = null)
		model_hide_list = ds_list_create()
	ds_list_clear(model_hide_list)
	
	// Shapes to hide
	if (model_shape_hide_list = null)
		model_shape_hide_list = ds_list_create()
	ds_list_clear(model_shape_hide_list)
	
	// Minecraft pallete color
	if (model_color_name_map = null)
		model_color_name_map = ds_map_create()
	ds_map_clear(model_color_name_map)
	
	// Get model from Minecraft assets list
	if (type != e_temp_type.MODEL)
	{
		// Invalid model
		if (is_undefined(mc_assets.model_name_map[?model_name]))
			return 0
		
		// Set file and texture
		var tempstatevars, temptexnamemap, temptexmatnamemap, temptexnormnamemap, tempshapetexnamemap, tempshapetexmatnamemap, tempshapetexnormnamemap, tempcolornamemap, temphidelist, tempshapehidelist, curfile;
		tempstatevars = model_state
		
		temptexnamemap = model_texture_name_map
		temptexmatnamemap = model_texture_material_name_map
		temptexnormnamemap = model_tex_normal_name_map
		
		tempshapetexnamemap = model_shape_texture_name_map
		tempshapetexmatnamemap = model_shape_texture_material_name_map
		tempshapetexnormnamemap = model_shape_tex_normal_name_map
		
		tempcolornamemap = model_color_name_map
		temphidelist = model_hide_list
		tempshapehidelist = model_shape_hide_list
		
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
								
								if (value_texture_material_name_map[v] != null)
									ds_map_merge(temptexmatnamemap, value_texture_material_name_map[v], true)
								
								if (value_tex_normal_name_map[v] != null)
									ds_map_merge(temptexnormnamemap, value_tex_normal_name_map[v], true)
								
								if (value_shape_texture_name_map[v] != null)
									ds_map_merge(tempshapetexnamemap, value_shape_texture_name_map[v], true)
								
								if (value_shape_texture_material_name_map[v] != null)
									ds_map_merge(tempshapetexmatnamemap, value_shape_texture_material_name_map[v], true)
								
								if (value_shape_tex_normal_name_map[v] != null)
									ds_map_merge(tempshapetexnormnamemap, value_shape_tex_normal_name_map[v], true)
								
								if (value_hide_list[v] != null)
									ds_list_merge(temphidelist, value_hide_list[v])
								
								if (value_shape_hide_list[v] != null)
									ds_list_merge(tempshapehidelist, value_shape_hide_list[v])
								
								if (value_color_name_map[v] != null)
									ds_map_merge(tempcolornamemap, value_color_name_map[v], true)
								
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
	
	if (model_file != null && is_undefined(model_texture_material_name_map[?""]))
		model_texture_material_name_map[?""] = model_file.texture_material_name
	
	if (model_file != null && is_undefined(model_tex_normal_name_map[?""]))
		model_tex_normal_name_map[?""] = model_file.texture_normal_name
	
	model_shape_update_color()
}
