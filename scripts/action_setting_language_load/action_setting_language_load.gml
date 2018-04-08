/// action_setting_language_load()

var fn = file_dialog_open_language();
if (!file_exists_lib(fn))
	return 0

setting_language_filename = fn
language_load(fn, language_map)

with (obj_template)
	temp_update_display_name()

with (obj_timeline)
	tl_update_type_name()

settings_save()