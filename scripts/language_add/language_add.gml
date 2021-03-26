/// language_add()
/// @desc Loads language file from filepath and registers data

var fn = file_dialog_open_language();

if (fn = "")
	return 0

// Already exists
if (file_exists_lib(languages_directory + filename_name(fn)))
	if (!question("This file already exists the language file directory. Do you want to replace the file?"))
		return 0

// Copy to folder and load
file_copy_lib(fn, languages_directory + filename_name(fn))
action_setting_language_load(languages_directory + filename_name(fn))

// New/edit language object
language_remove(filename_name(fn))
langauge_new(fn)

languages_save()
