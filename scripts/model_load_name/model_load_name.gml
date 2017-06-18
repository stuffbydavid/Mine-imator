/// model_load_name(name)
/// @arg name

name = argument0

if (string_count("mineimator:", name) > 0)
{
	name = string_replace(name, "mineimator:", "")
	name_key = true
}
else
	name_key = false