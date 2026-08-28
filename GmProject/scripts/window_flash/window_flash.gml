/// window_flash()

function window_flash()
{
	if (!is_cpp() || dev_mode_project_benchmarks)
		return 0
	
	return external_call(lib_window_flash)
}