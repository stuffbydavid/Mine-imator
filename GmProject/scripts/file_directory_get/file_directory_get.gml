/// CppSeparate StringType file_directory_get()
/// @desc For developers, returns the location where build files are stored.
/// For users in a release build, returns the Mine-imator_tmp folder in AppData on Windows, or /tmp on Unix.
/// In GameMaker, this is the sandboxed Mine_imator folder in AppData.

function file_directory_get()
{
	return game_save_id
}
