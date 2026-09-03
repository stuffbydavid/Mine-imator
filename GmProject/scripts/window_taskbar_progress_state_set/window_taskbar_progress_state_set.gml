/// window_taskbar_progress_state_set([state])
/// @arg [state]

function window_taskbar_progress_state_set(state = e_window_taskbar_state.NOPROGRESS)
{
	if (!is_cpp())
		return 0
	
	return external_call(lib_window_taskbar_progress_state_set, state)
}