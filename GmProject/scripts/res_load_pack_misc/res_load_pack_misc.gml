/// res_load_pack_misc()
/// @desc Loads miscellaneous textures into the resource.

function res_load_pack_misc()
{
	// Free old
	if (block_preview_texture != null)
		texture_free(block_preview_texture)
	
	if (colormap_grass_texture != null)
		texture_free(colormap_grass_texture)
	
	if (colormap_foliage_texture != null)
		texture_free(colormap_foliage_texture)
	
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
	
	// Pack image
	if (!file_exists_lib(load_assets_dir + mc_pack_image_file) && id != mc_res)
		block_preview_texture = texture_sprite(spr_unknown_pack)
	else
		block_preview_texture = texture_create(load_assets_dir + mc_pack_image_file)
	
	// Grass
	if (!file_exists_lib(load_assets_dir + mc_grass_image_file) && id != mc_res)
		colormap_grass_texture = texture_duplicate(mc_res.colormap_grass_texture)
	else
		colormap_grass_texture = texture_create(load_assets_dir + mc_grass_image_file)
	
	// Foliage
	if (!file_exists_lib(load_assets_dir + mc_foliage_image_file) && id != mc_res)
		colormap_foliage_texture = texture_duplicate(mc_res.colormap_foliage_texture)
	else
		colormap_foliage_texture = texture_create(load_assets_dir + mc_foliage_image_file)
	
	// Sun
	if (!file_exists_lib(load_assets_dir + mc_sun_image_file) && id != mc_res)
		sun_texture = texture_duplicate(mc_res.sun_texture)
	else
		sun_texture = texture_create(load_assets_dir + mc_sun_image_file)
	
	// Moon phases
	if (!file_exists_lib(load_assets_dir + mc_moon_phases_image_file) && id != mc_res)
		moonphases_texture = texture_duplicate(mc_res.moonphases_texture)
	else
		moonphases_texture = texture_create(load_assets_dir + mc_moon_phases_image_file)
	
	moon_texture = texture_split(moonphases_texture, 4, 2)
	
	// Clouds
	if (!file_exists_lib(load_assets_dir + mc_clouds_image_file) && id != mc_res)
		clouds_texture = texture_duplicate(mc_res.clouds_texture)
	else
		clouds_texture = texture_create(load_assets_dir + mc_clouds_image_file)
}
