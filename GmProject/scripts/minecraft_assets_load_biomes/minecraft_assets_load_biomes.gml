/// minecraft_assets_load_biomes(list, map)
/// @arg list
/// @arg map
/// @desc Loads biomes from Minecraft version

function minecraft_assets_load_biomes(list, map)
{
	// Read biomes from map
	for (var b = 0; b < ds_list_size(map); b++)
	{
		var biome = map[|b]
		var biomeid;
		with (new_obj(obj_biome))
		{
			biomeid = id
			
			// Name
			name = biome[?"name"]
			
			// Is this a biome group?
			group = value_get_real(biome[?"group"], false)
			
			// Foliage
			txy = vec2(0)
			if (is_string(biome[?"foliage"]))
			{
				color_foliage = hex_to_color(biome[?"foliage"])
				color_dry_foliage = color_foliage
				color_grass = color_foliage
				hardcoded = true
			}
			else
			{
				color_foliage = c_white
				color_dry_foliage = c_white
				color_grass = c_white
				txy = value_get_point2D(biome[?"foliage"], vec2(0, 0))
				hardcoded = false
			}
			
			// Grass
			if (is_string(biome[?"grass"]))
				color_grass = hex_to_color(biome[?"grass"])
			
			// Dry foliage
			if (is_string(biome[?"dry_foliage"]))
				color_dry_foliage = hex_to_color(biome[?"dry_foliage"])
			
			// Water
			if (is_string(biome[?"water"]))
				color_water = hex_to_color(biome[?"water"])
			
			biome_base = null
			biome_variants = null
			variants_extend = false
			
			// Read possible variants
			if (ds_list_valid(biome[?"variant"]))
			{
				biome_variants = ds_list_create()
				var biomevariants = biome[?"variant"]
				for (var v = 0; v < ds_list_size(biomevariants); v++)
				{
					var variant = biomevariants[|v];
					with (new_obj(obj_biome))
					{
						// Name
						name = variant[?"name"]
						group = false
						
						// Foliage
						txy = array_copy_1d(other.txy)
						hardcoded = other.hardcoded
						color_foliage = other.color_foliage
						
						if (is_string(variant[?"foliage"]))
						{
							color_foliage = hex_to_color(variant[?"foliage"])
							hardcoded = true
						}
						else if (ds_list_valid(variant[?"foliage"]))
						{
							color_foliage = c_white
							txy = value_get_point2D(variant[?"foliage"], vec2(0, 0))
							hardcoded = false
						}
						
						// Grass
						if (is_string(variant[?"grass"]))
							color_grass = hex_to_color(variant[?"grass"])
						else
							color_grass = other.color_grass
						
						// Dry foliage
						if (is_string(variant[?"dry_foliage"]))
							color_dry_foliage = hex_to_color(variant[?"dry_foliage"])
						else
							color_dry_foliage = other.color_dry_foliage
						
						// Water
						if (is_string(variant[?"water"]))
							color_water = hex_to_color(variant[?"water"])
						else
							color_water = other.color_water
						
						biome_base = biomeid
						
						ds_list_add(biome_base.biome_variants, id)
					}
				}
			}
			
		}
		
		ds_list_add(biome_list, biomeid)
	}
}
