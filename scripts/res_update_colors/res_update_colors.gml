/// res_update_colors()
/// @desc Update grass & foliage colors for a resource.

if (!colormap_grass_texture)
	return 0
	
var biome = biome_list[|app.background_biome];
color_grass = texture_getpixel(colormap_grass_texture, biome.tx, biome.ty)
color_foliage = texture_getpixel(colormap_foliage_texture, biome.tx, biome.ty)
