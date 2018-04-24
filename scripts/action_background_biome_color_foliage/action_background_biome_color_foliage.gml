/// action_background_biome_color_foliage(color)
/// @arg color

var col;

if (history_undo)
	col = history_data.old_value
else if (history_redo)
	col = history_data.new_value
else
{
	col = argument0
	history_set_var(action_background_biome_color_foliage, background_biome_color_foliage, col, true)
}

background_biome_color_foliage = col

with (obj_resource)
	res_update_colors()

properties.library.preview.update = true