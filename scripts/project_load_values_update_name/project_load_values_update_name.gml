/// project_load_values_update_name(name)
/// @arg name

var name = argument0;

if (load_format < e_project.FORMAT_130_AL10)
{
	if (name = "BG_SKY_CLOUDS_Z")
		return "BG_SKY_CLOUDS_HEIGHT"
}
