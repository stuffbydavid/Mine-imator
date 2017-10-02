/// res_load_pack_misc()
/// @desc Loads miscellaneous textures into the resource.

// Free old
if (block_preview_texture != null)
	texture_free(block_preview_texture)

if (colormap_grass_texture != null)
	texture_free(colormap_grass_texture)

if (colormap_foliage_texture != null)
	texture_free(colormap_foliage_texture)

if (particles_texture[0] != null)
	texture_free(particles_texture[0])

if (particles_texture[1] != null)
	texture_free(particles_texture[1])
	
if (sun_texture != null)
	texture_free(sun_texture)

if (moonphases_texture != null)
{
	texture_free(moonphases_texture)
	for (var t = 0; t < 8; t++)
		texture_free(moon_texture[t])
}

if (clouds_texture != null)
	texture_free(clouds_texture)
	
// Create new
block_preview_texture = texture_create(load_assets_dir + "pack.png")

colormap_grass_texture = texture_create(load_assets_dir + mc_textures_directory + "colormap\\grass.png")
colormap_foliage_texture = texture_create(load_assets_dir + mc_textures_directory + "colormap\\foliage.png")

particles_texture[0] = texture_create(load_assets_dir + mc_textures_directory + "particle\\particles.png")
particles_texture[1] = texture_create(load_assets_dir + mc_textures_directory + "entity\\explosion.png")

sun_texture = texture_create(load_assets_dir + mc_textures_directory + "environment\\sun.png")
moonphases_texture = texture_create(load_assets_dir + mc_textures_directory + "environment\\moon_phases.png")
moon_texture = texture_split(moonphases_texture, 4, 2)

clouds_texture = texture_create_fixed(load_assets_dir + mc_textures_directory + "environment\\clouds.png", 32, 32)
