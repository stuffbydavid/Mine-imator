/// action_background_biome(biome)
/// @arg biome

function action_background_biome(biome)
{
	// Group object, select first biome in list instead
	var biomeobj = find_biome(biome);
	if (biomeobj.group)
		biome = biomeobj.biome_variants[|0].name
	
	if (!history_undo && !history_redo)
	{
		if (action_tl_select_single(null, e_tl_type.BACKGROUND))
		{
			tl_value_set_start(action_background_biome, true)
			tl_value_set(e_value.BG_BIOME, biome, false)
			tl_value_set_done()
			return 0
		}
		
		history_set_var(action_background_biome, background_biome, biome, true)
	}
	
	background_biome = biome
	
	with (obj_resource)
		res_update_colors()
	
	properties.library.preview.update = true
}
