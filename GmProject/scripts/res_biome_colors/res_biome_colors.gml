function res_biome_colors(biomename, values = null)
{
	var biome, grass, foliage, dryfoliage, water, spruce;
	biome = find_biome(biomename)
	if (biome = null)
		return null

	if (biome.name = "custom")
	{
		if (values != null)
		{
			return [
				values[e_value.ENV_GRASS_COLOR],
				values[e_value.ENV_FOLIAGE_COLOR],
				values[e_value.ENV_DRY_FOLIAGE_COLOR],
				values[e_value.ENV_WATER_COLOR],
				values[e_value.ENV_LEAVES_OAK_COLOR],
				values[e_value.ENV_LEAVES_SPRUCE_COLOR],
				values[e_value.ENV_LEAVES_BIRCH_COLOR],
				values[e_value.ENV_LEAVES_JUNGLE_COLOR],
				values[e_value.ENV_LEAVES_ACACIA_COLOR],
				values[e_value.ENV_LEAVES_DARK_OAK_COLOR],
				values[e_value.ENV_LEAVES_MANGROVE_COLOR]
			]
		}

		return app.env_color_list
	}

	if (biome.hardcoded)
	{
		grass = biome.color_grass
		foliage = biome.color_foliage
		dryfoliage = biome.color_dry_foliage
	}
	else
	{
		grass = texture_getpixel(colormap_grass_texture, biome.txy[0], biome.txy[1])
		foliage = texture_getpixel(colormap_foliage_texture, biome.txy[0], biome.txy[1])
		dryfoliage = texture_getpixel(colormap_dry_foliage_texture, biome.txy[0], biome.txy[1])
	}

	water = biome.color_water
	spruce = hex_to_color("62A857")
	return [ grass, foliage, dryfoliage, water, foliage, spruce, spruce, foliage, foliage, foliage, foliage ]
}
