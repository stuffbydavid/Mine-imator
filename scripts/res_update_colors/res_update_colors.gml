/// res_update_colors([biome])
/// @arg [biome]
/// @desc Update grass & foliage colors for a resource.

if (colormap_grass_texture = null)
	return 0
	
var biome, foliagecolor;
if (argument_count > 0)
	biome = argument[0]
else
	biome = app.background_biome

if (biome.name = "custom")
{
	color_grass = app.background_grass_color
	color_foliage = app.background_foliage_color
	color_water = app.background_water_color
	
	color_leaves_oak = app.background_leaves_oak_color
	color_leaves_spruce = app.background_leaves_spruce_color
	color_leaves_birch = app.background_leaves_birch_color
	color_leaves_jungle = app.background_leaves_jungle_color
	color_leaves_acacia = app.background_leaves_acacia_color
	color_leaves_dark_oak = app.background_leaves_dark_oak_color
}
else
{
	if (biome.biome_variants = null)
	{
		if (biome.hardcoded)
		{
			color_grass = biome.color_grass
			foliagecolor = biome.color_foliage
		}
		else
		{
			color_grass = texture_getpixel(colormap_grass_texture, biome.txy[0], biome.txy[1])
			foliagecolor = texture_getpixel(colormap_foliage_texture, biome.txy[0], biome.txy[1])
		}
	
		color_water = biome.color_water
	}
	else
	{
		var variant = biome.biome_variants[|biome.selected_variant];
	
		if (variant.hardcoded)
		{
			color_grass = variant.color_grass
			foliagecolor = variant.color_foliage
		}
		else
		{
			color_grass = texture_getpixel(colormap_grass_texture, variant.txy[0], variant.txy[1])
			foliagecolor = texture_getpixel(colormap_foliage_texture, variant.txy[0], variant.txy[1])
		}
	
		color_water = variant.color_water
	}
	
	color_leaves_oak = foliagecolor
	color_leaves_jungle = foliagecolor
	color_leaves_acacia = foliagecolor
	color_leaves_dark_oak = foliagecolor
	color_foliage = foliagecolor
	
	color_leaves_spruce = hex_to_color("#62A857")
	color_leaves_birch = color_leaves_spruce
}
