/// model_shape_update_color([part])
/// @arg [part]
/// @desc Updates Minecraft color palette colors of shapes in a model

if (model_file = null)
	return 0
	
if (model_color_name_map = null)
	return 0

var root;
root = model_file;
if (argument_count > 0)
	root = argument[0]

if (root.part_list = null)
	return 0

for (var p = 0; p < ds_list_size(root.part_list); p++)
{
	var part = root.part_list[|p];
	
	if (part.shape_list = null)
		continue
		
	for (var s = 0; s < ds_list_size(part.shape_list); s++)
	{
		var shape = part.shape_list[|s];
		if (ds_map_exists(model_color_name_map, shape.description))
		{
			var colorstring = model_color_name_map[? shape.description];
			var color;
			switch (colorstring)
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
			shape.minecraft_color = color
		}
	}
	model_shape_update_color(part)
}