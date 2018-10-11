/// res_update_colors([biome])
/// @arg [biome]
/// @desc Update grass & foliage colors for a resource.

if (colormap_grass_texture = null)
	return 0
	
var biome;
if (argument_count > 0)
	biome = argument[0]
else
	biome = app.background_biome

if (biome.name = "custom")
{
	color_grass = app.background_grass_color
	color_foliage = app.background_foliage_color
	color_water = app.background_water_color
}
else
{
	if (biome.biome_variants = null)
	{
		if (biome.hardcoded)
		{
			color_grass = biome.color_grass
			color_foliage = biome.color_foliage
		}
		else
		{
			color_grass = texture_getpixel(colormap_grass_texture, biome.txy[0], biome.txy[1])
			color_foliage = texture_getpixel(colormap_foliage_texture, biome.txy[0], biome.txy[1])
		}
	
		color_water = biome.color_water
	}
	else
	{
		var variant = biome.biome_variants[|biome.selected_variant];
	
		if (variant.hardcoded)
		{
			color_grass = variant.color_grass
			color_foliage = variant.color_foliage
		}
		else
		{
			color_grass = texture_getpixel(colormap_grass_texture, variant.txy[0], variant.txy[1])
			color_foliage = texture_getpixel(colormap_foliage_texture, variant.txy[0], variant.txy[1])
		}
	
		color_water = variant.color_water
	}
}
