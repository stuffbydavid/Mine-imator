/// res_biome_colors(biomename, [values])
/// @arg biomename
/// @arg [values]

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
			return array(
				values[e_value.BG_GRASS_COLOR],
				values[e_value.BG_FOLIAGE_COLOR],
				values[e_value.BG_DRY_FOLIAGE_COLOR],
				values[e_value.BG_WATER_COLOR],
				values[e_value.BG_LEAVES_OAK_COLOR],
				values[e_value.BG_LEAVES_SPRUCE_COLOR],
				values[e_value.BG_LEAVES_BIRCH_COLOR],
				values[e_value.BG_LEAVES_JUNGLE_COLOR],
				values[e_value.BG_LEAVES_ACACIA_COLOR],
				values[e_value.BG_LEAVES_DARK_OAK_COLOR],
				values[e_value.BG_LEAVES_MANGROVE_COLOR])
		}

		return array(
			app.background_grass_color,
			app.background_foliage_color,
			app.background_dry_foliage_color,
			app.background_water_color,
			app.background_leaves_oak_color,
			app.background_leaves_spruce_color,
			app.background_leaves_birch_color,
			app.background_leaves_jungle_color,
			app.background_leaves_acacia_color,
			app.background_leaves_dark_oak_color,
			app.background_leaves_mangrove_color)
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
	return array(grass, foliage, dryfoliage, water, foliage, spruce, spruce, foliage, foliage, foliage, foliage)
}
