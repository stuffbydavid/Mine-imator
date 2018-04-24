/// new_biome(name, tx, ty, hardcoded, grass, foliage, water, base)
/// @arg name
/// @arg tx
/// @arg ty
/// @arg hardcoded
/// @arg grass
/// @arg foliage
/// @arg water
/// @arg base

with (new(obj_biome))
{
	// Name
	name = argument0
	display_name = minecraft_asset_get_name("biome", name)
	
	// Coordinates
	txy[0] = argument1
	txy[1] = argument2
	
	// Color
	hardcoded = argument3
	color_grass = argument4
	color_foliage = argument5
	color_water = argument6
	
	// Variants
	biome_base = argument7
	biome_variants = null
	selected_variant = 0
	
	if (biome_base != null)
	{
		if (ds_exists(biome_base.biome_variants, ds_type_list))
			ds_list_add(biome_base.biome_variants, id)
		else
		{
			biome_base.biome_variants = ds_list_create()
			ds_list_add(biome_base.biome_variants, id)
		}
	}
		
		
	return id
}