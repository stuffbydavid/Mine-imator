/// minecraft_get_color(name)
/// @arg name
/// @desc Returns a Minecraft color based on given name

function minecraft_get_color(name)
{
	switch (name)
	{
		case "leather": return c_minecraft_leather;
		case "white": return c_minecraft_white;
		case "orange": return c_minecraft_orange;
		case "magenta": return c_minecraft_magenta;
		case "light_blue": return c_minecraft_light_blue;
		case "yellow": return c_minecraft_yellow;
		case "lime": return c_minecraft_lime;
		case "pink": return c_minecraft_pink;
		case "gray": return c_minecraft_gray;
		case "light_gray": return c_minecraft_light_gray;
		case "cyan": return c_minecraft_cyan;
		case "purple": return c_minecraft_purple;
		case "blue": return c_minecraft_blue;
		case "brown": return c_minecraft_brown;
		case "green": return c_minecraft_green;
		case "red": return c_minecraft_red;
		case "black": return c_minecraft_black;
		default:
		{
			if (string_contains(name, "#"))
				return hex_to_color(name)
			else
				return c_white
		}
	}
}