/// texture_create_patched(filename)
/// @arg filename
/// @desc Load a patched texture from Data/Minecraft/Patched/ in datafiles if available, otherwise load the original file.

function texture_create_patched(fn)
{
	if (!is_cpp())
	{
		var name = filename_name(fn);
		if (file_exists_lib(patched_directory + name))
			return texture_create(patched_directory + name);
	}
	
	return texture_create(fn)
}