/// trial_startup()

function trial_startup()
{
	globalvar trial_version;
	trial_version = (dev_mode_full ? false : true)
	
	if (file_exists_lib(key_file))
	{
		log("Found key_file", key_file)
		if (key_valid(file_text_contents(key_file)))
			trial_version = false
	}
}
