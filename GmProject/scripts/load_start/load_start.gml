function load_start(object, script)
{
	if (popup_current != popup_loading)
	{
		popup_current = popup_loading
		popup_ani = 0
		popup_ani_type = "show"
	}
	
	if (popup_current = popup_loading && popup_ani != 1)
		popup_current.load_amount = ds_priority_size(load_queue)
	
	with (popup_loading)
	{
		caption = ""
		text = ""
		progress = 0
		load_object = object
		load_script = script
	}

	// Show resource name before the first loading frame
	with (object)
	{
		other.popup_loading.caption = filename
		switch (type)
		{
			case e_res_type.SCHEMATIC:
			case e_res_type.FROM_WORLD:
				other.popup_loading.text = text_get("load_scenery/open")
				break
			
			case e_res_type.SOUND:
				other.popup_loading.text = text_get("load_audio/read")
				break
			
			case e_res_type.PACK:
			{
				if (!load_reload && file_exists_lib(save_folder + "/" + filename + ".packcache"))
					other.popup_loading.text = text_get("load_pack/cache")
				else
					other.popup_loading.text = text_get("load_pack/unzip")
				break
			}
		
			case e_res_type.PACK_UNZIPPED:
				other.popup_loading.text = text_get("load_pack/unzip")
				break
		}
	}
	
	window_busy = "popup/" + popup_current.name
}
