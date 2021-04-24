/// window_set_focus()

function window_set_focus()
{
	return external_call(lib_window_set_focus, window_handle())
}
