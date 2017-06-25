/// res_export()
/// Saves the sprites into the given directory.
// TODO

var fnout = save_folder + "\\" + filename_out;

debug("res_export", "Exporting to " + fnout)

/*if (type = "pack")
{
	if (!ready)
		return 0
	
	var path = fnout + "\\";
	directory_create_lib(fnout)
	
	var key = ds_map_find_first(model_texture_map);
	while (!is_undefined(key))
	{
		texture_export(model_texture_map[? key], path + key + ".png")
		key = ds_map_find_next(model_texture_map, key)
	}
	
	if (block_frames = 1)
		texture_export(block_texture[0], path + "blocks1.png")
	else
		for (var f = 0; f < 32; f++)
			texture_export(block_texture[f], path + "blocks" + string(f + 1) + ".png")
		
	texture_export(colormap_grass_texture, path + "color_grass.png")
	texture_export(colormap_foliage_texture, path + "color_foliage.png")
	texture_export(item_texture, path + "items.png")
	texture_export(particles_texture[0], path + "particles_sheet1.png")
	texture_export(particles_texture[1], path + "particles_sheet2.png")
	texture_export(block_preview_texture, path + "pack.png")
	texture_export(sun_texture, path + "sun.png")
	texture_export(moonphases_texture, path + "moonphases.png")
	texture_export(clouds_texture, path + "clouds.png")
}
else*/
	file_copy_lib(load_folder + "\\" + filename, fnout)

debug("res_export", "Done!")
