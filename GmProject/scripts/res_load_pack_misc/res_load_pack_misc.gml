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
	
	if (colormap_dry_foliage_texture != null)
		texture_free(colormap_dry_foliage_texture)
	
	if (sun_texture != null)
		texture_free(sun_texture)
	
	for (var i = 0; i < 8; i++)
		if (moon_textures[i] != null)
			texture_free(moon_textures[i])
	
	//if (moonphases_texture != null)
	//{
	//	texture_free(moonphases_texture)
	//	for (var t = 0; t < 8; t++)
	//		texture_free(moon_texture[t])
	//}
	
	if (clouds_texture != null)
		texture_free(clouds_texture)
	
	if (glint_armor_texture != null)
		texture_free(glint_armor_texture)
	
	if (glint_item_texture != null)
		texture_free(glint_item_texture)
	
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
	
	// Dry foliage
	if (!file_exists_lib(load_assets_dir + mc_dry_foliage_image_file) && id != mc_res)
		colormap_dry_foliage_texture = texture_duplicate(mc_res.colormap_dry_foliage_texture)
	else
		colormap_dry_foliage_texture = texture_create(load_assets_dir + mc_dry_foliage_image_file)
	
	// Sun
	if (!file_exists_lib(load_assets_dir + mc_sun_image_file) && id != mc_res)
		sun_texture = texture_duplicate(mc_res.sun_texture)
	else
		sun_texture = texture_create(load_assets_dir + mc_sun_image_file)
	
	// Moon phases
	if (!file_exists_lib(load_assets_dir + mc_moon_phase_0_image_file) && id != mc_res)
		for (var i = 0; i < 8; i++)
			moon_textures[i] = texture_duplicate(mc_res.moon_textures[i])
	else
	{
		for (var i = 0; i < 8; i++)
		{
			var moon_phase_image_files = [
				mc_moon_phase_0_image_file,
				mc_moon_phase_1_image_file,
				mc_moon_phase_2_image_file,
				mc_moon_phase_3_image_file,
				mc_moon_phase_4_image_file,
				mc_moon_phase_5_image_file,
				mc_moon_phase_6_image_file,
				mc_moon_phase_7_image_file
			];
			moon_textures[i] = texture_create(load_assets_dir + moon_phase_image_files[i]);
		}
	}
	
	//// Moon phases
	//if (!file_exists_lib(load_assets_dir + mc_moon_phases_image_file) && id != mc_res)
	//	moonphases_texture = texture_duplicate(mc_res.moonphases_texture)
	//else
	//	moonphases_texture = texture_create(load_assets_dir + mc_moon_phases_image_file)
	//moon_texture = texture_split(moonphases_texture, 4, 2)
	
	// Clouds
	if (!file_exists_lib(load_assets_dir + mc_clouds_image_file) && id != mc_res)
		clouds_texture = texture_duplicate(mc_res.clouds_texture)
	else
		clouds_texture = texture_create(load_assets_dir + mc_clouds_image_file)
	
	// Enchantment glint
	if (!file_exists_lib(load_assets_dir + mc_glint_armor_file) && id != mc_res)
		glint_armor_texture = texture_duplicate(mc_res.glint_armor_texture)
	else
		glint_armor_texture = texture_create(load_assets_dir + mc_glint_armor_file)
	
	if (!file_exists_lib(load_assets_dir + mc_glint_item_file) && id != mc_res)
		glint_item_texture = texture_duplicate(mc_res.glint_item_texture)
	else
		glint_item_texture = texture_create(load_assets_dir + mc_glint_item_file)
}
