/// load_start(object, script)
/// @arg object
/// @arg script

function load_start(object, script)
{
	if (popup != popup_loading)
	{
		popup = popup_loading
		popup_ani = 0
		popup_ani_type = "show"
	}
	
	if (popup = popup_loading && popup_ani != 1)
		popup.load_amount = ds_priority_size(load_queue)
	
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
				other.popup_loading.text = text_get("loadsceneryopen")
				break
			
			case e_res_type.SOUND:
				other.popup_loading.text = text_get("loadaudioread")
				break
			
			case e_res_type.PACK:
			{
				if (!load_reload && file_exists_lib(save_folder + "/" + filename + ".packcache"))
					other.popup_loading.text = text_get("loadpackcache")
				else
					other.popup_loading.text = text_get("loadpackunzip")
				break
			}
		
			case e_res_type.PACK_UNZIPPED:
				other.popup_loading.text = text_get("loadpackunzip")
				break
		}
	}
	
	window_busy = "popup" + popup.name
}
