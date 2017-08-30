/// res_load_pack()
/// @desc Unzips an archive and stores the textures in the resource.

switch (load_stage)
{
	// Unzip archive
	case "unzip":
	{
		if (pack_zip != "")
		{
			if (unzip(pack_zip) < 0)
			{
				log("Error unzipping pack")
				error("errorunzippack")
				with (app)
					load_next()
				return 0
			}
		}
		
		load_stage = "modeltextures"
		with (app)
		{
			popup_loading.text = text_get("loadpackmodeltextures")
			popup_loading.progress = 1 / 4
		}
		break
	}
	
	// Load model textures
	case "modeltextures":
	{
		res_load_pack_model_textures()
		
		load_stage = "blocktextures"
		with (app)
		{
			popup_loading.text = text_get("loadpackblocktextures")
			popup_loading.progress = 2 / 4
		}
		break
	}
	
	// Load block textures
	case "blocktextures":
	{
		res_load_pack_block_textures()
		
		load_stage = "itemtextures"
		with (app)
		{
			popup_loading.text = text_get("loadpackitemtextures")
			popup_loading.progress = 3 / 4
		}
		break
	}
	
	// Load item textures and finish
	case "itemtextures":
	{
		res_load_pack_item_textures()
		res_load_pack_misc()
		res_update_colors()
		
		ready = true
		
		log("Pack loaded")
		
		// Update project and load next in the queue
		with (app)
		{
			if (background_ground_tex = other.id)
				background_ground_update_texture()
			
			if (background_sky_clouds_tex = other.id)
				background_sky_update_clouds()
			
			with (bench_settings)
				if (item_tex = other.id)
					temp_update_item()
					
			with (obj_template)
				if (item_tex = other.id)
					temp_update_item()
				
			load_next()
		}
		break
	}
}

