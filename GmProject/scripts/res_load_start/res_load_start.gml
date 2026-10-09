/// @desc Starts loading the resource.

function res_load_start()
{
	switch (type)
	{
		case e_res_type.SCHEMATIC:
		case e_res_type.FROM_WORLD:
		{
			load_stage = "open"
			
			with (app)
			{
				popup_loading.text = text_get("load_scenery/open")
				popup_loading.caption = other.filename
				popup_loading.load_script = res_load_scenery
			}
			
			break
		}
		
		case e_res_type.SOUND:
		{
			load_stage = "open"
			
			with (app)
			{
				popup_loading.text = text_get("load_audio/read")
				popup_loading.caption = other.filename
				popup_loading.load_script = res_load_audio
			}
			
			break
		}
		
		case e_res_type.PACK:
		case e_res_type.PACK_UNZIPPED:
		{
			with (app)
			{
				popup_loading.caption = other.filename
				popup_loading.load_script = res_load_pack
			}
			
			// Assign texture page
			if (pack_texture_page < 0)
				pack_texture_page = texture_page_create()
			else
				texture_page_clear(pack_texture_page)
			
			texture_page_set_current(pack_texture_page)
			res_load_pack_render_textures()
			
			// Load texture cache if available
			if (!load_reload)
			{
				var cachefile = save_folder + "/" + filename + ".packcache";
				if (file_exists_lib(cachefile))
				{
					pack_cache_loaded = res_load_pack_cache(cachefile)
					
					texture_page_reset()
					
					if (pack_cache_loaded)
					{
						app.popup_loading.text = text_get("load_pack/cache")
						type = e_res_type.PACK
						load_stage = "done"
						
						break
					}
				}
			}
			
			load_stage = "unzip"
			app.popup_loading.text = text_get("load_pack/unzip")
			
			texture_page_reset()
			
			break
		}
	}
}
