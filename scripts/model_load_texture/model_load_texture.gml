/// model_load_texture(name)
/// @arg name

var name = argument0;

if (string_pos("minecraft:", name) > 0)
{
	texture = string_replace(name, "minecraft:", "")
	texture_minecraft = true
}
else
{
	// TODO: Store as external resource instead
	// texture = new_res(...)
	
	texture_minecraft = false
}