/// languages_save()

log("Saving languages", languages_file)

json_save_start(languages_file)
json_save_object_start()

json_save_var("format", settings_format)

json_save_array_start("languages")
	
	with (obj_language)
	{
		json_save_object_start()
		
		json_save_var("name", json_string_encode(name))
		json_save_var("locale", locale)
		json_save_var("filename", filename)
		
		json_save_object_done()
	}

json_save_array_done()
json_save_object_done()
json_save_done()

debug("Saved languges")
