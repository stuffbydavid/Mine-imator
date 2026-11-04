function key_save()
{
	json_save_start(key_file)
	
	json_save_object_start()
	
		json_save_var("format", e_key_format.FORMAT_210)
		json_save_var("key", key_current)
		json_save_var("date", key_current_date)
		json_save_var("dismissed", key_expired_dismissed)
	
	json_save_object_done()
	
	json_save_done()
}