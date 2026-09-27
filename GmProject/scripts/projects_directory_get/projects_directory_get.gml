/// CppSeparate StringType projects_directory_get()
/// Returns the default location where projects are saved.
/// On Windows this is the Projects folder in the installation, on Unix this is ~/Mine-imator/Projects

function projects_directory_get()
{
	return working_directory + "Projects/"
}
