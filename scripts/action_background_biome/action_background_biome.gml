/// action_background_biome(biome)
/// @arg biome

function action_background_biome(biome)
{
	if (!history_undo && !history_redo)
		history_set_var(action_background_biome, background_biome, biome, false)
	
	background_biome = biome
	
	with (obj_resource)
		res_update_colors()
	
	properties.library.preview.update = true
}
