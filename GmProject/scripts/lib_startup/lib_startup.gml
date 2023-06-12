/// lib_startup()

function lib_startup()
{
	globalvar file_copy_temp;
	file_copy_temp = false
	if (is_cpp())
		return true
		
	log("External library init")
	
	var libpath, pathfile, pathmovie, pathwindow;
	libpath = "Data/Libraries/"
	pathfile = libpath + "file.dll"
	pathmovie = libpath + "movie.dll"
	pathwindow = libpath + "window.dll"
	
	if (!file_exists(pathfile))
		return missing_file(pathfile)
	
	if (!file_exists(pathmovie))
		return missing_file(pathmovie)
	
	if (!file_exists(pathwindow))
		return missing_file(pathwindow)
	
	globalvar lib_open_url, lib_execute, lib_unzip, lib_gzunzip, lib_file_rename, lib_file_copy, lib_file_delete, lib_file_exists, lib_json_file_convert_unicode;
	globalvar lib_directory_create, lib_directory_exists, lib_directory_delete;
	globalvar lib_movie_init, lib_movie_set, lib_movie_start, lib_movie_audio_file_decode, lib_movie_audio_file_add, lib_movie_audio_sound_add, lib_movie_frame, lib_movie_done;
	globalvar lib_window_maximize, lib_window_set_focus;
	
	// Window library
	log("External library", pathwindow)
	lib_window_maximize = external_define(pathwindow, "window_maximize", dll_cdecl, ty_real, 1, ty_string)
	lib_window_set_focus = external_define(pathwindow, "window_set_focus", dll_cdecl, ty_real, 1, ty_string)
	
	// File library
	log("External library", pathfile)
	file_copy_temp = true
	lib_open_url = external_define(pathfile, "open_url", dll_cdecl, ty_real, 1, ty_string)
	lib_execute = external_define(pathfile, "execute", dll_cdecl, ty_real, 3, ty_string, ty_string, ty_real)
	lib_unzip = external_define(pathfile, "unzip", dll_cdecl, ty_real, 2, ty_string, ty_string)
	lib_gzunzip = external_define(pathfile, "gzunzip", dll_cdecl, ty_real, 2, ty_string, ty_string)
	lib_file_rename = external_define(pathfile, "file_rename", dll_cdecl, ty_real, 2, ty_string, ty_string)
	lib_file_copy = external_define(pathfile, "file_copy", dll_cdecl, ty_real, 2, ty_string, ty_string)
	lib_file_delete = external_define(pathfile, "file_delete", dll_cdecl, ty_real, 1, ty_string)
	lib_file_exists = external_define(pathfile, "file_exists", dll_cdecl, ty_real, 1, ty_string)
	lib_directory_create = external_define(pathfile, "directory_create", dll_cdecl, ty_real, 1, ty_string)
	lib_directory_delete = external_define(pathfile, "directory_delete", dll_cdecl, ty_real, 1, ty_string)
	lib_directory_exists = external_define(pathfile, "directory_exists", dll_cdecl, ty_real, 1, ty_string)
	lib_json_file_convert_unicode = external_define(pathfile, "json_file_convert_unicode", dll_cdecl, ty_real, 2, ty_string, ty_string)
	
	// Movie library
	log("External library", pathmovie)
	lib_movie_init = external_define(pathmovie, "movie_init", dll_cdecl, ty_real, 0)
	lib_movie_set = external_define(pathmovie, "movie_set", dll_cdecl, ty_real, 5, ty_real, ty_real, ty_real, ty_real, ty_real)
	lib_movie_start = external_define(pathmovie, "movie_start", dll_cdecl, ty_real, 2, ty_string, ty_string)
	lib_movie_audio_file_decode = external_define(pathmovie, "movie_audio_file_decode", dll_cdecl, ty_real, 2, ty_string, ty_string)
	lib_movie_audio_file_add = external_define(pathmovie, "movie_audio_file_add", dll_cdecl, ty_real, 1, ty_string)
	lib_movie_audio_sound_add = external_define(pathmovie, "movie_audio_sound_add", dll_cdecl, ty_real, 6, ty_real, ty_real, ty_real, ty_real, ty_real, ty_real)
	lib_movie_frame = external_define(pathmovie, "movie_frame", dll_cdecl, ty_real, 1, ty_string)
	lib_movie_done = external_define(pathmovie, "movie_done", dll_cdecl, ty_real, 0)
	
	log("External library", "movie init")
	external_call(lib_movie_init)
	
	// Math library (windows.dll)
	math_lib_startup(pathwindow)
	
	return true
}
