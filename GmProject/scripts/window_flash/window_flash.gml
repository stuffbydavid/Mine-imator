/// window_flash()

function window_flash()
{
	if (!is_cpp() || benchmark_mode)
		return 0
	
	return external_call(lib_window_flash)
}