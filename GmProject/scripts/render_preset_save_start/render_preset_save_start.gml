/// render_preset_save_start(filename, saveall)
/// @arg filename

function render_preset_save_start(fn)
{
	json_save_start(fn)
	json_save_object_start()
	json_save_var("format", render_settings_format)
	json_save_var("created_in", mineimator_version_full)
	json_save_var("name", name)
}