/// CppSeparate StringType user_directory_get()
/// @desc Returns the location where user generated files are written (log, key, settings, projects).
/// On Windows this is the Data folder in the installation, on Unix this is ~/Mine-imator.

function user_directory_get()
{
	return working_directory + "Data/"
}
