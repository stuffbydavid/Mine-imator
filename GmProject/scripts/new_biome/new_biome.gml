/// new_biome(name, tx, ty, hardcoded, grass, foliage, dryfoliage, water, base)
/// @arg name
/// @arg tx
/// @arg ty
/// @arg hardcoded
/// @arg grass
/// @arg foliage
/// @arg dryfoliage
/// @arg water
/// @arg base

function new_biome(name, tx, ty, hardcoded, grass, foliage, dryfoliage, water, base)
{
	with (new_obj(obj_biome))
	{
		// Name
		id.name = argument0
		group = false
		display_name = minecraft_asset_get_name("biome", name)
		
		// Coordinates
		txy[0] = tx
		txy[1] = ty
		
		// Color
		id.hardcoded = hardcoded
		color_grass = grass
		color_foliage = foliage
		color_dry_foliage = dryfoliage
		color_water = water
		
		// Variants
		biome_base = base
		biome_variants = null
		selected_variant = 0
		
		if (biome_base != null)
		{
			if (biome_variants != null)
			{
				ds_list_add(biome_base.biome_variants, id)
			}
			else
			{
				biome_base.biome_variants = ds_list_create()
				ds_list_add(biome_base.biome_variants, id)
			}
		}
		
		return id
	}
}
