/// window_beep()

function window_beep(sound = 0)
{
	// default: MB_OK;
	// 1: MB_ICONERROR;
	// 2: MB_ICONQUESTION;
	// 3: MB_ICONWARNING;
	// 4: MB_ICONINFORMATION;
		
	if (!is_cpp())
		return 0
	
	return external_call(lib_window_beep, sound)
}
