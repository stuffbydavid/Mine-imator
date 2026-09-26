/// minecraft_assets_load_biomes(list, biomes, dimensionkey)
/// @arg list
/// @arg biomes
/// @arg dimensionkey
/// @desc Loads biomes from Minecraft version

function minecraft_assets_load_biomes(list, biomes, dimensionkey)
{
	if (!ds_list_valid(biomes))
		return 0

	// Read biomes from list
	for (var b = 0; b < ds_list_size(biomes); b++)
	{
		var biome, biomeid;
		biome = biomes[|b]
		with (new_obj(obj_biome))
		{
			biomeid = id
			
			// Name
			name = biome[?"name"]
			if (name = "nether") // Legacy
				name = "the_nether"
			
			// Parse dimension
			dimension = dimensionkey
			if (dimension = "legacy")
			{
				dimension = "overworld"
				if (name = "the_nether")
					dimension = "the_nether"
				else if (name = "the_end" || name = "the_void")
					dimension = "the_end"
			}
			
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
			color_water = c_plains_biome_water
			if (is_string(biome[?"water"]))
				color_water = hex_to_color(biome[?"water"])
			
			// Optional ground setting
			ground_name = value_get_string(biome[?"ground"])

			// Sky and fog defaults for this dimension
			sky_color = c_sky_overworld
			sky_enabled = is_string(biome[?"sky"])
			fog_color = c_sky_overworld
			fog_enabled = is_string(biome[?"fog"])
			
			if (dimension = "the_nether" || dimension = "the_end")
			{
				sky_color = (dimension = "the_nether" ? c_sky_the_nether : c_sky_the_end)
				fog_color = sky_color
			}
			if (fog_enabled)
				fog_color = hex_to_color(biome[?"fog"])
			if (sky_enabled)
				sky_color = hex_to_color(biome[?"sky"])
			
			biome_base = null
			biome_variants = null
			variants_extend = (name = "the_end")
			
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
						dimension = other.dimension
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
							
						// Optional ground setting
						ground_name = value_get_string(variant[?"ground"])

						// Use the dimension sky when no override is provided
						fog_color = other.fog_color
						fog_enabled = is_string(variant[?"fog"])
						sky_enabled = is_string(variant[?"sky"])
						
						if (fog_enabled)
							fog_color = hex_to_color(variant[?"fog"])
						
						sky_color = c_sky_overworld
						if (dimension = "the_nether")
							sky_color = c_sky_the_nether
						else if (dimension = "the_end")
							sky_color = c_sky_the_end
						
						if (sky_enabled)
							sky_color = hex_to_color(variant[?"sky"])
						
						biome_base = biomeid
						
						ds_list_add(biome_base.biome_variants, id)
					}
				}
			}
			
		}
		
		ds_list_add(list, biomeid)
	}
}
