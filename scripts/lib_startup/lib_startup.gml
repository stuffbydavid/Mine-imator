/// lib_startup()

log("Library startup")

var path_file, path_movie, path_window;
path_file = "Data\\file.dll"
path_movie = "Data\\movie.dll"
path_window = "Data\\window.dll"

globalvar lib_open_url, lib_execute, lib_unzip, lib_gzunzip, lib_file_rename, lib_file_copy, lib_file_delete, lib_file_exists;
globalvar file_copy_temp, lib_directory_create, lib_directory_exists, lib_directory_delete;
globalvar lib_movie_init, lib_movie_set, lib_movie_start, lib_movie_audio_file_decode, lib_movie_audio_file_add, lib_movie_audio_sound_add, lib_movie_frame, lib_movie_done;
globalvar lib_window_maximize, lib_window_set_focus;

log(path_file)
file_copy_temp = true
lib_open_url = external_define(path_file, "open_url", dll_cdecl, ty_real, 1, ty_string)
lib_execute = external_define(path_file, "execute", dll_cdecl, ty_real, 3, ty_string, ty_string, ty_real)
lib_unzip = external_define(path_file, "unzip", dll_cdecl, ty_real, 2, ty_string, ty_string)
lib_gzunzip = external_define(path_file, "gzunzip", dll_cdecl, ty_real, 2, ty_string, ty_string)
lib_file_rename = external_define(path_file, "file_rename", dll_cdecl, ty_real, 2, ty_string, ty_string)
lib_file_copy = external_define(path_file, "file_copy", dll_cdecl, ty_real, 2, ty_string, ty_string)
lib_file_delete = external_define(path_file, "file_delete", dll_cdecl, ty_real, 1, ty_string)
lib_file_exists = external_define(path_file, "file_exists", dll_cdecl, ty_real, 1, ty_string)
lib_directory_create = external_define(path_file, "directory_create", dll_cdecl, ty_real, 1, ty_string)
lib_directory_delete = external_define(path_file, "directory_delete", dll_cdecl, ty_real, 1, ty_string)
lib_directory_exists = external_define(path_file, "directory_exists", dll_cdecl, ty_real, 1, ty_string)

log(path_movie)
lib_movie_init = external_define(path_movie, "movie_init", dll_cdecl, ty_real, 0)
lib_movie_set = external_define(path_movie, "movie_set", dll_cdecl, ty_real, 5, ty_real, ty_real, ty_real, ty_real, ty_real)
lib_movie_start = external_define(path_movie, "movie_start", dll_cdecl, ty_real, 2, ty_string, ty_string)
lib_movie_audio_file_decode = external_define(path_movie, "movie_audio_file_decode", dll_cdecl, ty_real, 2, ty_string, ty_string)
lib_movie_audio_file_add = external_define(path_movie, "movie_audio_file_add", dll_cdecl, ty_real, 1, ty_string)
lib_movie_audio_sound_add = external_define(path_movie, "movie_audio_sound_add", dll_cdecl, ty_real, 5, ty_real, ty_real, ty_real, ty_real, ty_real)
lib_movie_frame = external_define(path_movie, "movie_frame", dll_cdecl, ty_real, 1, ty_string)
lib_movie_done = external_define(path_movie, "movie_done", dll_cdecl, ty_real, 0)

log("Movie init")
external_call(lib_movie_init)

log(path_window)
lib_window_maximize = external_define(path_window, "window_maximize", dll_cdecl, ty_real, 1, ty_string)
lib_window_set_focus = external_define(path_window, "window_set_focus", dll_cdecl, ty_real, 1, ty_string)

if (startup_last_crash)
{
	if (show_question("Do you want to report the crash now via the Mine-imator forums? In your bug report, copy paste the log contents, along with instructions how to recreate the bug. If the issue concerns a specific animation, upload its folder as a .zip.")) 
	{
		open_url(link_forums_bugs)
		open_url(log_previous_file)
	}
}
