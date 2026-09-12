/// window_taskbar_progress_value_set([progress])
/// @arg [progress]

function window_taskbar_progress_value_set(progress = 0)
{
	if (!is_cpp())
		return 0
	
	return external_call(lib_window_taskbar_progress_value_set, progress)
}