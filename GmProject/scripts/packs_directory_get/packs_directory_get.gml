/// CppSeparate StringType packs_directory_get()
/// Returns the location where imported resource packs are copied.
/// On Windows this is the Packs folder in the installation, on Unix this is ~/Mine-imator/Packs

function packs_directory_get()
{
	return working_directory + "Packs/"
}
