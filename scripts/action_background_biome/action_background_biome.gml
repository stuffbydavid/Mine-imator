/// action_background_biome(biome)
/// @arg biome

var biome;

if (history_undo)
	biome = history_data.old_value
else if (history_redo)
	biome = history_data.new_value
else
{
	biome = argument0
	history_set_var(action_background_biome, background_biome, biome, false)
}

background_biome = biome

with (obj_resource)
	res_update_colors()

properties.library.preview.update = true
