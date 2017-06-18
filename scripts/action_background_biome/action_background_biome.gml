/// action_background_biome(biome)
/// @arg biome

var biome;

if (history_undo)
	biome = history_data.oldval
else if (history_redo)
	biome = history_data.newval
else
{
	biome = argument0
	history_set_var(action_background_biome, background_biome, biome, false)
}

background_biome = biome
with (obj_resource)
	res_update_colors()
properties.library.preview.update = true
