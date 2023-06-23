/// res_load_pack_model_textures()

function res_load_pack_model_textures()
{
	// Free old
	if (model_texture_map != null)
	{
		var key = ds_map_find_first(model_texture_map);
		while (!is_undefined(key))
		{
			texture_free(model_texture_map[?key])
			key = ds_map_find_next(model_texture_map, key)
		}
		ds_map_destroy(model_texture_map)
	}
	
	if (model_texture_material_map != null)
	{
		var key = ds_map_find_first(model_texture_material_map);
		while (!is_undefined(key))
		{
			texture_free(model_texture_material_map[?key])
			key = ds_map_find_next(model_texture_material_map, key)
		}
		ds_map_destroy(model_texture_material_map)
	}
	
	if (model_tex_normal_map != null)
	{
		var key = ds_map_find_first(model_tex_normal_map);
		while (!is_undefined(key))
		{
			texture_free(model_tex_normal_map[?key])
			key = ds_map_find_next(model_tex_normal_map, key)
		}
		ds_map_destroy(model_tex_normal_map)
	}
	
	// Create new
	debug_timer_start()
	
	log("Model textures", "load")
	model_texture_map = ds_map_create()
	model_texture_material_map = ds_map_create()
	model_tex_normal_map = ds_map_create()
	for (var t = 0; t < ds_list_size(mc_assets.model_texture_list); t++)
	{
		var name, fname, matfname, norfname, tex;
		name = mc_assets.model_texture_list[|t]
		fname = load_assets_dir + mc_textures_directory + name + ".png"
		matfname = load_assets_dir + mc_textures_directory + name + "_s.png"
		norfname = load_assets_dir + mc_textures_directory + name + "_n.png"
		
		// Diffuse
		if (file_exists_lib(fname))
		{
			if (name = "entity/steve")
				tex = res_load_player_skin(fname)
			else
				tex = texture_create_square(fname)
		}
		else if (id != mc_res)
			tex = texture_duplicate(mc_res.model_texture_map[?name])
		else
		{
			if (dev_mode)
				log("Model texture not found", mc_assets.model_texture_list[|t])
			tex = texture_create_missing()
		}
		
		model_texture_map[?name] = tex
		
		// Material
		if (file_exists_lib(matfname))
		{
			if (matfname = "entity/steve_s")
				tex = res_load_player_skin(matfname)
			else
				tex = texture_create_square(matfname)
		}
		else
			tex = texture_duplicate(spr_default_material)
		
		model_texture_material_map[?name] = tex
		
		// Normal
		if (file_exists_lib(norfname))
		{
			if (norfname = "entity/steve_n")
				tex = res_load_player_skin(norfname)
			else
				tex = texture_create_square(norfname)
		}
		else 
			tex = texture_duplicate(spr_default_normal)
		
		model_tex_normal_map[?name] = tex
	}
	
	log("Model textures", "done")
	debug_timer_stop("Model textures")
}
