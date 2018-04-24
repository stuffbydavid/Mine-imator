/// action_background_biome_variant(selected_variant)
/// @arg selected_variant

var variant;

if (history_undo)
	variant = history_data.old_value
else if (history_redo)
	variant = history_data.new_value
else
{
	variant = argument0
	history_set_var(action_background_biome_variant, background_biome.selected_variant, variant, false)
}

background_biome.selected_variant = variant

with (obj_resource)
	res_update_colors()

properties.library.preview.update = true