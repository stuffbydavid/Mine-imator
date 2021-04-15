/// action_setting_language(filename)
/// @arg filename

var fn = argument0;

setting_language_filename = fn
language_load(languages_directory + fn, language_map)

settings_save()
