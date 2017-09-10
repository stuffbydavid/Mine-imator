/// log_startup()

// Old log detected?
if (file_exists(log_file) && !dev_mode)
{
	startup_last_crash = true
	file_delete(log_previous_file)
	file_rename(log_file, log_previous_file)
	show_message("It seems Mine-imator didn\'t close properly last time, perhaps due to a crash. A log file was generated at " + log_previous_file)
}

// Write header
var file = file_text_open_write(log_file);
if (file < 0)
{
	access_error()
	return false
}

file_text_write_string(file, "___ Mine-imator log ___");
file_text_writeln(file)
file_text_write_string(file, "In your bug report, include this full log, along with instructions how to recreate the bug.");
file_text_writeln(file)
file_text_write_string(file, "If the issue concerns a specific animation, upload its folder as a .zip.");
file_text_writeln(file)
file_text_close(file)

// System info
log("mineimator_version", mineimator_version + test(mineimator_version_extra != "", " (" + mineimator_version_extra + ")", ""))
log("gm_runtime", gm_runtime)
log("YYC", yesno(code_is_compiled()))
log("texture_lib", texture_lib)
log("working_directory", working_directory)
log("file_directory", file_directory)
log("OS", test(false, "Mac", "Windows"))
log("os_version", os_version)
log("os_is_network_connected", yesno(os_is_network_connected()))
log("os_get_language", os_get_language())
log("os_get_region", os_get_region())
log("USERDOMAIN", environment_get_variable("USERDOMAIN"))
log("USERNAME", environment_get_variable("USERNAME"))
log("USERPROFILE", environment_get_variable("USERPROFILE"))
log("APPDATA", environment_get_variable("APPDATA"))
log("NUMBER_OF_PROCESSORS", environment_get_variable("NUMBER_OF_PROCESSORS"))
log("PROCESSOR_ARCHITECTURE", environment_get_variable("PROCESSOR_ARCHITECTURE"))
log("PROCESSOR_IDENTFIER", environment_get_variable("PROCESSOR_IDENTFIER"))
log("PROCESSOR_LEVEL", environment_get_variable("PROCESSOR_LEVEL"))
log("PROCESSOR_REVISION", environment_get_variable("PROCESSOR_REVISION"))

var osinfo = os_get_info();
if (osinfo > -1)
{
	var key = ds_map_find_first(osinfo);
	while (!is_undefined(key))
	{
		log(key, osinfo[?key])
		key = ds_map_find_next(osinfo, key)
	}
	ds_map_destroy(osinfo)
}

if (startup_last_crash)
	log("Old log found")

return true
