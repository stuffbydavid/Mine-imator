/// action_background_biome_variant(selected_variant)
/// @arg selected_variant

function action_background_biome_variant(variant)
{
	if (!history_undo && !history_redo)
		history_set_var(action_background_biome_variant, background_biome.selected_variant, variant, false)
	
	background_biome.selected_variant = variant
	
	with (obj_resource)
		res_update_colors()
	
	properties.library.preview.update = true
}
