/// app_startup()

startup_last_crash = false
startup_error = true

if (!log_startup())
	return false

lib_startup()

if (!file_lib_startup())
	return false
	
if (!file_exists_lib(import_file))
{
	missing_file(import_file)
	return false
}

if (!file_exists_lib(legacy_file))
{
	missing_file(legacy_file)
	return false
}

vertex_format_startup()
if (!shader_startup())
	return false

app_startup_globals()
app_startup_lists()
app_startup_window()

settings_startup()
project_legacy_startup()
render_startup()

if (!minecraft_assets_startup())
{
	error("errorloadassets")
	return false
}

startup_error = false

return true
