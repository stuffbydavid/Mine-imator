/// res_load_pack_item_textures(type, suffix)
/// @arg type
/// @arg suffix
/// @desc Creates a texture sheet for the items.

function res_load_pack_item_textures(type, suffix)
{
	// Free old
	if (type = "diffuse" && item_sheet_texture != null)
		texture_free(item_sheet_texture)
	
	if (type = "material" && item_sheet_texture_material != null)
		texture_free(item_sheet_texture_material)
	
	if (type = "normal" && item_sheet_tex_normal != null)
		texture_free(item_sheet_tex_normal)
	
	// Create new
	var itemsize, texlist, surf, fileslist;
	itemsize = null
	fileslist = null
	
	debug_timer_start()
	
	// Used to figure out what new files have been added
	if (dev_mode_debug_unused && type = "diffuse")
	{
		var filesarr = file_find(load_assets_dir + mc_textures_directory + "item/", ".png");
		fileslist = ds_list_create()
		
		// Convert array to modifyable list
		for (var i = 0; i < array_length(filesarr); i++)
			ds_list_add(fileslist, filesarr[i])
	}
	
	// Load textures
	log("Item textures", type, "load")
	texlist = ds_list_create() // name -> texture
	for (var t = 0; t < ds_list_size(mc_assets.item_texture_list); t++)
	{
		if (mc_assets.item_texture_list[|t] = "")
		{
			ds_list_add(texlist, null)
			continue
		}
		
		var name, fname;
		name = mc_assets.item_texture_list[|t]
		fname = load_assets_dir + mc_textures_directory + name + suffix + ".png";
		
		// Look if legacy name exists
		if (!file_exists_lib(fname) && !is_undefined(legacy_item_texture_name_map[?name]))
			fname = load_assets_dir + mc_textures_directory + legacy_item_texture_name_map[?name] + suffix + ".png"
		
		if (file_exists_lib(fname))
		{
			var tex = texture_create(fname);
			itemsize = max(itemsize, texture_width(tex))
			ds_list_add(texlist, tex)
			
			if (fileslist != null)
				ds_list_delete_value(fileslist, fname)
		}
		else
		{
			if (dev_mode)
				log("Item texture not found", mc_assets.item_texture_list[|t] + suffix)
			ds_list_add(texlist, null)
		}
	}
	
	if (fileslist != null)
	{
		ds_list_sort(fileslist, true)
		if (ds_list_size(fileslist) > 0)
		{
			var str = "The following item textures were unused:\n";
			for (var i = 0; i < ds_list_size(fileslist); i++)
				str += "  " + filename_name(fileslist[|i]) + "\n"
			log(str)
		}
		ds_list_destroy(fileslist)
	}
	
	if (itemsize = null)
		itemsize = item_size
	
	// Create surface of items
	log("Item textures", "surface")
	draw_texture_start()
	surf = surface_create(minecraft_item_sheet_size[0] * itemsize, minecraft_item_sheet_size[1] * itemsize)
	surface_set_target(surf)
	{
		gpu_set_blendmode_ext(bm_one, bm_inv_src_alpha)
		draw_clear_alpha(c_black, 0)
		
		for (var t = 0; t < ds_list_size(texlist); t++)
		{
			var tex, dx, dy;
			tex = texlist[|t]
			dx = (t mod minecraft_item_sheet_size[0]) * itemsize
			dy = (t div minecraft_item_sheet_size[0]) * itemsize
			
			if (tex != null)
			{
				var wid, hei, scale;
				wid = texture_width(tex)
				hei = texture_height(tex)
				scale = itemsize / wid
				draw_texture_part(tex, dx, dy, 0, 0, wid, hei, scale, scale)
			}
			else
			{
				if (type = "diffuse" && id != mc_res)
					draw_texture_part(mc_res.item_sheet_texture, dx, dy,
									  (t mod minecraft_item_sheet_size[0]) * item_size, (t div minecraft_item_sheet_size[0]) * item_size,
									  item_size, item_size, itemsize / item_size, itemsize / item_size)
				
				if (type = "material")
					draw_box(dx, dy, itemsize, itemsize, false, c_black, 1)
				
				if (type = "normal")
					draw_box(dx, dy, itemsize, itemsize, false, c_normal, 1)
			}
		}
		
		gpu_set_blendmode(bm_normal)
	}
	surface_reset_target()
	draw_texture_done()
	
	if (type = "diffuse")
		item_sheet_texture = texture_surface(surf)
	else if (type = "material")
		item_sheet_texture_material = texture_surface(surf)
	else
		item_sheet_tex_normal = texture_surface(surf)
	
	// Clean up
	for (var t = 0; t < ds_list_size(texlist); t++)
		if (texlist[|t] != null)
			texture_free(texlist[|t])
	
	surface_free(surf)
	ds_list_destroy(texlist)
	
	log("Item textures", type, "done")
	debug_timer_stop("Item textures: " + type)
}
