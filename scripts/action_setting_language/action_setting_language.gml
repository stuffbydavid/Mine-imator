/// action_setting_language(filename)
/// @arg filename

function action_setting_language(fn)
{
	setting_language_filename = fn
	language_load(languages_directory + fn, language_map)

	settings_save()
}
