/// recent_save()

function recent_save()
{
	log("Updating recent list")
	
	json_save_start(recent_file)
	json_save_object_start()
	
	json_save_array_start("list")
	
	for (var i = 0; i < ds_list_size(recent_list); i++)
	{
		var recent = recent_list[|i];
		
		json_save_object_start()
		
		json_save_var("name", json_string_encode(recent.name))
		json_save_var("author", json_string_encode(recent.author))
		json_save_var("description", json_string_encode(recent.description))
		json_save_var("thumbnail", recent.thumbnail)
		
		json_save_var("filename", json_string_encode(recent.filename))
		json_save_var("last_opened", recent.last_opened)
		json_save_var_bool("pinned", recent.pinned)
		
		json_save_object_done()
	}
	
	json_save_array_done()
	json_save_object_done()
	
	json_save_done()
	
	debug("Saved recent list")
}
