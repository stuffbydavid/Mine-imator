/// res_load_start()
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
				popup_loading.text = text_get("loadsceneryopen")
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
				popup_loading.text = text_get("loadaudioread")
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
			
			// Load texture cache if available
			if (!load_reload)
			{
				var cachefile = save_folder + "/" + filename + ".packcache";
				if (file_exists_lib(cachefile))
				{
					pack_cache_loaded = res_load_pack_cache(cachefile)
					if (pack_cache_loaded)
					{
						app.popup_loading.text = text_get("loadpackcache")
						type = e_res_type.PACK
						load_stage = "finish"
						break
					}
				}
			}
			
			load_stage = "unzip"
			app.popup_loading.text = text_get("loadpackunzip")
			break
		}
	}
}
