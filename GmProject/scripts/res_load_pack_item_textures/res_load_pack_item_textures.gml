/// res_load_pack_item_textures(type, suffix)
/// @arg type
/// @arg suffix
/// @desc Creates texture sheets for 16px and 32px items.

function res_load_pack_item_textures(type, suffix)
{
	// Free old
	for (var size = 0; size < e_item_sheet.amount; size++)
	{
		if (type = "diffuse")
		{
			if (item_sheet_texture[size] != null)
				texture_free(item_sheet_texture[size])
			item_sheet_texture[size] = null
		}

		if (type = "material")
		{
			if (item_sheet_texture_material[size] != null)
				texture_free(item_sheet_texture_material[size])
			item_sheet_texture_material[size] = null
		}

		if (type = "normal")
		{
			if (item_sheet_texture_normal[size] != null)
				texture_free(item_sheet_texture_normal[size])
			item_sheet_texture_normal[size] = null
		}
	}
	
	// Create new
	var itemsize, itemscale, texlist, surf, fileslist;
	itemsize = null
	texlist = array_create(e_item_sheet.amount, null)
	surf = array_create(e_item_sheet.amount, null)
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
	for (var size = 0; size < e_item_sheet.amount; size++)
	{
		var itemtexlist = mc_assets.item_texture_list[size]
		if (ds_list_size(itemtexlist) = 0 || minecraft_item_sheet_size[size][X] <= 0 || minecraft_item_sheet_size[size][Y] <= 0)
			continue

		log("Item textures", type, "load " + string(item_size * (size + 1)))
		texlist[size] = ds_list_create() // name -> texture
		for (var t = 0; t < ds_list_size(itemtexlist); t++)
		{
			if (itemtexlist[|t] = "")
			{
				ds_list_add(texlist[size], null)
				continue
			}

			var name, fname;
			name = itemtexlist[|t]
			fname = load_assets_dir + mc_textures_directory + name + suffix + ".png";

			// Look if legacy name exists
			if (!file_exists_lib(fname) && !is_undefined(legacy_item_texture_name_map[?name]))
				fname = load_assets_dir + mc_textures_directory + legacy_item_texture_name_map[?name] + suffix + ".png"

			if (file_exists_lib(fname))
			{
				var tex;
				if (id = mc_res) // Patch textures
					tex = texture_create_patched(fname)
				else
					tex = texture_create(fname)
					
				// Sheet size is determined by the maximum width of the first 10 item textures
				if (size = e_item_sheet.SIZE16 && t < 10)
					itemsize = max(itemsize, texture_width(tex))
					
				ds_list_add(texlist[size], tex)

				if (fileslist != null)
					ds_list_delete_value(fileslist, fname)
			}
			else
			{
				if (dev_mode)
					log("Item texture not found", itemtexlist[|t] + suffix)
				ds_list_add(texlist[size], null)
			}
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
	itemscale = itemsize / item_size
	
	// Create item sheets
	for (var size = 0; size < e_item_sheet.amount; size++)
	{
		if (texlist[size] = null)
			continue
		
		var staticitemsize = itemscale * item_size * (size + 1)
		log("Item textures", type, string(item_size * (size + 1)) + " surface")
		draw_texture_start()
		surf[size] = surface_create(minecraft_item_sheet_size[size][X] * staticitemsize, minecraft_item_sheet_size[size][Y] * staticitemsize)
		surface_set_target(surf[size])
		{
			gpu_set_blendmode_ext(bm_one, bm_inv_src_alpha)
			draw_clear_alpha(c_black, 0)

			for (var t = 0; t < ds_list_size(texlist[size]); t++)
			{
				var tex, dx, dy;
				tex = texlist[size][|t]
				dx = (t mod minecraft_item_sheet_size[size][X]) * staticitemsize
				dy = (t div minecraft_item_sheet_size[size][X]) * staticitemsize
				
				if (tex != null)
				{
					var wid, hei, scale;
					wid = texture_width(tex)
					hei = texture_height(tex)
					scale = staticitemsize / wid
					draw_texture_part(tex, dx, dy, 0, 0, wid, hei, scale, scale)
				}
				else
				{
					if (type = "diffuse" && id != mc_res && mc_res.item_sheet_texture[size] != null)
					{
						var sourceitemsize = item_size * (size + 1)
						draw_texture_part(mc_res.item_sheet_texture[size], dx, dy,
							(t mod minecraft_item_sheet_size[size][X]) * sourceitemsize, (t div minecraft_item_sheet_size[size][X]) * sourceitemsize,
							sourceitemsize, sourceitemsize, staticitemsize / sourceitemsize, staticitemsize / sourceitemsize)
					}
					else if (type = "material")
						draw_box(dx, dy, staticitemsize, staticitemsize, false, c_black, 1)
					else if (type = "normal")
						draw_box(dx, dy, staticitemsize, staticitemsize, false, c_normal, 1)
				}
			}

			gpu_set_blendmode(bm_normal)
		}
		surface_reset_target()
		draw_texture_done()
		
		if (type = "diffuse")
			item_sheet_texture[size] = texture_surface(surf[size])
		else if (type = "material")
			item_sheet_texture_material[size] = texture_surface(surf[size])
		else
			item_sheet_texture_normal[size] = texture_surface(surf[size])
	}
	
	// Clean up
	for (var size = 0; size < e_item_sheet.amount; size++)
	{
		if (texlist[size] = null)
			continue
		for (var t = 0; t < ds_list_size(texlist[size]); t++)
			if (texlist[size][|t] != null)
				texture_free(texlist[size][|t])

		surface_free(surf[size])
		ds_list_destroy(texlist[size])
	}
	
	log("Item textures", type, "done")
	debug_timer_stop("Item textures: " + type)
}
