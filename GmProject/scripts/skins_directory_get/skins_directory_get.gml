/// CppSeparate StringType skins_directory_get()
/// Returns the location where downloaded player skins are saved.
/// On Windows this is the Skins folder in the installation, on Unix this is ~/Mine-imator/Skins

function skins_directory_get()
{
	return working_directory + "Skins/"
}
