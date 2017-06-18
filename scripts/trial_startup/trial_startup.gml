/// trial_startup()

trial_version = true

if (file_exists_lib(key_file))
{
	log("Found key_file", key_file)
	file_delete_lib(temp_file)
	file_copy_lib(key_file, temp_file)
	var f = file_text_open_read(temp_file);
	if (f > -1)
	{
		if (key_valid(file_text_read_string(f)))
			trial_version = false
		file_text_close(f)
	}
}
