/// menu_biome_init(menu)
/// @arg menu

function menu_biome_init(menu)
{
	list_init_start()
	
	var selectedbiome, biome;
	selectedbiome = find_biome(menu.menu_value)
	
	// Extend variant list if needed
	if (selectedbiome.biome_base != null && menu.menu_ani = 0)
		selectedbiome.biome_base.variants_extend = true
	
	// Add biomes with variants
	for (var b = 0; b < ds_list_size(biome_list); b++)
	{
		biome = biome_list[|b]
		
		menu_add_item(biome.name, minecraft_asset_get_name("biome", biome.name))
		
		if (biome.biome_variants != null && ds_list_size(biome.biome_variants) > 0)
		{
			list_item_add_action(list_item_last, string(biome) + "extend", menu_item_set_extend, biome.variants_extend, biome, null, "left", biome.variants_extend ? "tooltiptlcollapse" : "tooltiptlexpand", spr_chevron_ani)
			
			if (biome.variants_extend)
			{
				for (var v = 0; v < ds_list_size(biome.biome_variants); v++)
				{
					if (biome.biome_variants[|v].name = "normal")
						continue
				
					menu_add_item(biome.biome_variants[|v].name, minecraft_asset_get_name("biome", biome.biome_variants[|v].name))
					list_item_last.indent = 32
				}
			}
		}
		else
			list_item_last.indent = 20
	}
	
	return list_init_end()
}
