/// app_startup()

startup_last_crash = false
startup_error = true

if (!log_startup())
	return false

if (!lib_startup())
	return false

if (!file_lib_startup())
	return false
	
if (!file_exists_lib(import_file))
	return missing_file(import_file)

if (!file_exists_lib(legacy_file))
	return missing_file(legacy_file)

if (!file_exists_lib(language_file))
	return missing_file(language_file)

vertex_format_startup()
if (!shader_startup())
	return false

app_startup_lists()
app_startup_window()

alert_startup()
json_startup()
settings_startup()
project_startup()
legacy_startup()
render_startup()
camera_startup()

if (!minecraft_assets_startup())
	return false

startup_error = false

return true
