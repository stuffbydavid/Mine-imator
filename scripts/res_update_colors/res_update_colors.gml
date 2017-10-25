/// res_update_colors([biome])
/// @arg [biome]
/// @desc Update grass & foliage colors for a resource.

if (colormap_grass_texture = null)
	return 0
	
var biome;
if (argument_count > 0)
	biome = argument[0]
else
	biome = app.background_biome;

if (biome.name = "mesa")
{
	color_grass = c_mesa_biome_grass
	color_foliage = c_mesa_biome_foliage
}
else if (biome.name = "swampland")
{
	color_grass = c_swampland_biome_grass
	color_foliage = c_swampland_biome_foliage
}
else
{
	color_grass = texture_getpixel(colormap_grass_texture, biome.tx, biome.ty)
	color_foliage = texture_getpixel(colormap_foliage_texture, biome.tx, biome.ty)
}