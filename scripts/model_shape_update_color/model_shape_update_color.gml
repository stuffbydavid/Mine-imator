/// model_shape_update_color()
/// @desc Updates Minecraft color palette colors of shapes in a model

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
	var color;
	switch (ds_map_find_value(model_color_name_map, key))
	{
		case "white": color = c_minecraft_white; break;
		case "orange": color = c_minecraft_orange; break;
		case "magenta": color = c_minecraft_magenta; break;
		case "light_blue": color = c_minecraft_light_blue; break;
		case "yellow": color = c_minecraft_yellow; break;
		case "lime": color = c_minecraft_lime; break;
		case "pink": color = c_minecraft_pink; break;
		case "gray": color = c_minecraft_gray; break;
		case "light_gray": color = c_minecraft_light_gray; break;
		case "cyan": color = c_minecraft_cyan; break;
		case "purple": color = c_minecraft_purple; break;
		case "blue": color = c_minecraft_blue; break;
		case "brown": color = c_minecraft_brown; break;
		case "green": color = c_minecraft_green; break;
		case "red": color = c_minecraft_red; break;
		case "black": color = c_minecraft_black; break;
		default: color = c_white;
	}
			
	ds_map_add(model_color_map, key, color)
	key = ds_map_find_next(model_color_name_map, key)
}