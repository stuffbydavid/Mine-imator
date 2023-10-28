/// model_shape_update_color()
/// @desc Updates Minecraft color palette colors of shapes in a model

function model_shape_update_color()
{
	if (model_file = null)
		return 0
	
	if (model_color_name_map = null)
		return 0
	
	if (model_color_map = null)
		model_color_map = ds_map_create()
	else
		ds_map_clear(model_color_map)
	
	var key = ds_map_find_first(model_color_name_map)
	while (!is_undefined(key))
	{
		var color = minecraft_get_color(ds_map_find_value(model_color_name_map, key));
		
		ds_map_add(model_color_map, key, color)
		key = ds_map_find_next(model_color_name_map, key)
	}
}
